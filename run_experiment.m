function [results] = run_experiment(datasetName, modelName, pcaModel, ...
                            expNumber, ...
                            trainN, testN, testPerc, ...
                            contextInfoSize, ...
                            useContent, useContext, useProbe, ...
                            pcaPerc, ...
                            useVE )
                            

%clear all
close all
clc

% Add paths
root = pwd;
addpath(root);
addpath(genpath(fullfile(root, 'src')));
addpath(genpath(fullfile(root, 'data')));

% Dataset Parameters
initialPars.dataset.name = datasetName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Model
%
% moldel: baseline model, options: 'KCCA' 'KISSME' 'svmml' 'Euclidean'
% PCAmodel: use PCA features to compute DIA, options: true false
initialPars.model = modelName;
initialPars.PCAmodel = pcaModel; %false;

%% Results
%
% commomFolder: path to save files
% expNumber: number of experiment
%
initialPars.results.commonFolder = './results/';
initialPars.results.expNumber = sprintf('%03d', expNumber);

%% Split Information
%
% cameraPairs: camera pair to compute
% numTrials: number of trilas
initialPars.split.cameraPairs = [1 2];
initialPars.split.numTrials = 10;
initialPars.split.persons2test = testPerc; %percentage
initialPars.split.persons2testN = testN; %fixed number
initialPars.split.persons2trainN = trainN; %fixed number
initialPars.split.numSamplesPerPersonTest = 1;
initialPars.split.numSamplesPerPersonTrain = 1;

%% Content Info
initialPars.contestInfo.errorPerc = NaN;

%% Context Information
initialPars.contextInfo.kcommonMatches = contextInfoSize;

%% Discriminant Information Analisys
initialPars.dia.includingContent = useContent; % include feat vectors from content set
initialPars.dia.includingContext = useContext; % include feat vectors from context set
initialPars.dia.includingProbe = useProbe; % include feat vectors from probe
initialPars.dia.PCAcompNum = pcaPerc;  % Percentage of PCA energy

%% Visual Expansion
initialPars.visualExpansion.use = useVE;            % Use of Visual Expansion (POP ICCV 2013)
initialPars.visualExpansion.treeNumber = 200;      % Number of trees contained into random forest
initialPars.visualExpansion.treeDepth = 5;         % Depth of the tree
                                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
%% Let's go!
results = DCIA_main(initialPars);

end