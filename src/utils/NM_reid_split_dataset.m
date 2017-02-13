function [train, cv, test, test2] = NM_reid_split_dataset( dataset, pars )
% Author:    Niki Martinel
% Date:      2012/10/30 10:38:19
% Revision:  0.1
% Copyright: Niki Martinel, 2012


% Loop through all transformations 
for i=1:size(pars.settings.testCams,1)

    % Loop through all tests
    for t=1:pars.settings.numTests
    
        %% Split into train/test datasets
        allPeopleIDs = 1:dataset.peopleCount;

        % Randomly shuffled person IDs
        if ~isempty(pars.settings.testPeopleIDs)
            if size(pars.settings.testPeopleIDs, 2) > 1
                allPeopleIDs = pars.settings.testPeopleIDs(:,t);
            else
                allPeopleIDs = pars.settings.testPeopleIDs;
            end
        else
            allPeopleIDs = allPeopleIDs(randperm(length(allPeopleIDs)));
        end
        
        % Reduce dataset size if requried
        if ~isempty(pars.settings.numPersons)
            allPeopleIDs = allPeopleIDs(1:pars.settings.numPersons);
        end
        
        % Number of person per each set (we can have some overlapping)
        numPersonTrain = round(pars.settings.learningSets(1)*length(allPeopleIDs));
        
        % Person IDs used for training and testing
        idPersonTrain = sort(allPeopleIDs(1:numPersonTrain), 'ascend');
        idPersonTest = sort(allPeopleIDs(numPersonTrain+1:end), 'ascend');
        idPersonTest2 = idPersonTrain;
        
        % Use the same persons for training and testing
        if pars.settings.trainAndTestWithSamePersons
            idPersonTrain = idPersonTest;
        end

        if ~isfield(pars.settings, 'useSameImageIndexForPositiveAndNegativeSamples')
            pars.settings.useSameImageIndexForPositiveAndNegativeSamples = false;
        end
        useSameImageIndexForPositiveAndNegativeSamples = pars.settings.useSameImageIndexForPositiveAndNegativeSamples;
        
        % Get training and test samples
        if ~pars.settings.trainAndTestWithSamePersons
            
            % Training set
            train(i, t) = getSamples(dataset, idPersonTrain, pars.settings.testCams(i,:), ...
                pars.settings.numberSamplesPerPersonTraining(1), pars.settings.numberSamplesPerPersonTraining(2), ...
                useSameImageIndexForPositiveAndNegativeSamples);
            
            % Cross validation set
            if ~isempty(pars.classifier.kfold) && pars.classifier.kfold > 0
                cvPartition = cvpartition(length(idPersonTrain), 'kfold', pars.classifier.kfold);
                for c=1:pars.classifier.kfold
                    cv.train(i,t,c) = getSamples(dataset, idPersonTrain(cvPartition.training(c)), pars.settings.testCams(i,:), pars.settings.numberSamplesPerPersonTraining(1), pars.settings.numberSamplesPerPersonTraining(2), useSameImageIndexForPositiveAndNegativeSamples);
                    cv.test(i,t,c) = getSamples(dataset, idPersonTrain(cvPartition.test(c)), pars.settings.testCams(i,:), pars.settings.numberSamplesPerPersonTesting(1), pars.settings.numberSamplesPerPersonTesting(2), useSameImageIndexForPositiveAndNegativeSamples);
                end
            else
                cv = [];
            end
            
            % Test set
            test(i, t) = getSamples(dataset, idPersonTest, pars.settings.testCams(i,:), ...
                pars.settings.numberSamplesPerPersonTesting(1), pars.settings.numberSamplesPerPersonTesting(2), ...
                useSameImageIndexForPositiveAndNegativeSamples);
            
            test2(i, t) = getSamples(dataset, idPersonTest2, pars.settings.testCams(i,:), ...
                pars.settings.numberSamplesPerPersonTesting(1), pars.settings.numberSamplesPerPersonTesting(2), ...
                useSameImageIndexForPositiveAndNegativeSamples);
        else
            
            % Training and test set
            [train(i, t), test(i,t)] = getOverlappingSamples(dataset, idPersonTrain, idPersonTest, ...
                pars.settings.testCams(i,:), ...
                pars.settings.numberSamplesPerPersonTraining, pars.settings.numberSamplesPerPersonTesting, ...
                useSameImageIndexForPositiveAndNegativeSamples);
            
            % Cross validation set
            if ~isempty(pars.classifier.kfold) && pars.classifier.kfold > 0
                cvPartition = cvpartition(length(idPersonTrain), 'kfold', pars.classifier.kfold);
                for c=1:pars.classifier.kfold
                    [cv.train(i,t,c), cv.test(i,t,c)] = getOverlappingSamples(dataset, idPersonTrain(cvPartition.training(c)), idPersonTrain(cvPartition.test(c)), ...
                        pars.settings.testCams(i,:), ...
                        pars.settings.numberSamplesPerPersonTraining, pars.settings.numberSamplesPerPersonTraining, ...
                        useSameImageIndexForPositiveAndNegativeSamples);
                    %cv(i,t,c).test = getSamples(dataset, idPersonTrain(cvPartition.test(c)), ...
                    %    pars.settings.testCams(i,:), pars.settings.numberSamplesPerPersonTesting(1), pars.settings.numberSamplesPerPersonTesting(2), ...
                    %    useSameImageIndexForPositiveAndNegativeSamples);
                end
            else
                cv = [];
            end
        end
    end
end

end

%% GET TRAINING SAMPLES SAMPLES
function [samples] = getSamples(dataset, personsIDs, cameraPair, numPositive, numNegative, useSameImageIndexForPositiveAndNegativeSamples)

samples.ID = [];
samples.index = [];
samples.label = [];
if (numPositive < 0 && numNegative < 0)
    numPositive = abs(numPositive);
    numNegative = abs(numNegative);
    
    if strcmpi(dataset.name, 'VIPeR')
        idx1 = dataset.imageIndex(dataset.cam==cameraPair(1));
        idx2 = dataset.imageIndex(dataset.cam==cameraPair(2));
        
        idx1 = idx1(personsIDs);
        randSortedPersonsIDs = personsIDs(randperm(length(personsIDs)));
        idx2 = idx2(randSortedPersonsIDs);
        samples.index = allcomb(idx1, idx2);
        samples.ID = allcomb(personsIDs, randSortedPersonsIDs);        
    else
        
        idx1_pos = cell(length(personsIDs), 1);
        idx1_neg = cell(length(personsIDs), 1);
        idx2_pos = cell(length(personsIDs), 1);
        idx2_neg = cell(length(personsIDs), 1);
        for i=1:length(personsIDs)
            tmp = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==personsIDs(i));
            if ~isempty(tmp)
                tmp = tmp(randperm(length(tmp)))';
                if numPositive > length(tmp)
                    idx1_pos{i} = tmp;
                else
                    idx1_pos{i} = tmp(1:numPositive);
                end
                if numNegative > length(tmp)
                    idx1_neg{i} = tmp;                    
                else
                    idx1_neg{i} = tmp(1:numNegative);
                end
            else
                idx1_pos{i} = [];
                idx1_neg{i} = [];
            end
            
            tmp = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==personsIDs(i));
            if ~isempty(tmp)
                tmp = tmp(randperm(length(tmp)))';
                if numPositive > length(tmp)
                    idx2_pos{i} = tmp;
                else
                    idx2_pos{i} = tmp(1:numPositive);
                end
                if numNegative > length(tmp)
                    idx2_neg{i} = tmp;
                else
                    idx2_neg{i} = tmp(1:numNegative);
                end
            else
                idx2_pos{i} = [];
                idx2_neg{i} = [];
            end
        end
        
        id_pos = cell2mat(arrayfun(@(x)(allcomb(repmat(personsIDs(x), numel(idx1_pos{x}), 1), repmat(personsIDs(x), numel(idx2_pos{x}), 1))),1:length(personsIDs), 'UniformOutput', false)');
        idx_pos = cell2mat(arrayfun(@(x)(allcomb(idx1_pos{x}, idx2_pos{x})), 1:length(personsIDs), 'UniformOutput', false)');
        samples.ID = [samples.ID; id_pos];
        samples.index = [samples.index; idx_pos];
        
        id_1 = cell2mat(arrayfun(@(x)(repmat(personsIDs(x), numel(idx1_neg{x}), 1)), 1:length(personsIDs), 'UniformOutput', false)');
        id_2 = cell2mat(arrayfun(@(x)(repmat(personsIDs(x), numel(idx2_neg{x}), 1)), 1:length(personsIDs), 'UniformOutput', false)');
        id_neg = allcomb(id_1, id_2);
        idx_neg = allcomb(cell2mat(idx1_neg), cell2mat(idx2_neg));
        toRemove = id_neg(:,1) == id_neg(:,2);
        id_neg(toRemove,:) = [];
        idx_neg(toRemove,:) = [];
        samples.ID = [samples.ID; id_neg];
        samples.index = [samples.index; idx_neg];
        
        
%         for i=1:length(personsIDs)
%             id_neg = cell2mat(arrayfun(@(x)(allcomb(repmat(personsIDs(i), numel(idx1_neg(x)), 1), repmat(personsIDs(x), numel(idx2_neg(x)), 1))), setdiff(1:length(personsIDs),i), 'UniformOutput', false)');
%             idx_neg = cell2mat(arrayfun(@(x)(allcomb(idx1_neg{i}, idx2_neg{x})), setdiff(1:length(personsIDs), i), 'UniformOutput', false)');
%             samples.ID = [samples.ID; id_neg];
%             samples.index = [samples.index; idx_neg];
%         end
    end
        
%         
%         %numS = max(numPositive, numNegative);
%         %personID_indexA = NaN*ones(length(personsIDs), numS);
%         %personID_indexB = personID_indexA;
%         
%         for i=1:length(personsIDs)
%             for j=1:length(personsIDs)
%                 
%                 if i==j
%                     samples.ID = [samples.ID; repmat([i j], numPositive, 1)];
%                     samples.index = [samples.index; allcomb(idx1_pos{i}, idx2_pos{j})];
%                 else
%                     samples.ID = [samples.ID; repmat([i j], numNegative, 1)];
%                     samples.index = [samples.index; allcomb(idx1_neg{i}, idx2_neg{j})];
%                 end
%                 
% %                 idx1 = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==personsIDs(i));
% %                 idx2 = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==personsIDs(j));
% %                 if ~isempty(idx1) && ~isempty(idx2)
% %                     combinations = allcomb(idx1, idx2);
% % 
% %                     if (isinf(numPositive) && isinf(numNegative))
% %                         numSamples = size(combinations,1);
% %                     else
% %                         numSamples = numNegative;
% %                         if i==j
% %                             numSamples = numPositive;
% %                         end
% %                     end
% %                     
% %                     if useSameImageIndexForPositiveAndNegativeSamples
% %                         
% %                         if all(isnan(personID_indexA(i,:)))
% %                             if numS > length(idx1)
% %                                 personID_indexA(i,1:length(idx1)) = idx1;
% %                             else
% %                                 personID_indexA(i,:) = idx1(randperm(length(idx1),numS));
% %                             end
% %                         end
% %                         if all(isnan(personID_indexB(j,:)))
% %                             if numS > length(idx2)
% %                                 personID_indexB(j,1:length(idx2)) = idx2;
% %                             else
% %                                 personID_indexB(j,:) = idx2(randperm(length(idx2),numS));
% %                             end
% %                         end
% %                         
% %                         pidxA = personID_indexA(i,1:numSamples);
% %                         pidxB = personID_indexB(j,1:numSamples);
% %                         
% %                         pidxA = pidxA(~isnan(pidxA));
% %                         pidxB = pidxB(~isnan(pidxB));
% %                         
% %                         combinations = allcomb(pidxA, pidxB);
% %                         
% %                         samples.ID = [samples.ID; [repmat(personsIDs(i), size(combinations,1), 1) dataset.personID(combinations(:,2))']];
% %                         samples.index = [samples.index; combinations];
% %                     else
% %                                         
% %                         combinations = combinations(randperm(size(combinations, 1)),:);
% %                         if numSamples > size(combinations, 1)
% %                             numSamples = size(combinations, 1);
% %                         end
% % 
% %                         samples.ID = [samples.ID; [repmat(personsIDs(i), numSamples, 1) dataset.personID(combinations(1:numSamples,2))']];
% %                         samples.index = [samples.index; combinations(1:numSamples,:)];
% %                     end
% % 
% %                 end
%             end
%         end
%     end
else
    for i=1:length(personsIDs)
        idx = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==personsIDs(i));
        idxPos = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==personsIDs(i));
        idxNeg = dataset.imageIndex(dataset.cam==cameraPair(2) & ismember(dataset.personID, personsIDs(personsIDs~=personsIDs(i))));
        
        % No images of this person in camera 1
        if isempty(idx)
            continue;
        end

        % Positive combinations
        if ~isempty(idxPos)
            samples.ID = [samples.ID; repmat([personsIDs(i) personsIDs(i)], numPositive, 1)];
            combinations = allcomb(idx, idxPos);
            combinations = combinations(randperm(size(combinations, 1)),:);
            if numPositive > size(combinations,1)
                numPositive = size(combinations,1);
            end
            samples.index = [samples.index; combinations(1:numPositive,:)];
            %samples.label = [samples.label; ones(numPositive,1)];
        end
        
        % Negative combinations
        if ~isempty(idxNeg)
            combinations = allcomb(idx, idxNeg);
            combinations = combinations(randperm(size(combinations, 1)),:);
            if numNegative>length(combinations)
                numNegative = length(combinations);
            end
            samples.index = [samples.index; combinations(1:numNegative,:)];
            samples.ID = [samples.ID; [repmat(personsIDs(i), numNegative, 1) dataset.personID(combinations(1:numNegative,2))']];
            %samples.label = [samples.label; zeros(numNegative,1)];
        end
    end
end
if ~isempty(samples.ID)
    samples.label = samples.ID(:,1) == samples.ID(:,2);
end
end



function [samplesTrain, samplesTest] = getOverlappingSamples(dataset, personsIDsTrain, personsIDsTest, ...
                cameraPair, numSamplesTrain, numSamplesTest, useSameImageIndexForPositiveAndNegativeSamples)
samplesTrain.ID = [];
samplesTrain.index = [];
samplesTrain.label = [];
samplesTest.ID = [];
samplesTest.index = [];
samplesTest.label = [];
allPersonIDs = unique([personsIDsTrain personsIDsTest]);
if (numSamplesTrain(1) < 0 && numSamplesTest(1) < 0)
    numSamplesTrain = abs(numSamplesTrain);
    numSamplesTest = abs(numSamplesTest);
    
    idx1_tr = cell(length(allPersonIDs), 1);
    idx2_tr = cell(length(allPersonIDs), 1);
    idx1_te = cell(length(allPersonIDs), 1);
    idx2_te = cell(length(allPersonIDs), 1);
    for i=1:length(allPersonIDs)
        tmp = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==allPersonIDs(i));
        tmp = tmp(randperm(length(tmp)));
        idx1_tr{i} = tmp(1:numSamplesTrain(1));
        idx1_te{i} = tmp(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1));
        
        tmp = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==allPersonIDs(i));
        tmp = tmp(randperm(length(tmp)));
        idx2_tr{i} = tmp(1:numSamplesTrain(1));
        idx2_te{i} = tmp(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1));
    end
    
    for i=1:length(allPersonIDs)
        for j=1:length(allPersonIDs)
            
            % Training set
            if all(ismember([allPersonIDs(i) allPersonIDs(j)], personsIDsTrain))
                combinations = allcomb(idx1_tr{i}, idx2_tr{j});
                samplesTrain.ID = [samplesTrain.ID; repmat([allPersonIDs(i) allPersonIDs(j)], size(combinations, 1), 1)];
                samplesTrain.index = [samplesTrain.index; combinations];
                if i==j
                    samplesTrain.label = [samplesTrain.label; ones(size(combinations,1),1)];
                else
                    samplesTrain.label = [samplesTrain.label; zeros(size(combinations,1),1)];
                end
            end
            
            % Test set
            if all(ismember([allPersonIDs(i) allPersonIDs(j)], personsIDsTest))
                combinations = allcomb(idx1_te{i}, idx2_te{j});
                samplesTest.ID = [samplesTest.ID; repmat([allPersonIDs(i) allPersonIDs(j)], size(combinations, 1), 1)];
                samplesTest.index = [samplesTest.index; combinations];
                if i==j
                    samplesTest.label = [samplesTest.label; ones(size(combinations,1),1)];
                else
                    samplesTest.label = [samplesTest.label; zeros(size(combinations,1),1)];
                end
            end
        end
    end
    
%     
%     % Loop for all persons (in both the training and test set)
%     for i=1:length(allPersonIDs)
%         idx1 = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==allPersonIDs(i));
%         for j=1:length(allPersonIDs)
%             idx2 = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==allPersonIDs(j));
%             combinations = allcomb(idx1, idx2);
%             combinations = combinations(randperm(size(combinations, 1)),:);
%             
%             % Training and testing samples
%             % First value is for training, second for testing
%             % Negative association
%             numSamplesTmp(1) = numSamplesTrain(2);
%             numSamplesTmp(2) = numSamplesTest(2);
%             if i==j
%                 % Positive association
%                 numSamplesTmp(1) = numSamplesTrain(1);
%                 numSamplesTmp(2) = numSamplesTest(1);
%             end
% 
%             % Check that the selected number of training/test samples is
%             % not exceeding the total number of possible combinations
%             if numSamplesTmp(1) + numSamplesTmp(2) > size(combinations, 1)
%                 numSamplesTmp(2) = size(combinations, 1) - numSamplesTmp(1);
%             end
%             
%             
%             % Persons are in the training set
%             if all(ismember([allPersonIDs(i) allPersonIDs(j)], personsIDsTrain))
%                 samplesTrain.ID = [samplesTrain.ID; repmat([allPersonIDs(i) allPersonIDs(j)], numSamplesTmp(1), 1)];
%                 samplesTrain.index = [samplesTrain.index; combinations(1:numSamplesTmp(1),:)];
%                 if i==j
%                     samplesTrain.label = [samplesTrain.label; ones(numSamplesTmp(1),1)];
%                 else
%                     samplesTrain.label = [samplesTrain.label; zeros(numSamplesTmp(1),1)];
%                 end
%             else
%                 numSamplesTmp(1) = 0;
%             end
% 
%             % Persons are in the test set
%             if all(ismember([allPersonIDs(i) allPersonIDs(j)], personsIDsTest))
%                 samplesTest.ID = [samplesTest.ID; repmat([allPersonIDs(i) allPersonIDs(j)], numSamplesTmp(2), 1)];
%                 samplesTest.index = [samplesTest.index; combinations(numSamplesTmp(1)+1:numSamplesTmp(1)+numSamplesTmp(2),:)];
%                 if i==j
%                     samplesTest.label = [samplesTest.label; ones(numSamplesTmp(2),1)];
%                 else
%                     samplesTest.label = [samplesTest.label; zeros(numSamplesTmp(2),1)];
%                 end
%             end
%            
%         end
%     end
elseif (numSamplesTrain(1) > 0 && numSamplesTest(1) < 0)
    numSamplesTrain = abs(numSamplesTrain);
    numSamplesTest = abs(numSamplesTest);
    %personID_index = [];
    
    idx1_tr = cell(length(allPersonIDs), 1);
    idx2_tr = cell(length(allPersonIDs), 1);
    idx1_te = cell(length(allPersonIDs), 1);
    idx2_te = cell(length(allPersonIDs), 1);
    for i=1:length(allPersonIDs)
        tmp = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==allPersonIDs(i));
        tmp = tmp(randperm(length(tmp)));
        idx1_tr{i} = tmp(1:numSamplesTrain(1));
        idx1_te{i} = tmp(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1));
        
        tmp = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==allPersonIDs(i));
        tmp = tmp(randperm(length(tmp)));
        idx2_tr{i} = tmp(1:numSamplesTrain(1));
        idx2_te{i} = tmp(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1));
    end
    
     for i=1:length(allPersonIDs)
        
        % Positivive training set samples
        if ismember(allPersonIDs(i), personsIDsTrain)
            combinations = allcomb(idx1_tr{i}, idx2_tr{i});
            combinations(numSamplesTrain(1)+1:end,:) = [];
            samplesTrain.ID = [samplesTrain.ID; repmat([allPersonIDs(i) allPersonIDs(i)], size(combinations, 1), 1)];
            samplesTrain.index = [samplesTrain.index; combinations];
            samplesTrain.label = [samplesTrain.label; ones(size(combinations,1),1)];
        end

        jjs = randperm(length(allPersonIDs));
        randAllPersonIDs = allPersonIDs(jjs);
        numAddedNegativeTrainingSamples = 0;
        for j=1:length(allPersonIDs)
            
            %Negative Training set
            if allPersonIDs(i) ~= randAllPersonIDs(j) && numAddedNegativeTrainingSamples < numSamplesTrain(2) && all(ismember([allPersonIDs(i) randAllPersonIDs(j)], personsIDsTrain))
                jj = jjs(j);
                combinations = allcomb(idx1_tr{i}, idx2_tr{jj});
                combinations(2:end,:) = [];
                samplesTrain.ID = [samplesTrain.ID; repmat([allPersonIDs(i) randAllPersonIDs(j)], size(combinations, 1), 1)];
                samplesTrain.index = [samplesTrain.index; combinations];
                samplesTrain.label = [samplesTrain.label; zeros(size(combinations,1),1)];
                numAddedNegativeTrainingSamples = numAddedNegativeTrainingSamples + 1;
            end
            
            %Positive and Negative Test set
            if all(ismember([allPersonIDs(i) allPersonIDs(j)], personsIDsTest))
                combinations = allcomb(idx1_te{i}, idx2_te{j});
                samplesTest.ID = [samplesTest.ID; repmat([allPersonIDs(i) allPersonIDs(j)], size(combinations, 1), 1)];
                samplesTest.index = [samplesTest.index; combinations];
                if i==j
                    samplesTest.label = [samplesTest.label; ones(size(combinations,1),1)];
                else
                    samplesTest.label = [samplesTest.label; zeros(size(combinations,1),1)];
                end
            end
        end
    end
    
%     for i=1:length(allPersonIDs)
%         idx = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==allPersonIDs(i));
%         idxPos = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==allPersonIDs(i));
% 
%         % Positive combinations
%         if any(ismember(personsIDsTrain, allPersonIDs(i)))
%             samplesTrain.ID = [samplesTrain.ID; repmat([allPersonIDs(i) allPersonIDs(i)], numSamplesTrain(1), 1)];
%         end
%         if any(ismember(personsIDsTest, allPersonIDs(i)))
%             samplesTest.ID = [samplesTest.ID; repmat([allPersonIDs(i) allPersonIDs(i)], numSamplesTest(1), 1)];
%         end
%         combinations = allcomb(idx, idxPos);
%         if size(combinations,1) < numSamplesTrain(1)+numSamplesTest(1)
%             while size(combinations,1) <= numSamplesTrain(1) + numSamplesTest(1)
%                 combinations = repmat(combinations,2,1);
%             end
%         end
%         combinations = combinations(randperm(size(combinations, 1)),:);
%         
%         if ~useSameImageIndexForPositiveAndNegativeSamples
%             % Chose positive combinations for training
%             if any(ismember(personsIDsTrain, allPersonIDs(i)))
%                 samplesTrain.index = [samplesTrain.index; combinations(1:numSamplesTrain(1),:)];
%                 samplesTrain.label = [samplesTrain.label; ones(numSamplesTrain(1),1)];
%             end
%             % Chose positive combinations for testing
%             if any(ismember(personsIDsTest, allPersonIDs(i)))
%                 samplesTest.index = [samplesTest.index; combinations(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1),:)];
%                 samplesTest.label = [samplesTest.label; ones(numSamplesTest(1),1)];
%             end
%         else
%             error('TODO');
%             numF = max(numSamplesTrain(1), numSamplesTest(1));
%             personID_index(i,:) = [idx(randperm(length(idx),numF)) idxPos(randperm(length(idxPos),numF))];
%             
%             combinations = allcomb(personID_index(i,1:numSamplesTrain(1)), personID_index(i,numF+1:numF+numSamplesTrain(1)));
%             
%              % Chose positive combinations for training
%             if any(ismember(personsIDsTrain, allPersonIDs(i)))
%                 samplesTrain.index = [samplesTrain.index; combinations(1:numSamplesTrain(1),:)];
%                 samplesTrain.label = [samplesTrain.label; ones(numSamplesTrain(1),1)];
%             end
%             % Chose positive combinations for testing
%             if any(ismember(personsIDsTest, allPersonIDs(i)))
%                 samplesTest.index = [samplesTest.index; combinations(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1),:)];
%                 samplesTest.label = [samplesTest.label; ones(numSamplesTest(1),1)];
%             end
%         end
% 		
%         
%         % Chose negative combinations for both training and testing
%         % If the number of distinct negative persons is, somehow, less than the
% 		% total number of negative examples required for training, then just replicate
% 		% the matrix of person ids for negative people for this ith person. Remember
% 		% that numSamplesTrain(2) is positive in the initparameters for the code to
% 		% come here
%         negPersonIDs = setdiff(personsIDsTrain,allPersonIDs(i));
%         while numSamplesTrain(2) > length(negPersonIDs)
%             negPersonIDs = repmat(negPersonIDs,2,1);
%         end
%         negPersonIDs = negPersonIDs(:,randperm(length(negPersonIDs)));
%         % Initialize the count for the number of negative examples already
%         % assigned for this ith person to the training set
%         iNegTrainCount = 0;
%         for j=1:length(negPersonIDs)
%             idxNeg = dataset.imageIndex(dataset.cam==cameraPair(2) & ismember(dataset.personID, allPersonIDs(allPersonIDs==negPersonIDs(j))));
%             combinations = allcomb(idx, idxNeg);
%             combinations = combinations(randperm(size(combinations, 1)),:);
%             % Assuming numSamplesTrain(2) > 0 and numSamplesTrain(2) is not
%             % greater than the total number of negative combinations
%             % possible taking 1 from each j loop
%             % Choose negative combinations for training untill the count (= numSamplesTrain(2))
% 			% is reached
%             if iNegTrainCount < numSamplesTrain(2)
%                 samplesTrain.index = [samplesTrain.index; combinations(1,:)];
%                 samplesTrain.ID = [samplesTrain.ID; allPersonIDs(i) negPersonIDs(j)];
%                 samplesTrain.label = [samplesTrain.label; 0];
%                 iNegTrainCount = iNegTrainCount + 1;
%             end
%                 
%             numNegSamples = numSamplesTest(2);
%             if size(combinations,1) < (numNegSamples + 1)
%                 numNegSamples = size(combinations,1) - 1;
%             end
%                 
% 			% Choose negative combinations for testing
% 			samplesTest.ID = [samplesTest.ID; repmat([allPersonIDs(i) negPersonIDs(j)], numNegSamples, 1)];
% 			% Starting from the second row of all combinations. If this
% 			% particular jth person was indeed chosen as negative
% 			% example for training data then that was done as the first row
% 			% of all combinations. There is no way that second row and
% 			% onwards were chosen as negative training example
% 			samplesTest.index = [samplesTest.index; combinations(2:numNegSamples+1,:)];
% 			samplesTest.label = [samplesTest.label; zeros(numNegSamples,1)];
%         end
%         
%     end
else
    numSamplesTrain = abs(numSamplesTrain);
    numSamplesTest = abs(numSamplesTest);
    for i=1:length(allPersonIDs)
        idx = dataset.imageIndex(dataset.cam==cameraPair(1) & dataset.personID==allPersonIDs(i));
        idxPos = dataset.imageIndex(dataset.cam==cameraPair(2) & dataset.personID==allPersonIDs(i));
        idxNeg = dataset.imageIndex(dataset.cam==cameraPair(2) & ismember(dataset.personID, allPersonIDs(allPersonIDs~=allPersonIDs(i))));

        % Positive combinations
        if ismember(allPersonIDs(i), personsIDsTrain)
            samplesTrain.ID = [samplesTrain.ID; repmat([allPersonIDs(i) allPersonIDs(i)], numSamplesTrain(1), 1)];
        end
        if ismember(allPersonIDs(i), personsIDsTest)
            samplesTest.ID = [samplesTest.ID; repmat([allPersonIDs(i) allPersonIDs(i)], numSamplesTest(1), 1)];
        end
        combinations = allcomb(idx, idxPos);
        combinations = combinations(randperm(size(combinations, 1)),:);
        
        % Chose combinations for training and testing
        if ismember(allPersonIDs(i), personsIDsTrain)
            samplesTrain.index = [samplesTrain.index; combinations(1:numSamplesTrain(1),:)];
            samplesTrain.label = [samplesTrain.label; ones(numSamplesTrain(1),1)];
        end
        if ismember(allPersonIDs(i), personsIDsTest)
            samplesTest.index = [samplesTest.index; combinations(numSamplesTrain(1)+1:numSamplesTrain(1)+numSamplesTest(1),:)];
            samplesTest.label = [samplesTest.label; ones(numSamplesTest(1),1)];
        end
        
        % Negative combinations
        combinations = allcomb(idx, idxNeg);
        combinations = combinations(randperm(size(combinations, 1)),:);
        %if numNegative>length(combinations)
        %    numNegative = length(combinations);
        %end

        % Chose combinations for training and testing
        if ismember(allPersonIDs(i), personsIDsTrain)
            samplesTrain.index = [samplesTrain.index; combinations(1:numSamplesTrain(2),:)];
            samplesTrain.ID = [samplesTrain.ID; [repmat(allPersonIDs(i), numSamplesTrain(2), 1) dataset.personID(combinations(1:numSamplesTrain(2),2))']];
            samplesTrain.label = [samplesTrain.label; zeros(numSamplesTrain(2),1)];
        end
        if ismember(allPersonIDs(i), personsIDsTest)
            samplesTest.index = [samplesTest.index; combinations(numSamplesTrain(2)+1:numSamplesTrain(2)+numSamplesTest(2),:)];
            samplesTest.ID = [samplesTest.ID; [repmat(allPersonIDs(i), numSamplesTest(2), 1) dataset.personID(combinations(numSamplesTrain(2)+1:numSamplesTrain(2)+numSamplesTest(2),2))']];
            samplesTest.label = [samplesTest.label; zeros(numSamplesTest(2),1)];
        end
    end
end

% Ensure labels are logical values
samplesTrain.label = logical(samplesTrain.label);
samplesTest.label = logical(samplesTest.label);

end