function [results] = DCIA_ComputeResults(initialResults, contentSet, model, split, pars, trainFlag)

fname = 'results.mat';
if trainFlag
    fname = 'trainResults.mat';
end

fprintf('Computing final results for train...');
t = tic;
if exist(strcat(pars.results.folder, fname),'file')
    load(strcat(pars.results.folder, fname));
else
    results = ComputeFinalResults(initialResults, contentSet, model, split);
    save(strcat(pars.results.folder, fname),'results');
end
fprintf('done in %.2f(s)\n', toc(t));
end