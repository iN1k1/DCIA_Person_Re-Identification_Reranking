function [ID, Index] = getSamplesToSet(dataset,cameraPair,personIdx,numSamples)

ID = [];
Index = [];

if strcmp(dataset.name,'PRID') || strcmp(dataset.name,'GRID')
    for i = 1:length(personIdx)
        IdxSamplesCamA = dataset.index(dataset.cam == cameraPair(1) & dataset.personID == personIdx(i));
        IdxSamplesCamB = dataset.index(dataset.cam == cameraPair(2) & dataset.personID == personIdx(i));

        idx = randperm(length(IdxSamplesCamB));
        if isempty(IdxSamplesCamA)
            ID = [ID;  repmat(personIdx(i), numSamples, 1)];
            Index = [Index; [NaN IdxSamplesCamB(idx(1:numSamples))']];
        else
            ID = [ID;  repmat(personIdx(i), numSamples, 1)];
            Index = [Index; [IdxSamplesCamA(idx(1:numSamples))' IdxSamplesCamB(idx(1:numSamples))']];
        end
    end
else
    for i = 1:length(personIdx)
        IdxSamplesCamA = dataset.index(dataset.cam == cameraPair(1) & dataset.personID == personIdx(i));
        IdxSamplesCamB = dataset.index(dataset.cam == cameraPair(2) & dataset.personID == personIdx(i));

        if length(IdxSamplesCamA) > length(IdxSamplesCamB)
            numSamplesAvailable = length(IdxSamplesCamB);
        else
            numSamplesAvailable = length(IdxSamplesCamA);
        end
        if numSamples > numSamplesAvailable
            numSamples = numSamplesAvailable;
        end
        idx = randperm(numSamplesAvailable);

        ID = [ID;  repmat(personIdx(i), numSamples, 1)];
        Index = [Index; [IdxSamplesCamA(idx(1:numSamples))' IdxSamplesCamB(idx(1:numSamples))']];
    end
end
