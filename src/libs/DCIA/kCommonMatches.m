function [kcommonMatchesScore, kcommonMatchesIdx] = kCommonMatches(Idx, cluster, probeScore, matchScore, kcommonMatchesNum)

% Compute score of the each kmatch
score = (probeScore + matchScore)./2;
[score, pos] = sort(score,'descend');
Idx = Idx(pos);
cluster = cluster(pos);

scoreCluster = score(cluster==1);
matchCluster = Idx(cluster==1);

[bins, pos] = unique(matchCluster);
matchClusterScore = scoreCluster(pos);

matchClusterNum = zeros(length(bins),1);
for i = 1:length(bins)
    matchClusterNum(i) = length(find(matchCluster==bins(i)))/matchClusterScore(i); 
end

% Select k more common matches
[allkcommonMatchesScore, pos] = sort(matchClusterNum,'descend');
allkcommonMatchesIdx = bins(pos);

if length(allkcommonMatchesIdx) >= kcommonMatchesNum
    kcommonMatchesScore = allkcommonMatchesScore(1:kcommonMatchesNum);
    kcommonMatchesIdx = allkcommonMatchesIdx(1:kcommonMatchesNum);
else
    kcommonMatchesScore = allkcommonMatchesScore(1:length(allkcommonMatchesIdx));
    kcommonMatchesIdx = allkcommonMatchesIdx(1:length(allkcommonMatchesIdx));
end