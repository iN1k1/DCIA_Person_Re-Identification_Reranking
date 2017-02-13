function [ranking] = DCIA_ComputeContentSetRankings(contentSetMatches, pars, trainFlag)

fname = 'ranking.mat';
if trainFlag
    fname = 'trainRanking.mat';
end

fprintf('Computing Ranking for each Person in the Content Set...');
t = tic;
if exist(fullfile(pars.results.folder,fname),'file')
    load(fullfile(pars.results.folder,fname));
else
%     if strcmp(pars.model,'CCA')
%         %%% CCA
%         load(strcat(pars.results.folder,'features.mat'));
%         load(strcat(pars.results.folder,'split.mat'));
%         load(strcat(pars.results.folder,'trainCCA.mat'));
%         ranking = PRIA_ComputeCorrMatchRankingCCA(contentSetMatches, features.data, split, trainCCA, true);
%         save(strcat(pars.results.folder,'trainRanking.mat'),'ranking');
%         clear features
%         clear split
%         clear trainCCA
%     else
    load(fullfile(pars.results.folder,'visualExpansion.mat'));
	splits = load(fullfile(pars.results.folder,'split.mat'));
    algo = [];
    kernels = [];
    if strcmp(pars.model,'KCCA')
        %%% KCCA
        load(fullfile(pars.results.folder,'features.mat'));
        load(fullfile(pars.results.folder,'kernel.mat'));
        %ranking = ComputeContentSetMatchRankingKCCA(contentSetMatches, features.data, VEData, splits.split, kernels, pars, trainFlag);
    elseif any(strcmp(pars.model,{'KISSME', 'svmml'}))
        %%% KISSME
        load(fullfile(pars.results.folder,'modelParam.mat'));
        load(fullfile(pars.results.folder,'trainModel.mat'));
        features.data = modelParam.allFeatures';
        %ranking = ComputeCorrMatchRankingKISSME(contentSetMatches, modelParam.allFeatures, VEData, splits.split, algo, trainFlag);
        %save(fullfile(pars.results.folder,fname),'ranking');
   % elseif strcmp(pars.model,'svmml')
        %%% svmml
      %  load(fullfile(pars.results.folder,'modelParam.mat'));
      %  load(fullfile(pars.results.folder,'trainModel.mat'));
        %ranking = PRIA_ComputeCorrMatchRankingSVMML(contentSetMatches, modelParam.allFeatures, VEData, splits.split, algo, trainFlag);
        %save(fullfile(pars.results.folder,fname),'ranking');
    elseif strcmp(pars.model,'Euclidean')
        %%% Euclidean
        load(fullfile(pars.results.folder,'features.mat'));
        %ranking = PRIA_ComputeCorrMatchRankingEuclidean(contentSetMatches, features.data, VEData, splits.split, trainFlag);
        %save(fullfile(pars.results.folder,fname),'ranking');
    end
    
    ranking = ComputeContentSetMatchRanking(contentSetMatches, features.data, VEData, splits.split, algo, kernels, pars, trainFlag);
    save(fullfile(pars.results.folder,fname),'ranking');
        
        
end
fprintf('done in %.2f(s)\n', toc(t));
end