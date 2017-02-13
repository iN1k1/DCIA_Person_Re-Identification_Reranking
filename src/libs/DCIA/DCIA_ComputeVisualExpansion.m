function [VEData] = DCIA_ComputeVisualExpansion(pars)

fprintf('***************************************************************\n');
fprintf('Computing visual expansion data...');
t = tic;

if exist(strcat(pars.results.folder,'visualExpansion.mat'),'file')
    load(strcat(pars.results.folder,'visualExpansion.mat'));
else
    load(strcat(pars.results.folder,'features.mat'));
    splits  = load(strcat(pars.results.folder,'split.mat'));
    if strcmp(pars.model,'KISSME') || strcmp(pars.model,'svmml')
        load(strcat(pars.results.folder,'modelParam.mat'));
        VEData = ComputeVisualExpansion(features, splits.split, true, modelParam.allFeatures', pars.visualExpansion);
        clear modelParam
    else
        VEData = ComputeVisualExpansion(features, splits.split, false, [], pars.visualExpansion); 
    end
    save(strcat(pars.results.folder,'visualExpansion.mat'),'VEData');
    clear features
    clear splits
end
fprintf('done in %.2f(s)\n', toc(t));
fprintf('***************************************************************\n');
end