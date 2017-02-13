function [results] = ComputeFinalResults(iniResults, corrMatches, tKCCA, tsplit)

% Camera Pairs Loop
for ncp = 1:size(corrMatches,1)
    % Trials Loop
    for nt = 1:size(corrMatches,2)
        %Persons
        np = 1;
        for i = 1:length(corrMatches{ncp,nt}.matches)
            cM = corrMatches{ncp,nt}.matches{i};
            if ~isempty(cM) %&& np <= size(tKCCA(ncp).trial(nt).rKCCA.pos,2)
                if ~iscell(tsplit(ncp).trial(nt).testIdx)
                    try
                        testIdx = tsplit(ncp).trial(nt).testIdx(tKCCA(ncp).trial(nt).rKCCA.pos(:,np),2);
                    catch e
                        a = 0;
                    end
                    valIdx = ones(1,length(cM)).*NaN;
                    for j = 1:length(cM)
                        pos = find(testIdx==cM(j));
                        if ~isempty(pos)
                            valIdx(j) = tKCCA(ncp).trial(nt).rKCCA.dist(pos,np);
                        end
                    end
                    maxv = max(valIdx);
                    for j = 1:length(cM)
                        if isnan(valIdx(j))
                            valIdx(j) = maxv + rand/10;
                        end
                    end 
                    [valIdx, pos] = sort(valIdx,'ascend');
                    order = pos;
                else
                    order = tKCCA(ncp).trial(nt).rKCCA.pos{i};
                    valIdx = tKCCA(ncp).trial(nt).rKCCA.dist{i};
                end
                
                allIdx = iniResults(ncp).rankingIdx(i,2:end,nt);
                allIDs = iniResults(ncp).rankingIDs(i,2:end,nt);
                allVal = iniResults(ncp).rankingVal(i,2:end,nt);
                Idx = ones(1,length(cM)).*NaN;
                IDs = ones(1,length(cM)).*NaN;
                Val = ones(1,length(cM)).*NaN;
                for j = 1:length(cM)
                    pos = find(allIdx==cM(j));
                    Idx(j) = allIdx(pos);
                    IDs(j) = allIDs(pos);
                    Val(j) = allVal(pos);
                    allIdx(pos) = NaN;
                    allIDs(pos) = NaN;
                    allVal(pos) = NaN;
                end
                allIdx = allIdx(~isnan(allIdx));
                allIDs = allIDs(~isnan(allIDs));
                allVal = allVal(~isnan(allVal));
                Idx = reshape(Idx(order), 1, []);
                IDs = reshape(IDs(order), 1, []);
                Val = reshape(valIdx, 1, []);
                
                iniResults(ncp).rankingIdx(i,2:end,nt) = [Idx allIdx];
                iniResults(ncp).rankingIDs(i,2:end,nt) = [IDs allIDs];
                iniResults(ncp).rankingVal(i,2:end,nt) = [Val allVal];
                rerankedTrueMatchPos = find(iniResults(ncp).rankingIDs(i,2:end,nt)==iniResults(ncp).rankingIDs(i,1,nt));
                iniResults(ncp).rerankGain(i,nt) = iniResults(ncp).trueMatchPos(1,i,nt) - rerankedTrueMatchPos;
                iniResults(ncp).trueMatchPos(1,i,nt) = rerankedTrueMatchPos;
                
                
                np = np +1;
            else
                iniResults(ncp).rerankGain(i,nt) = NaN;
            end
            
            
        end
        CMC = zeros(1,size(iniResults(ncp).trueMatchPos,2));
        for i = 1:size(iniResults(ncp).trueMatchPos,2)
            CMC(i) = (length(find(iniResults(ncp).trueMatchPos(1,:,nt)<=i)))/length(CMC);
        end
        results(ncp).trialsCMC(nt,:) = CMC;
        p = ~isnan(iniResults(ncp).rerankGain(:,nt));
        results(ncp).rerankImproved(nt) = sum(iniResults(ncp).rerankGain(p,nt)>0);
        results(ncp).rerankDeterioratied(nt) = sum(iniResults(ncp).rerankGain(p,nt)<0);
    end
    results(ncp).rankingIDs = iniResults(ncp).rankingIDs;
    results(ncp).rankingIdx = iniResults(ncp).rankingIdx;
    results(ncp).rankingVal = iniResults(ncp).rankingVal;
    results(ncp).trueMatchPos = iniResults(ncp).trueMatchPos;
    
    % global CMC
    if size(results(ncp).trialsCMC,1) > 1 
        results(ncp).CMC = mean(results(ncp).trialsCMC);
    else
        results(ncp).CMC = results(ncp).trialsCMC;
    end
    
    results(ncp).antCMC = iniResults(ncp).CMC; 
end