function [model, split] = DCIA_EvaluatePostTrainingModel(dciaTrain, dciaTest, ...
    dataset, pars, trainFlag)

fnameModel = 'testModel.mat';
fnameSplit = 'testSplit.mat';
if trainFlag
    fnameModel = 'ttrainModel.mat';
    fnameSplit = 'ttrainSplit.mat';
end

fprintf('Generating trainDIA split and Matchig people using %s for train...', pars.model);
t = tic;
if exist(fullfile(pars.results.folder, fnameModel),'file')
    load(fullfile(pars.results.folder, fnameModel));
    load(fullfile(pars.results.folder, fnameSplit));
else
    %if strcmp(pars.model,'CCA')
    %    [ttrainKCCA, ttrainSplit] = PRIA_TestCCA(dciaTrain, dciaTest, pars);
    %    save(fullfile(pars.results.folder,'ttrainKCCA.mat'),'ttrainKCCA');
    %    save(fullfile(pars.results.folder,'ttrainSplit.mat'),'ttrainSplit');
    %else
    if strcmp(pars.model,'KCCA')
        [model, split] = PRIA_TestKCCA(dciaTrain, dciaTest, pars);
    elseif strcmp(pars.model,'KISSME')
        [model, split] = PRIA_TestKISSME(dataset, dciaTrain, dciaTest, pars);
    elseif strcmp(pars.model,'svmml')
        [model, split] = PRIA_TestSVMML(dataset, dciaTrain, dciaTest, pars);
    elseif strcmp(pars.model,'Euclidean')
        [model, split] = PRIA_TestEuclidean(dciaTrain, dciaTest, pars);
    end
    save(fullfile(pars.results.folder,fnameModel),'model');
    save(fullfile(pars.results.folder, fnameSplit),'split');
end
fprintf('done in %.2f(s)\n', toc(t));

end