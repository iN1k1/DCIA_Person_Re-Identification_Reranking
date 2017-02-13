function [dia] = DCIA_DiscriminantContextInformationAnalysis(initialResults, ...
    contentSet, contextSet, dataset, pars, trainFlag)

fname = 'dia.mat';
if trainFlag
    fname = 'trainDia.mat';
end

fprintf('Computing Discriminant Context Information Analisys...');
t = tic;
if exist(strcat(pars.results.folder,fname),'file')
    load(strcat(pars.results.folder,fname));
else
    splits = load(strcat(pars.results.folder,'split.mat'));
    if strcmp(pars.model,'KISSME') || strcmp(pars.model,'svmml')
        if pars.PCAmodel
            load(strcat(pars.results.folder,'modelParam.mat'));
            features.data = modelParam.allFeatures';
            clear modelParam
        else
            load(strcat(pars.results.folder,'features.mat'));
        end
        load(strcat(pars.results.folder,'visualExpansion.mat'));
    else
        load(strcat(pars.results.folder,'features.mat'));
        load(strcat(pars.results.folder,'visualExpansion.mat'));
    end
    
    pars.dia.weights = false;
    pars.dia.enlarge = true;
    pars.dia.enlargeType = 0;
    pars.dia.matchingType = 1;
    pars.dia.PCAType = 1;
    pars.dia.PCAimportance = true;
    
    dia = ComputeDiscriminantInformationAnalisys(initialResults, ...
        contentSet, contextSet, dataset, features.data, ...
        VEData, splits.split, pars.dia, pars.PCAmodel, trainFlag);
    save(strcat(pars.results.folder,fname),'dia');
    clear features
    clear VEData
    clear splits
end
fprintf('done in %.2f(s)\n', toc(t));
end