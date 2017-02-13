function [algo] = modelTrain(modelParam, split)

AlgoOption = modelParam.AlgoOption;
allFeatures = modelParam.allFeatures;
nTrial = modelParam.nTrial;

train = split.train2;

for nt=1:nTrial
   
   % Get train and test partitions
   y = train(nt).label;
   
   % We have to change a bit of the indexing to run the following code
   [trainFeatures, train_ids_new, train_idx_pair, ~, ~] = get_train_test_data(allFeatures, train(nt), []);
            
   %% TRAIN
   switch AlgoOption.func
        case {'svmml'}
            [algo] = svmml_learn_full_final(trainFeatures',train_ids_new,AlgoOption);
        case {'KISSME'}                        
            [algo] = kissme(trainFeatures,train_idx_pair,y,AlgoOption);
   end
end