function [contextSet] = DCIA_ComputeContextSet(initialResults, ranking, pars, trainFlag)
fname = 'contextInfo.mat';
if trainFlag
    fname = 'trainContextInfo.mat';
end

fprintf('Computing Context Set...');
t = tic;
if exist(fullfile(pars.results.folder,fname),'file')
    load(fullfile(pars.results.folder,fname));
else
    contextSet = ComputeContextSet(initialResults, ranking, pars.contextInfo);
    save(fullfile(pars.results.folder,fname),'contextSet');
end
fprintf('done in %.2f(s)\n', toc(t));

end