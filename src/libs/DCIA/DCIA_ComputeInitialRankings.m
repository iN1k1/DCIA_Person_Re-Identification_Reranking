function [initialResults] = DCIA_ComputeInitialRankings(dataset, pars)

initialResults = [];

% Try to load data
if exist(strcat(pars.results.folder,'initialResults.mat'),'file')
    fprintf('Loading initial results...');
    t = tic;
    load(strcat(pars.results.folder,'initialResults.mat'));
else

    % Feature extraction
    features = extractFeatures(dataset, pars);

    % Load split / Compute split
    split = splitDataset(dataset, pars);

    if strcmp(pars.model,'KCCA')

        %%% KCCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Kernel representaion
        fprintf('Computing kernel representation...');
        t = tic;
        if exist(strcat(pars.results.folder,'kernel.mat'),'file')
            load(strcat(pars.results.folder,'kernel.mat'));
        else
            kernels = kernelRepresentation(features,split,false);
            save(strcat(pars.results.folder,'kernel.mat'),'kernels');
        end
        clear features
        fprintf('done in %.2f(s)\n', toc(t));

        % Matching KCCA
        fprintf('Matchig people using KCCA...');
        t = tic;
        if exist(strcat(pars.results.folder,'KCCA.mat'),'file')
            load(strcat(pars.results.folder,'KCCA.mat'));
        else
            KCCA = computeKCCA(kernels,pars);
            save(strcat(pars.results.folder,'KCCA.mat'),'KCCA');
        end
        clear kernels
        fprintf('done in %.2f(s)\n', toc(t));

        BaselineModel = KCCA;
        clear KCCA

    elseif strcmp(pars.model,'KISSME')

        %%% KISSME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('Matchig people using KISSME...');
        t = tic;
        if exist(strcat(pars.results.folder,'KISSME.mat'),'file')
            load(strcat(pars.results.folder,'KISSME.mat'));
        else
            [modelParam, split] = modelConfig(dataset, features, split, pars);
            save(strcat(pars.results.folder,'modelParam.mat'),'modelParam');
            save(strcat(pars.results.folder,'split.mat'),'split');

            [algo] = modelTrain(modelParam, split);
            save(strcat(pars.results.folder,'trainModel.mat'),'algo');

            [KISSME] = modelTest(modelParam, split, algo, false);
            save(strcat(pars.results.folder,'KISSME.mat'),'KISSME');
        end
        fprintf('done in %.2f(s)\n', toc(t));

        BaselineModel = KISSME;
        clear KISSME

    elseif strcmp(pars.model,'svmml')

        %%% svmml %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('Matchig people using svmml...');
        t = tic;
        if exist(strcat(pars.results.folder,'svmml.mat'),'file')
            load(strcat(pars.results.folder,'svmml.mat'));
        else
            [modelParam, split] = modelConfig(dataset, features, split, pars);
            save(strcat(pars.results.folder,'modelParam.mat'),'modelParam');
            save(strcat(pars.results.folder,'split.mat'),'split');

            [algo] = modelTrain(modelParam, split);
            save(strcat(pars.results.folder,'trainModel.mat'),'algo');

            [svmml] = modelTest(modelParam, split, algo, false);
            save(strcat(pars.results.folder,'svmml.mat'),'svmml');
        end
        fprintf('done in %.2f(s)\n', toc(t));

        BaselineModel = svmml;
        clear svmml

    elseif strcmp(pars.model,'Euclidean')

        %%% Euclidean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('Matchig people using Euclidean...');
        t = tic;
        if exist(strcat(pars.results.folder,'svmml.mat'),'file')
            load(strcat(pars.results.folder,'svmml.mat'));
        else
            Euclidean = euclideanMatching(split,features.data, false);
            save(strcat(pars.results.folder,'Euclidean.mat'),'Euclidean');
        end
        fprintf('done in %.2f(s)\n', toc(t));

        BaselineModel = Euclidean;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Compute results
    fprintf('Computing results...');
    t = tic;
    if exist(strcat(pars.results.folder,'initialResults.mat'),'file')
        load(strcat(pars.results.folder,'initialResults.mat'));
    else
        initialResults = computeResults(split, BaselineModel, false, pars.model, dataset);
        save(strcat(pars.results.folder,'initialResults.mat'),'initialResults');
    end
end

fprintf('done in %.2f(s)\n', toc(t));

end

