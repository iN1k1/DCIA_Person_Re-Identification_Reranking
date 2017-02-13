function [corrMatches] = ContentSetSelection(initialResults, pars, trainFlag)

for ncp = 1:length(initialResults)
    for nt = 1:size(initialResults(ncp).rankingVal,3)
        rankingValues = initialResults(ncp).rankingVal(:,:,nt);
        rankingIdx = initialResults(ncp).rankingIdx(:,:,nt);
        trueMatchPos = initialResults(ncp).trueMatchPos(:,:,nt);
        if trainFlag
            if ~isfield(initialResults, 'isTrain2')
                corrMatches{ncp,nt} = getCorrMatches(rankingValues, rankingIdx, trueMatchPos, false, pars.contestInfo.errorPerc, trainFlag);
            else
                corrMatches{ncp,nt} = getCorrMatches(rankingValues, rankingIdx, trueMatchPos, false, pars.contestInfo.errorPerc, trainFlag);
            end
        else
            corrMatches{ncp,nt} = getCorrMatches(rankingValues, rankingIdx, trueMatchPos, false, NaN, trainFlag);
        end
    end
end

end