function [sets] = splitDataset(dataset,pars)

fprintf('Spliting dataset...');
t = tic;

% Try to load split
sets = loadSplit(pars);
if ~isempty(sets)
    fprintf('done in %.2f(s)\n', toc(t));
    return
end

% Fix random generator!!
rng(2);
    
% Camera Pairs Loop
for ncp = 1:size(pars.split.cameraPairs,1)
    cameraPair = pars.split.cameraPairs(ncp,:);
    
    idxCamA = dataset.personID(dataset.cam == cameraPair(1));
    idxCamB = dataset.personID(dataset.cam == cameraPair(2));
    allCommonIndex = sort(intersect(idxCamA,idxCamB),'ascend');
    personsNumToTest = round(length(allCommonIndex)*pars.split.persons2test);
    
    % Trials Loop
    for nt = 1:pars.split.numTrials

        % Split index for train and test
        if strfind(lower(dataset.name),'prid') > 0           
            allIndex = randperm(length(allCommonIndex));
            testIdx = sort(setdiff(idxCamB,allCommonIndex(allIndex(personsNumToTest+1:end))),'ascend');
            trainIdx = sort(allCommonIndex(allIndex(personsNumToTest+1:end)),'ascend');
        else
            allIndex = randperm(length(allCommonIndex));
            if ~isnan(personsNumToTest) 
                testIdx = sort(allCommonIndex(allIndex(1:personsNumToTest)),'ascend');
                trainIdx = sort(allCommonIndex(allIndex(personsNumToTest+1:end)),'ascend');
            else
                testIdx = sort(allCommonIndex(allIndex(1:pars.split.persons2testN)),'ascend');
                trainIdx = sort(allCommonIndex(allIndex(pars.split.persons2testN+1:pars.split.persons2testN+pars.split.persons2trainN)),'ascend');
            end
        end

        % Select samples for each personID
        sets(ncp).test(nt).personsIndex = testIdx;
        [sets(ncp).test(nt).ID, sets(ncp).test(nt).index] = getSamplesToSet(dataset,cameraPair,testIdx,pars.split.numSamplesPerPersonTest);

        sets(ncp).train(nt).personsIndex = trainIdx;
        [sets(ncp).train(nt).ID, sets(ncp).train(nt).index] = getSamplesToSet(dataset,cameraPair,trainIdx,pars.split.numSamplesPerPersonTrain);
        
        % Eventually split the training set into two subsets..
        if ~isnan(pars.split.person2trainSplitModelsPerc)
            perm = randperm(length(trainIdx), length(trainIdx));
            trN = round(length(trainIdx)*pars.split.person2trainSplitModelsPerc(1));
            
            % Reduce initial training split
            trainIdx1 = trainIdx(perm(1:trN));
            sets(ncp).train(nt).personsIndex = trainIdx1;
            [sets(ncp).train(nt).ID, sets(ncp).train(nt).index] = getSamplesToSet(dataset,cameraPair,trainIdx1,pars.split.numSamplesPerPersonTrain);
            
            % Generate second training split
            trainIdx2 = trainIdx(perm(trN+1:end));
            sets(ncp).train2(nt).personIndex = trainIdx2;
            [sets(ncp).train2(nt).ID, sets(ncp).train2(nt).index] = getSamplesToSet(dataset,cameraPair,trainIdx2,pars.split.numSamplesPerPersonTrain);
        end
    end
end
split = sets;
save(fullfile(pars.results.folder,'split.mat'), 'split');
fprintf('done in %.2f(s)\n', toc(t));
end