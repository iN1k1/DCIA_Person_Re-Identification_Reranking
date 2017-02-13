function [modelParam, split] = modelConfig(dataset, features, split, pars)

%% INIT SETTINGS
methodName = pars.model; 
nTrial = size(split.test,2);
dataset.imageIndex = dataset.index;
AlgoOption = init_algo_option(methodName, dataset.name, nTrial);

%% LOAD DATA
testIDs = [];
if strcmp('PRID',dataset.name)
   maxNumTemplate = 1;
   
   id_personsInAandB = 1:200;
   id_personsOnlyInA = 201:385;
   id_personsOnlyInB = 386:934;
   
   % Number of persons in both cameras used for test + number of persons
   % that are only in cam B
   num_gallery = 100 + numel(id_personsOnlyInB);
   testSetSize = 649;
   
   % Here we have to exclude persons that are only in camera A
   totalPersons = numel([id_personsInAandB id_personsOnlyInB]);
   
   % Here we define a matrix containing the train/test IDs used for the
   % different trials
   testIDs = zeros(totalPersons, nTrial);
   for t=1:nTrial
        perm = id_personsInAandB(randperm(length(id_personsInAandB)));
        testIDs(:, t) = [perm id_personsOnlyInB]';
   end
else
   maxNumTemplate = 1;
   num_gallery = round(pars.split.persons2test*dataset.peopleCount);
   testSetSize = round(pars.split.persons2test*dataset.peopleCount);
   totalPersons = dataset.peopleCount;
    
end

%% GET TRAIN/TEST SPLITS
for j = 1:nTrial
    % Train
    n = 1;
    for i = 1:length(split.train(j).ID)
        split.train2(j).index(n,1) = split.train(j).index(i,1);
        split.train2(j).index(n+1,1) = split.train(j).index(i,1);

        split.train2(j).index(n,2) = split.train(j).index(i,2);
        aux1 = split.train(j).index(:,2);
        aux1 = aux1(aux1 ~= split.train(j).index(i,2));
        num = randi(length(aux1)-1)+1;
        split.train2(j).index(n+1,2) = aux1(num);

        split.train2(j).label(n,1) = true;
        split.train2(j).label(n+1,1) = false;

        n = n +2;
    end
    split.train2(j).ID(:,1) = dataset.personID(split.train2(j).index(:,1));
    split.train2(j).ID(:,2) = dataset.personID(split.train2(j).index(:,2));
    
    % Test
    order = randperm(length(split.test(j).ID));
    for i = 1:length(split.test(j).ID)
       if ~isnan(split.test(j).index(i,1))
           in = (i-1)*length(split.test(j).ID)+1;
           fn = i*length(split.test(j).ID);
           split.test2(j).index(in:fn,1) = repmat(split.test(j).index(i,1),length(split.test(j).ID),1);
           split.test2(j).index(in:fn,2) = split.test(j).index(order,2);
       end
    end
    split.test2(j).ID(:,1) = dataset.personID(split.test2(j).index(:,1));
    split.test2(j).ID(:,2) = dataset.personID(split.test2(j).index(:,2));
    
    split.test2(j).label = false(size(split.test2(j).index,1),1);
    for i = 1:length(split.test(j).ID):length(split.test2(j).label)
       auxLabel = split.test2(j).label(i:i-1+length(split.test(j).ID));
       auxIDs = split.test2(j).ID(i:i-1+length(split.test(j).ID),2);
       auxID = split.test2(j).ID(i,1);
       auxLabel(auxIDs==auxID) = true;
       split.test2(j).label(i:i-1+length(split.test(j).ID)) = auxLabel;
    end
    
    % Test 2
    order = randperm(length(split.train(j).ID));
    for i = 1:length(split.train(j).ID)
       in = (i-1)*length(split.train(j).ID)+1;
       fn = i*length(split.train(j).ID);
       split.test22(j).index(in:fn,1) = repmat(split.train(j).index(i,1),length(split.train(j).ID),1);
       split.test22(j).index(in:fn,2) = split.train(j).index(order,2);
    end
    split.test22(j).ID(:,1) = dataset.personID(split.test22(j).index(:,1));
    split.test22(j).ID(:,2) = dataset.personID(split.test22(j).index(:,2));
    
    split.test22(j).label = false(size(split.test22(j).index,1),1);
    for i = 1:length(split.train(j).ID):length(split.test22(j).label)
       auxLabel = split.test22(j).label(i:i-1+length(split.train(j).ID));
       auxIDs = split.test22(j).ID(i:i-1+length(split.train(j).ID),2);
       auxID = split.test22(j).ID(i,1);
       auxLabel(auxIDs==auxID) = true;
       split.test22(j).label(i:i-1+length(split.train(j).ID)) = auxLabel;
    end
end



%% COMPUTE FEATURES
allFeatures = double(features.data');

%% FEATURES PRE-PROCESSING
[allFeatures] = featuresPreProcessing(AlgoOption, allFeatures);

modelParam.nTrial= nTrial;
clear nTrial
modelParam.AlgoOption = AlgoOption;
clear AlgoOption
modelParam.allFeatures = allFeatures;
clear allFeatures
modelParam.num_gallery = num_gallery;
clear numGallery
