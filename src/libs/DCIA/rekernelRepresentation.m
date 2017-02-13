function [kernelTestA, kernelTestB] = rekernelRepresentation(dataTestA, dataTestB, dataTrainA, dataTrainB, meanA, meanB)


[kernelTestA, ~] = kernel_expchi2(dataTestA,dataTrainA,meanA);

[kernelTestB, ~] = kernel_expchi2(dataTestB,dataTrainB,meanB);