function [dia] = ComputeDiscriminantInformationAnalisys(iniRanking, corrMatches, contextInfo, dataset, features, VEData, split, pars, PCAmodel, trainFlag)

dia = repmat(struct('Idx', [], 'vec', []), size(contextInfo,1), size(contextInfo,2), size(contextInfo,3));

% Loop over camera pairs
for ncp = 1:size(contextInfo,1)
    pcaCompUsed = ones(size(contextInfo,2),size(contextInfo,3)).*NaN;
    
    % Loop over trials
    for nt = 1:size(contextInfo,2)
        
        % For each probe
        parfor i = 1:size(contextInfo,3)
            
            % Does the probe has a corresponding content set or context set? 
            if ~isempty(contextInfo(ncp,nt,i).matchNum)
                
                probe = iniRanking.rankingIdx(i,1,nt);
                content = corrMatches{ncp,nt}.matches{i}';
                context = contextInfo(ncp,nt,i).matchIdx;
                probeW = max(contextInfo(ncp,nt,i).matchNum);
                contentW = repmat(max(contextInfo(ncp,nt,i).matchNum),length(corrMatches{ncp,nt}.matches{i}),1);
                contextW = contextInfo(ncp,nt,i).matchNum;
                
                if pars.includingContent && pars.includingContext && pars.includingProbe
                    allIdx = [probe; content; context];
                    allWeights = [probeW; contentW; contextW];
                elseif pars.includingContent && ~pars.includingContext && pars.includingProbe
                    allIdx = [probe; content];
                    allWeights = [probeW; contentW];
                elseif ~pars.includingContent && pars.includingContext && pars.includingProbe
                    allIdx = [probe; context];
                    allWeights = [probeW; contextW];
                elseif pars.includingContent && pars.includingContext && ~pars.includingProbe
                    allIdx = [content; context];
                    allWeights = [contentW; contextW];
                else
                    allIdx = probe;
                    allWeights = probeW;
                end
                
                [diaIdx, pos] = unique(allIdx);
                diaWeights = allWeights(pos);
                
                if pars.weights
                    diaWeights = ((361-abs(dataset.orientation(diaIdx)'-dataset.orientation(probe)))./360) .* diaWeights;
                else
                    diaWeights = ones(length(diaIdx),1) .* diaWeights;
                end
                
                if pars.enlarge   
                    enlarge = [];
                    if pars.enlargeType == 0
                        enlarge = round(diaWeights./min(diaWeights));
                    elseif pars.enlargeType == 1
                        enlarge = round(diaWeights./min(diaWeights));
                        enlarge = abs(enlarge - (max(enlarge(:))+1));
                    elseif pars.enlargeType == 2
                        enlarge = ones(length(diaWeights),1).*4;
                    end
                    enlarge(enlarge(:)<1)=1;
                    
                    aux = diaIdx;
                    diaIdx = [];
                    for j = 1:length(aux)
                        diaIdx = [diaIdx; repmat(aux(j),enlarge(j),1)];
                    end
                    diaWeights = ones(length(diaIdx),1);
                end
                
                if PCAmodel
                    VEDataProbe = VEData.VEprobe.PCAfeat{nt};
                else
                    VEDataProbe = VEData.VEprobe.feat{nt};
                end
                
                % Obtain features
                auxFeatures = features;
                auxFeatures(probe,:) = VEDataProbe(probe,:);
                featData = auxFeatures(diaIdx,:);
                %clear auxFeatures
                
                % Apply PCA
                % Niki => OLD: robustPCA returned a 3rd par PCAplot which
                % was not used!
                try 
                    [newFeatData, pcaCompUsed(nt,i)] = robustPCA(featData', diaWeights, pars.PCAType, pars.PCAcompNum, pars.PCAimportance);
                catch ppp
                    error('Check Robust PCA');
                end
                
                PCAIdx = diaIdx;

                if ~pars.includingContent && pars.includingContext && pars.includingProbe
                    newFeatData = [features(corrMatches{ncp,nt}.matches{i},:)' newFeatData];
                    diaIdx = [corrMatches{ncp,nt}.matches{i}'; diaIdx];            
                end
                
                if pars.includingContent && pars.includingContext && ~pars.includingProbe
                    newFeatData = [VEDataProbe(probe,:)' newFeatData];
                    diaIdx = [probe; diaIdx]; 
                end

                [fdiaIdx, pos] = unique(diaIdx);
                fnewFeatData = newFeatData(:,pos);
                
                [PCAIdx, pos2] = unique(PCAIdx);
                
                if trainFlag
                    Idx = split(ncp).train(nt).index;
                    if isfield(iniRanking, 'isTrain2')
                        Idx = split(ncp).train2(nt).index;
                    end
                    gallery = Idx(Idx(:,1)==probe,2);
                    probePos = fdiaIdx==probe;
                    galleryPos = fdiaIdx==gallery;
                    dia(ncp,nt,i).Idx = [probe; gallery];
                    dia(ncp,nt,i).vec = [fnewFeatData(:,probePos) fnewFeatData(:,galleryPos)];
                else
                    if pars.matchingType == 1
                        Idx = split(ncp).test(nt).index;
                        gallery = Idx(Idx(:,1)==probe,2);
                        probePos = fdiaIdx==probe;
                        galleryPos = fdiaIdx==gallery;
                        dia(ncp,nt,i).Idx = [probe; gallery];
                        dia(ncp,nt,i).vec = [fnewFeatData(:,probePos) fnewFeatData(:,galleryPos)];
                    else
                        probePos = fdiaIdx==probe;
                        galleryPos = zeros(length(fdiaIdx),1);
                        for j = 1:length(corrMatches{ncp,nt}.matches{i})
                            corrPos = fdiaIdx==corrMatches{ncp,nt}.matches{i}(j);
                            galleryPos = galleryPos|corrPos;
                        end
                        dia(ncp,nt,i).Idx = [fdiaIdx(probePos); fdiaIdx(galleryPos)];
                        dia(ncp,nt,i).vec = [fnewFeatData(:,probePos) fnewFeatData(:,galleryPos)];
                        Idx = split(ncp).test(nt).index;
                        gallery = Idx(Idx(:,1)==probe,2);
                    end
                end
            else
                dia(ncp,nt,i).Idx = [];
                dia(ncp,nt,i).vec = [];
            end
        end
    end
    dia(ncp).statistics.data = pcaCompUsed;
    dia(ncp).statistics.mean = mean(pcaCompUsed);
    dia(ncp).statistics.std = std(pcaCompUsed);
end
