function [AlgoOption] = init_algo_option(methodName, datasetName, nTrial)

% The number of test times with the same train/test partition.
% In each test, the gallery and prob set partion is randomly divided.
num_itr = nTrial; 
np_ratio =10; % The ratio of number of negative and positive pairs. Used in PCCA
% default algorithm option setting

AlgoOption.name = methodName;
AlgoOption.func = methodName; % note 'rPCCA' use PCCA function also.
AlgoOption.npratio = np_ratio; % negative to positive pair ratio
AlgoOption.beta =3;  % different algorithm have different meaning, refer to PCCA and LFDA paper.
AlgoOption.d = 40; % projection dimension
AlgoOption.epsilon =1e-4;
AlgoOption.lambda =0;
AlgoOption.w = [];
AlgoOption.dataname = datasetName;
AlgoOption.num_itr=num_itr;
AlgoOption.kernel = 'linear';
AlgoOption.doPCA = 0;
% customize in different case
switch  methodName
    case {'LFDA'}
        AlgoOption.npratio =0; % npratio is not required.
        AlgoOption.beta =0.01;
        AlgoOption.d =40;
        AlgoOption.LocalScalingNeighbor =6; % local scaling affinity matrix parameter.
        AlgoOption.num_itr= 10;
    case {'oLFDA'}
        AlgoOption.npratio =0; % npratio is not required.
        AlgoOption.beta =0.15; % regularization parameter
        AlgoOption.d = 40;
        AlgoOption.LocalScalingNeighbor =6; % local scaling affinity matrix parameter.
        AlgoOption.num_itr= 10;
    case {'PCCA'}
        AlgoOption.lambda = 0;
        AlgoOption.maxIter = 2000;
    case {'rPCCA'}
        AlgoOption.func = 'PCCA';
        AlgoOption.lambda =0.01;
        AlgoOption.maxIter = 2000;
    case {'svmml'}
        AlgoOption.p = []; % learn full rank projection matrix
        AlgoOption.lambda1 = 1e-8;
        AlgoOption.lambda2 = 1e-6;
        AlgoOption.maxit = 300;
        AlgoOption.verbose = 0;
        AlgoOption.doPCA = 1;
        AlgoOption.PCAdim = [];
    case {'MFA'}
        AlgoOption.Nw = 0; % 0--use all within class samples
        AlgoOption.Nb = 12;
        AlgoOption.d = 30;
        AlgoOption.beta = 0.01;
%     case {'PRDC'} % To be added in the future
%         AlgoOption.Maxloop = 100;
%         AlgoOption.Dimension = 1000;
%         AlgoOption.npratio = 0;
    case {'KISSME'}
        AlgoOption.PCAdim = 34;
        AlgoOption.npratio = 10;
        AlgoOption.nFold = 10;
        AlgoOption.doPCA = 1;
end
end