%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code emulates the results for the VIPeR dataset as published in the paper entitled 
% "Discriminant Context Information Analysis for Post-Ranking Person
% Re-Identification", Jorge Garcia, Niki Martinel, Alfredo Gardel, Ignacio Bravo Gian Luca Foresti and Christian Micheloni
%  Published in IEEE Transcations on Image Processing
%
% Date: 08/22/2016
% Version: 0.1 
% 
dataset = 'VIPeR'; % Dataset
baseline = {'KCCA', 'KISSME', 'svmml', 'Euclidean'}; %Baselines
pcaModel = [false, true, true, false]; % Does the baseline requires PCA?
tr_te = [316 316]; % Train/test split 
testPerc = NaN; % Do not use percentage to split the data
cnt = 1;
for s=1:length(baseline)
    % Run experiment
    % Please refer to run_experiment.m for parameters details
    run_experiment(dataset, baseline{s}, pcaModel(s), ...
                    100+cnt, ...
                    tr_te(1), tr_te(2), testPerc, ...
                    10, ... %Number of context matches
                    true, true, true, ... % Use contest/context/probe
                    55, ... % PCA energy
                    true... % Use Visual Expansion
                    );
    cnt = cnt+1;
end