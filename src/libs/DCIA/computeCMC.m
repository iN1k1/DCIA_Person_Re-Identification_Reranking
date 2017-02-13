function [CMC, rankingIDs, rankingIdx, rankingVal, trueRank] = computeCMC(dist, pos, IDs, idx)

rankingIDs = zeros(size(dist,2),size(dist,1)+1);
rankingIdx = zeros(size(dist,2),size(dist,1)+1);
rankingVal = zeros(size(dist,2),size(dist,1)+1).*NaN;

rankingVal(:,2:end) = dist';

trueRank = zeros(1,size(dist,2));
for i = 1:size(dist,2)
    ranksIDs = IDs(pos(:,i));
    trueRank(i) = find(ranksIDs==IDs(i));
    rankingIDs(i,1) = IDs(i);
    rankingIDs(i,2:end) = ranksIDs;
    rankingIdx(i,1) = idx(i,1);
    ranksIdx = idx(pos(:,i),2);
    rankingIdx(i,2:end) = ranksIdx;
end
CMC = zeros(1,size(dist,2));
for i = 1:size(dist,2)
    CMC(i) = (length(find(trueRank<=i)))/length(CMC);
end
