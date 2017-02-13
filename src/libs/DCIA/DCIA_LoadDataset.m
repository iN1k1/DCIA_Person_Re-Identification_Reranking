function [dataset] = DCIA_LoadDataset(pars)

fprintf('Loading dataset...');
t = tic;
load(fullfile(pars.dataset.data.folder,strcat(pars.dataset.data.filename,'.mat')));
fprintf('done in %.2f(s)\n', toc(t));

end