function [results] = computeResults(split, rKCCA, trainFlag, modelName, dataset)

for ncp = 1:length(split)
    for nt = 1:length(split(ncp).test)
        dists = rKCCA(ncp).trial(nt).rKCCA.dist;
        pos = rKCCA(ncp).trial(nt).rKCCA.pos;
        if trainFlag
            IDs = split(ncp).train(nt).ID;
            idx = split(ncp).train(nt).index;
        else
            IDs = split(ncp).test(nt).ID;
            idx = split(ncp).test(nt).index;
        end
        % trials CMC
        [CMC(nt).data, rankingIDs(nt).data, rankingIdx(nt).data, rankingVal(nt).data, trueMatchPos(nt).data] = computeCMC(dists, pos, IDs, idx);  
    end
    % arrayCMC
    results(ncp).trialsCMC = zeros(length(CMC),length(CMC(1).data));
    for i = 1:length(CMC)
        results(ncp).trialsCMC(i,:) = CMC(i).data;
    end
    % global CMC
    if size(results(ncp).trialsCMC,1) > 1 
        results(ncp).CMC = mean(results(ncp).trialsCMC);
    else
        results(ncp).CMC = results(ncp).trialsCMC;
    end
    % ranking from each person
    results(ncp).rankingIDs = zeros(size(rankingIDs(1).data,1),size(rankingIDs(1).data,2),length(rankingIDs));
    for i = 1:length(rankingIDs)
        results(ncp).rankingIDs(:,:,i) = rankingIDs(i).data;
    end
    results(ncp).rankingIdx = zeros(size(rankingIdx(1).data,1),size(rankingIdx(1).data,2),length(rankingIdx));
    for i = 1:length(rankingIdx)
        results(ncp).rankingIdx(:,:,i) = rankingIdx(i).data;
    end
    results(ncp).rankingVal = zeros(size(rankingVal(1).data,1),size(rankingVal(1).data,2),length(rankingVal));
    for i = 1:length(rankingVal)
        results(ncp).rankingVal(:,:,i) = rankingVal(i).data;
    end
    results(ncp).trueMatchPos = zeros(size(trueMatchPos(1).data,1),size(trueMatchPos(1).data,2),length(trueMatchPos));
    for i = 1:length(trueMatchPos)
        results(ncp).trueMatchPos(:,:,i) = trueMatchPos(i).data;
    end
end