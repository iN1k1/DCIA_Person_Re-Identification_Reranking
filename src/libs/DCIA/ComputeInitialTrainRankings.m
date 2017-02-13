function [initialTrainResults] = ComputeInitialTrainRankings(features, split, pars, dataset)

if strcmp(pars.model,'KCCA')
    
    %%% KCCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Kernel representaion
    fprintf('Computing kernel representation...');
    t = tic;
    if exist(strcat(pars.results.folder,'trainKernel.mat'),'file')
        load(strcat(pars.results.folder,'trainKernel.mat'));
    else
        kernels = kernelRepresentation(features,split,true);
        save(strcat(pars.results.folder,'trainKernel.mat'),'kernels');
    end
    clear features
    fprintf('done in %.2f(s)\n', toc(t));

    % Matching KCCA
    fprintf('Matchig people using KCCA...');
    t = tic;
    if exist(strcat(pars.results.folder,'trainKCCA.mat'),'file')
        load(strcat(pars.results.folder,'trainKCCA.mat'));
    else
        trainKCCA = computeKCCA(kernels,pars);
        save(strcat(pars.results.folder,'trainKCCA.mat'),'trainKCCA');
    end
    clear kernels
    fprintf('done in %.2f(s)\n', toc(t));
    
    trainBaselineModel = trainKCCA;
    clear trainKCCA

elseif strcmp(pars.model,'KISSME')
    
    %%% KISSME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('Matchig people using KISSME...');
    t = tic;
    if exist(strcat(pars.results.folder,'trainKISSME.mat'),'file')
        load(strcat(pars.results.folder,'trainKISSME.mat'));
    else
        load(strcat(pars.results.folder,'modelParam.mat'));
        load(strcat(pars.results.folder,'trainModel.mat'));
        
        [trainKISSME] = modelTest(modelParam, split, algo, true);
        save(strcat(pars.results.folder,'trainKISSME.mat'),'trainKISSME');
    end
    fprintf('done in %.2f(s)\n', toc(t));

    trainBaselineModel = trainKISSME;
    clear trainKISSME
    
elseif strcmp(pars.model,'svmml')
    
    %%% svmml %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('Matchig people using svmml...');
    t = tic;
    if exist(strcat(pars.results.folder,'trainsvmml.mat'),'file')
        load(strcat(pars.results.folder,'trainsvmml.mat'));
    else
        load(strcat(pars.results.folder,'modelParam.mat'));
        load(strcat(pars.results.folder,'trainModel.mat'));

        [trainsvmml] = modelTest(modelParam, split, algo, true);
        save(strcat(pars.results.folder,'trainsvmml.mat'),'trainsvmml');
    end
    fprintf('done in %.2f(s)\n', toc(t));

    trainBaselineModel = trainsvmml;
    clear trainsvmml
    
elseif strcmp(pars.model,'Euclidean')
    
    %%% Euclidean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('Matchig people using Euclidean...');
    t = tic;
    if exist(strcat(pars.results.folder,'trainEuclidean.mat'),'file')
        load(strcat(pars.results.folder,'trainEuclidean.mat'));
    else
        [trainEuclidean] = euclideanMatching(split,features.data, true);
        save(strcat(pars.results.folder,'trainEuclidean.mat'),'trainEuclidean');
    end
    fprintf('done in %.2f(s)\n', toc(t));

    trainBaselineModel = trainEuclidean;
    clear trainEuclidean
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute results
fprintf('Computing results...');
t = tic;
if exist(strcat(pars.results.folder,'initialTrainResults.mat'),'file')
    load(strcat(pars.results.folder,'initialTrainResults.mat'));
else
    initialTrainResults = computeResults(split, trainBaselineModel, true, pars.model, dataset);
    if strcmpi(pars.model, 'kcca') && isfield(split, 'train2')
        for ncp = 1:length(split)
           split(ncp).train = split(ncp).train2;
           for nt = 1:length(split(ncp).train2)
               trainBaselineModel(ncp).trial(nt).rKCCA = trainBaselineModel(ncp).trial(nt).rKCCA2;
           end
       end
        initialTrainResults = computeResults(split, trainBaselineModel, true, pars.model, dataset);
        initialTrainResults.isTrain2 = true;
    end
    % Save..
    save(strcat(pars.results.folder,'trainInitialResults.mat'),'initialTrainResults');
end
fprintf('done in %.2f(s)\n', toc(t));
end