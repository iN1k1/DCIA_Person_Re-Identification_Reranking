function [pars] = DCIA_InitParameter(pars)

% Initial Information of Parameters
% pars = pars;

% Results
if ~exist(fullfile(pars.results.commonFolder,pars.dataset.name),'dir')
    mkdir(fullfile(pars.results.commonFolder,pars.dataset.name));
end
if ~exist(fullfile(pars.results.commonFolder,pars.dataset.name,'/exp',pars.results.expNumber),'dir')
    mkdir(fullfile(pars.results.commonFolder,pars.dataset.name,'/exp',pars.results.expNumber));
end
pars.results.folder = fullfile(pars.results.commonFolder,pars.dataset.name,'/exp',pars.results.expNumber,'/');

% Dataset
pars.dataset.data.folder = fullfile(pwd,'data','datasets');
pars.dataset.data.filename = ['data_',pars.dataset.name];

% Baseline
pars.KCCA.reconstructionError = 1;
pars.KCCA.regularisationPar = 0.5;

% Split (leave NaN!)
pars.split.person2trainSplitModelsPerc = NaN;

% Store parameters
save(fullfile(pars.results.folder,'parameters.mat'),'pars');

end

