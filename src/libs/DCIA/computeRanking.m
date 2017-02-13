function [rankingIDs, rankingIdx, rankingVal, trueRank] = computeRanking(dist, pos, galleryIdx, galleryIDs, IDs, idx, kmatch, probeIdx)

rankingIDs = zeros(1,size(dist,1)+1);
rankingIdx = zeros(1,size(dist,1)+1);
rankingVal = zeros(1,size(dist,1)+1).*NaN;

rankingVal(:,2:end) = dist';

rankingIdx(1,1) = idx(kmatch,2);
rankingIDs(1,1) = IDs(kmatch);

rankingIdx(1,2:end) = galleryIdx(pos(:,1));
rankingIDs(1,2:end) = galleryIDs(pos(:,1));

trueRank = find(rankingIdx(1,2:end)==probeIdx);
