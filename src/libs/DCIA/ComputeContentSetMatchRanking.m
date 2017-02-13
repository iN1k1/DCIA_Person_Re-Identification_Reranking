function [ranking] = ComputeContentSetMatchRanking(corrMatches, features, VEData, split, algo, kernels, pars, trainFlag)

ranking = repmat(struct('IDs', {[]}, 'Idx', {[]}, 'Val', {[]}, 'ranking', {[]}), size(corrMatches,1), size(corrMatches,2));
kernel = [];

% Camera Pairs Loop
for ncp = 1:size(corrMatches,1)
    % Trials Loop
    for nt = 1:size(corrMatches,2)
        if trainFlag
            test_idx = split(ncp).train(nt).index;
            test_IDs = split(ncp).train(nt).ID;
            if ~isempty(kernel) && isfield(split(ncp), 'train2')
                test_idx = split(ncp).train2(nt).index;
                test_IDs = split(ncp).train2(nt).ID;
            end
            train_idx = split(ncp).train(nt).index;
        else
            test_idx = split(ncp).test(nt).index;
            test_IDs = split(ncp).test(nt).ID;
            train_idx = split(ncp).train(nt).index;
            
            if ~isempty(kernel) && isfield(split(ncp), 'train2')
                kernel = kernels(ncp).trial(nt);
                kernel.KA_train = kernel.KA_train2;
                kernel.KB_train = kernel.KB_train2;
                kernel.meanA = kernel.meanA2;
                kernel.meanB = kernel.meanB2;
                train_idx = split(ncp).train2(nt).index;
            end
        end
        
        try
            VEDataProbe = VEData.VEprobe.feat{nt};
            VEDataGallery = VEData.VEgallery.feat{nt};
        catch
            VEDataProbe = VEData.VEprobe.PCAfeat{nt};
            VEDataGallery = VEData.VEgallery.PCAfeat{nt};
        end
        
        aux = corrMatches{ncp,nt};
        
        
        % Niki => this nested loops are used to initialize the IDs, Idx,
        % Val and TrueRank cell arrays such that they can be used in a
        % parfor loop!
        for i = 1:length(test_idx(~isnan(test_idx(:,1)),1))
            
            % Get list of correlated matches
            crMatches = aux.matches{i};
            if ~isempty(crMatches)
                % Matches Loop
                for jj = 1:length(crMatches)
                    IDs{i}{jj} = [];
                    Idx{i}{jj} = [];
                    Val{i}{jj} = [];
                    TrueRank{i}{jj} = [];
                end
            end
        end
        
        % Loop over all probes which have at least a correlated match!
        parfor i = 1:length(test_idx(~isnan(test_idx(:,1)),1))
            matches = aux.matches{i};
            if ~isempty(matches)
                % Matches Loop
                for j = 1:length(matches)
                    % Order Idx for compute rankings
                    [kfeat, gfeat, galleryIdx, galleryIDs] = generateListsToRanking(i,matches(j),test_idx,test_IDs,features,VEDataProbe,VEDataGallery);

                    % Compute distances
                    [dist, pos] = ComputeDists(kfeat, gfeat, features, train_idx, algo, kernel, pars);
                    
                    % Compute the matching IDs, indexes and scores between
                    % the j-th corrleated match used as probe and all the
                    % gallery images + i-th probe
                    [mIDs, mIdx, mVal, trueRank] = computeRanking(dist, pos, galleryIdx, galleryIDs, test_IDs, test_idx, find(test_idx(:,2)==matches(j)), test_idx(i));
                    
                    % Niki => removed from ranking structure to allow parallel loop
                    IDs{i}{j} = mIDs;
                    Idx{i}{j} = mIdx;
                    Val{i}{j} = mVal;
                    TrueRank{i}{j} = trueRank;
                    %ranking(ncp,nt).IDs{i}{j} = mIDs; 
                    %ranking(ncp,nt).Idx{i}{j} = mIdx;
                    %ranking(ncp,nt).Val{i}{j} = mVal;
                    %ranking(ncp,nt).TrueRank{i}{j} = trueRank;
                    
                end
            else
                % Niki => removed from ranking structure to allow parallel loop
                IDs{i} = [];
                Idx{i} = [];
                Val{i} = [];
                TrueRank{i} = [];
                %ranking(ncp,nt).IDs{i} = []; 
                %ranking(ncp,nt).Idx{i} = [];
                %ranking(ncp,nt).Val{i} = [];
                %ranking(ncp,nt).TrueRank{i} = [];
            end
        end
        ranking(ncp,nt).IDs = IDs;
        ranking(ncp,nt).Idx = Idx;
        ranking(ncp,nt).Val = Val;
        ranking(ncp,nt).TrueRank = TrueRank;
        clear IDs Idx Val TrueRank;
    end
end