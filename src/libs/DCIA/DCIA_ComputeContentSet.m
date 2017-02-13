function [contentSet] = DCIA_ComputeContentSet(initialTrainResults, pars, trainFlag)

fprintf('Computing Content Set...');
t = tic;
fname = 'corrMatches.mat';
if trainFlag
    fname = 'corrTrainMatches.mat';
end
if exist(strcat(pars.results.folder,fname),'file')
    load(strcat(pars.results.folder,fname));
else
    contentSet = ContentSetSelection(initialTrainResults, pars, trainFlag);
    save(strcat(pars.results.folder,fname),'contentSet');
end
fprintf('done in %.2f(s)\n', toc(t));
end