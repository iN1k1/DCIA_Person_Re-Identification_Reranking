function [rKCCA, testSplit] = PRIA_TestEuclidean(trainDia, testDia, pars)  

type = 1;
for ncp = 1:size(testDia,1)
   for nt = 1:size(testDia,2)     
       for i = 1:size(testDia,3)
           if ~isempty(testDia(ncp,nt,i).Idx)
               if length(testDia(ncp,nt,i).Idx) > 2
                   type = 2;
               end
           end
       end
   end
end

for ncp = 1:size(testDia,1)
   for nt = 1:size(testDia,2)
       if type == 1
           trainIdx = ones(size(trainDia,3),2).*NaN;
           testIdx = ones(size(testDia,3),2).*NaN;
           for i = 1:size(trainDia,3)
               if ~isempty(trainDia(ncp,nt,i).Idx)
                   featL = length(trainDia(ncp,nt,i).vec(:,1));
                   break;
               end
           end
           features = zeros(featL,size(trainDia,3)*2+size(testDia,3)*2);
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
           
           testP = testIdx(:,1);
           testG = testIdx(:,2);
           
           % Compute the cosine distance
           distMatrix = pdist2(features(testG(~isnan(testG)),:),features(testP(~isnan(testP)),:),'euclidean');

           % Nearest Neighbor (NN) classification
           [rKCCA(ncp).trial(nt).rKCCA.dist, rKCCA(ncp).trial(nt).rKCCA.pos] = sort(distMatrix);
           
           testSplit(ncp).trial(nt).trainIdx = trainIdx;
           testSplit(ncp).trial(nt).testIdx = testIdx;
           
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
                   
                   testP = testIdx(:,1);
                   testG = testIdx(:,2);

                   % Compute the cosine distance
                   distMatrix = pdist2(features(testG(~isnan(testG)),:),features(testP(~isnan(testP)),:),'euclidean');

                   % Nearest Neighbor (NN) classification
                   [rKCCA(ncp).trial(nt).rKCCA.dist{i}, rKCCA(ncp).trial(nt).rKCCA.pos{i}] = sort(distMatrix);

                   testSplit(ncp).trial(nt).trainIdx{i} = trainIdx;
                   testSplit(ncp).trial(nt).testIdx{i} = testIdx;

               end
           end
       end
   end
end