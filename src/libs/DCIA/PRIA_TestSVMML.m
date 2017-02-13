function [rKCCA, testSplit] = PRIA_TestSVMML(dataset, trainDia, testDia, pars)

type = 1;
for ncp = 1:size(testDia,1)
   for nt = 1:size(testDia,2)     
       for i = 1:size(testDia,3)
           if ~isempty(testDia(ncp,nt,i).Idx)
               if length(testDia(ncp,nt,i).Idx) > 2
                   type = 2;
               end
               featDim = length(testDia(ncp,nt,i).vec(:,1));
           end
       end
   end
end

for ncp = 1:size(testDia,1)
   for nt = 1:size(testDia,2)
       if type == 1
           trainIdx = ones(size(trainDia,3),2).*NaN;
           testIdx = ones(size(testDia,3),2).*NaN;
           features = zeros(featDim,size(trainDia,3)*2+size(testDia,3)*2);
           for i = 1:size(trainDia,3)
               if ~isempty(trainDia(ncp,nt,i).Idx)
                   trainIdx(i,1) = trainDia(ncp,nt,i).Idx(1); 
                   trainIdx(i,2) = trainDia(ncp,nt,i).Idx(2);
                   features(:,trainIdx(i,1)) = trainDia(ncp,nt,i).vec(:,1);
                   features(:,trainIdx(i,2)) = trainDia(ncp,nt,i).vec(:,2);
               end
           end
           for i = 1:size(testDia,3)
               if ~isempty(testDia(ncp,nt,i).Idx)
                   testIdx(i,1) = testDia(ncp,nt,i).Idx(1);
                   testIdx(i,2) = testDia(ncp,nt,i).Idx(2);
                   features(:,testIdx(i,1)) = testDia(ncp,nt,i).vec(:,1);
                   features(:,testIdx(i,2)) = testDia(ncp,nt,i).vec(:,2);
               end
           end

           trainIdx(:,1) = sort(trainIdx(:,1),'ascend');
           trainIdx(:,2) = sort(trainIdx(:,2),'ascend');
           testIdx(:,1) = sort(testIdx(:,1),'ascend');
           testIdx(:,2) = sort(testIdx(:,2),'ascend');

           if min(features(:)) < 0
               features = features + abs(min(features(:)));
           end

           testSplit(ncp).trial(nt).trainIdx = trainIdx;
           testSplit(ncp).trial(nt).testIdx = testIdx; 
           
           
           load(strcat(pars.results.folder,'modelParam.mat'));
           
           modelParam.nTrial = 1;
           modelParam.allFeatures = features;%featuresPreProcessing(modelParam.AlgoOption, features');
           clear features
           
           clear split
           n = 1;
           for i = 1:size(trainIdx,1)
               if ~isnan(trainIdx(i,1)) && ~isnan(trainIdx(i,1))
                   split.train2.index(n,1) = trainIdx(i,1);
                   split.train2.index(n+1,1) = trainIdx(i,1);
                   
                   split.train2.index(n,2) = trainIdx(i,2);
                   aux1 = trainIdx(~isnan(trainIdx(:,2)),2);
                   aux1 = aux1(aux1 ~= trainIdx(i,2));
                   num = randi(length(aux1)-1)+1;
                   split.train2.index(n+1,2) = aux1(num);
                   
                   split.train2.label(n,1) = true;
                   split.train2.label(n+1,1) = false;
                   
                   n = n +2;
               end
           end
           split.train2.ID(:,1) = dataset.personID(split.train2.index(:,1));
           split.train2.ID(:,2) = dataset.personID(split.train2.index(:,2));
           
           testIdx1 = testIdx(~isnan(testIdx(:,1)),1);
           testIdx2 = testIdx(~isnan(testIdx(:,2)),2);
           for i = 1:length(testIdx1)
               in = (i-1)*length(testIdx1)+1;
               fn = i*length(testIdx1);
               split.test2.index(in:fn,1) = repmat(testIdx1(i),length(testIdx1),1);
               split.test2.index(in:fn,2) = testIdx2(randperm(length(testIdx2)));
           end
           split.test2.ID(:,1) = dataset.personID(split.test2.index(:,1));
           split.test2.ID(:,2) = dataset.personID(split.test2.index(:,2));
           split.test2.label = false(size(split.test2.index,1),1);
           for i = 1:length(testIdx1):length(split.test2.label)
               auxIDs = split.test2.ID(i:i-1+length(testIdx1),2);
               auxID = split.test2.ID(i,1);
               split.test2.label(auxIDs==auxID) = true;
           end
           
           [algo] = modelTrain(modelParam, split);


           [KCCA] = modelTest(modelParam, split, algo, false);
           
           rKCCA(ncp).trial(nt).rKCCA.dist = KCCA.trial(1).rKCCA.dist;
           rKCCA(ncp).trial(nt).rKCCA.pos = KCCA.trial(1).rKCCA.pos;
           clear KCCA
                             
       elseif type == 2
           trainIdx = ones(size(trainDia,3),2).*NaN;
           tfeatures = zeros(length(trainDia(ncp,nt,1).vec(:,1)),size(trainDia,3)*2+size(testDia,3)*2);
           for i = 1:size(trainDia,3)
               if ~isempty(trainDia(ncp,nt,i).Idx)
                   trainIdx(i,1) = trainDia(ncp,nt,i).Idx(1); 
                   trainIdx(i,2) = trainDia(ncp,nt,i).Idx(2);
                   tfeatures(:,trainIdx(i,1)) = trainDia(ncp,nt,i).vec(:,1);
                   tfeatures(:,trainIdx(i,2)) = trainDia(ncp,nt,i).vec(:,2);
               end
           end
           trainIdx(:,1) = sort(trainIdx(:,1),'ascend');
           trainIdx(:,2) = sort(trainIdx(:,2),'ascend');
           
           load(strcat(pars.results.folder,'modelParam.mat'));
           
           n = 1;
           for i = 1:size(trainIdx,1)
               if ~isnan(trainIdx(i,1)) && ~isnan(trainIdx(i,1))
                   split.train2.index(n,1) = trainIdx(i,1);
                   split.train2.index(n+1,1) = trainIdx(i,1);
                   
                   split.train2.index(n,2) = trainIdx(i,2);
                   aux1 = trainIdx(~isnan(trainIdx(:,2)),2);
                   aux1 = aux1(aux1 ~= trainIdx(i,2));
                   num = randi(length(aux1)-1)+1;
                   split.train2.index(n+1,2) = aux1(num);
                   
                   split.train2.label(n,1) = true;
                   split.train2.label(n+1,1) = false;
                   
                   n = n +2;
               end
           end
           split.train2.ID(:,1) = dataset.personID(split.train2.index(:,1));
           split.train2.ID(:,2) = dataset.personID(split.train2.index(:,2));
           
           [algo] = modelTrain(modelParam, split);
           
           for i = 1:size(testDia,3)
               if ~isempty(testDia(ncp,nt,i).Idx)
                   testIdx = ones(length(testDia(ncp,nt,i).Idx)-1,2).*NaN;
                   testIdx(1,1) = testDia(ncp,nt,i).Idx(1);
                   features = tfeatures;
                   features(:,testIdx(1,1)) = testDia(ncp,nt,i).vec(:,1);
                   for j = 1:length(testDia(ncp,nt,i).Idx)-1
                       testIdx(j,2) = testDia(ncp,nt,i).Idx(j+1);
                       features(:,testIdx(j,2)) = testDia(ncp,nt,i).vec(:,j+1);
                   end
                   testIdx(:,1) = sort(testIdx(:,1),'ascend');
                   testIdx(:,2) = sort(testIdx(:,2),'ascend');
                   
                   if min(features(:)) < 0
                       features = features + abs(min(features(:)));
                   end
                   
                   modelParam.allFeatures = features;%featuresPreProcessing(modelParam.AlgoOption, features');
                   clear features

                   testSplit(ncp).trial(nt).trainIdx{i} = trainIdx;
                   testSplit(ncp).trial(nt).testIdx{i} = testIdx;
                   
                   
                   testIdx1 = testIdx(~isnan(testIdx(:,1)),1);
                   testIdx2 = testIdx(~isnan(testIdx(:,2)),2);
                   
                   in = 1;
                   fn = length(testIdx1);
                   split.test2.index(in:fn,1) = repmat(testIdx(i,1),length(testIdx1),1);
                   split.test2.index(in:fn,2) = testIdx2(randperm(length(testIdx2)));

                       
                   split.test2.ID(:,1) = dataset.personID(split.test2.index(:,1));
                   split.test2.ID(:,2) = dataset.personID(split.test2.index(:,2));
                   split.test2.label = false(size(split.test2.index,1),1);
                   
                   auxIDs = split.test2.ID(:,2);
                   auxID = split.test2.ID(1,1);
                   split.test2.label(auxIDs==auxID) = true;

                   [algo] = modelTrain(modelParam, split);


                   [rrKCCA] = modelTest(modelParam, split, algo, false);
                   
                   rKCCA(ncp).trial(nt).rKCCA.dist{i} = rrKCCA(ncp).trial(nt).rKCCA.dist;
                   rKCCA(ncp).trial(nt).rKCCA.pos{i} = rrKCCA(ncp).trial(nt).rKCCA.pos;
                 
               end
           end
       end
   end
end
