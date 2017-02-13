function [initialTrainResults] = DCIA_ComputeTrainRankings(dataset, pars)
fprintf('Computing Initial Rankings for train...');
t = tic;
if exist(strcat(pars.results.folder,'trainInitialResults.mat'),'file')
    load(strcat(pars.results.folder,'trainInitialResults.mat'));
else
    load(strcat(pars.results.folder,'features.mat'));
    splits = load(strcat(pars.results.folder,'split.mat'));
    initialTrainResults = ComputeInitialTrainRankings(features, splits.split,  pars, dataset);
    clear features
    clear splits
end
fprintf('done in %.2f(s)\n', toc(t)); 
end