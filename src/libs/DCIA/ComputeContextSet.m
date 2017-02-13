function [contextInfo] = ComputeContextSet(initResults, allRankings, pars)

% Niki
% initialize context info structure to allow parallel loop!
contextInfo = repmat(struct('matchNum', [], 'matchIdx', [], 'clusters', []), size(allRankings,1), size(allRankings,2), length(allRankings(1,1).Idx));
%contextInfo = [];

% Camera Pairs Loop
for ncp = 1:size(allRankings,1)
    % Trials Loop
    for nt = 1:size(allRankings,2)
        rankings = allRankings(ncp,nt);
        % Person Test Loop
        parfor i = 1:length(rankings.Idx)
            if ~isempty(rankings.Idx{i})
                % Create clusters
                cluster = [];
                for j = 1:length(rankings.Idx{i})
                    aux = createClusters(initResults(ncp).rankingIdx(i,:,nt), ...
                        initResults(ncp).rankingIDs(i,:,nt),initResults(ncp).rankingVal(i,:,nt), ...
                        rankings.Idx{i}{j},rankings.IDs{i}{j},rankings.Val{i}{j});
                    contextInfo(ncp,nt,i).clusters{j} = aux;
                    cluster = [cluster; aux]; 
                end
                % Find the k-common matches
                [contextInfo(ncp,nt,i).matchNum, contextInfo(ncp,nt,i).matchIdx] = kCommonMatches(cluster(:,3),cluster(:,5),cluster(:,1),cluster(:,2),pars.kcommonMatches);
            else
                contextInfo(ncp,nt,i).matchNum = [];
                contextInfo(ncp,nt,i).matchIdx = [];
            end
        end
    end
end

