function [kernelTrain, kernelTest, m] = computeKernel(data,testIndex,trainIndex)

%dataTest = data(testIndex,:);
%dataTrain = data(trainIndex,:);
dataTest = data(testIndex(~isnan(testIndex)),:);
dataTrain = data(trainIndex(~isnan(trainIndex)),:);

[kernelTrain, m] = kernel_expchi2(dataTrain,dataTrain);
[kernelTest, ~] = kernel_expchi2(dataTest,dataTrain,m);
  