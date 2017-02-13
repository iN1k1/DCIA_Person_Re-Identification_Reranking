function [ split ] = loadSplit( pars )

split = [];
commonSplit = fullfile(pars.results.folder, '..', 'common', sprintf('split_%d_%d.mat', pars.split.persons2trainN, pars.split.persons2testN));
if ~isnan(pars.split.person2trainSplitModelsPerc)
    commonSplit = fullfile(pars.results.folder, '..', 'common', sprintf('split_%d_%d_%g-%g.mat', pars.split.persons2trainN, pars.split.persons2testN, pars.split.person2trainSplitModelsPerc(1), pars.split.person2trainSplitModelsPerc(2)));
end
if exist(commonSplit, 'file')
    load(commonSplit);
    save(fullfile(pars.results.folder,'split.mat'), 'split');
elseif exist(fullfile(pars.results.folder,'split.mat'),'file')
    load(strcat(pars.results.folder,'split.mat'));
end

end

