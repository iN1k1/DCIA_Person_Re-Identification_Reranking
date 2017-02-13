%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Discriminant Context Information Analysis
% for Post-Ranking Person Re-Identification
%
% Authors:  Jorge Garcia, Niki Martinel, Alfredo Gardel, Ignacio Bravo
%           Gian Luca Foresti and Christian Micheloni
%  
% Published in IEEE Transcations on Image Processing
%
% Date: 08/22/2016
% Version: 0.1 
% 
% Important Note:
% Intellectual property rights of the following material remains the 
% property of the authors (or as the case may be another rightful owner).
% The provided code, may not be downloaded, printed, copied, reproduced,
% republished, posted, displayed, modified, reused, broadcast or
% transmitted in any way, except for research purposes.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [results] = DCIA_main(initialPars)

fprintf('***************************************************************\n');
fprintf('       Discriminant Context Information Analysis \n');
fprintf('       for Post-Ranking Person Re-Identification \n');
fprintf('***************************************************************\n');

%% Init Parameters
pars = DCIA_InitParameter(initialPars);

%% Load Dataset
dataset = DCIA_LoadDataset(pars);

%% Compute Initial Rankings and CMCs
initialResults = DCIA_ComputeInitialRankings(dataset, pars); 

%% Compute Visual Expansion (Using Multi-Output Regression Forest - POP ICCV 2013)
VEData = DCIA_ComputeVisualExpansion(pars);
    
%% TRAIN Discriminant Context Information Analisys
fprintf('***************************************************************\n');

% Compute Initial Ranking for Training
initialTrainResults = DCIA_ComputeTrainRankings(dataset, pars);

% Select Content Set
contentSetTrain = DCIA_ComputeContentSet(initialTrainResults, pars, true);

% Compute Ranking for each K-best Correlated Match for Training
rankingTrain = DCIA_ComputeContentSetRankings(contentSetTrain, pars, true);

% Compute Global Context Information and Select K-common Matches for Training
contextSetTrain = DCIA_ComputeContextSet(initialTrainResults, rankingTrain, pars, true);

% Discriminant Information Analisys for Training
trainDCIA = DCIA_DiscriminantContextInformationAnalysis(initialTrainResults, contentSetTrain, contextSetTrain, dataset, pars, true);

% Generate trainDIA Split and Matching
[postTrainingModel, evalSplit] = DCIA_EvaluatePostTrainingModel(trainDCIA, trainDCIA, dataset, pars, true);

% Compute results
trainResults = DCIA_ComputeResults(initialTrainResults, contentSetTrain, postTrainingModel, evalSplit, pars, true);

% Clear useless data..
clear postTrainingModel evalSplit contentSetTrain initialTrainResults trainResults trainRanking contextSetTrain;

fprintf('***************************************************************\n');

%% Test Discriminant Information Analisys

% Compute content set for test data
contentSetTest = DCIA_ComputeContentSet(initialResults, pars, false);

% Compute Ranking for each K-best Correlated Match
rankingTest = DCIA_ComputeContentSetRankings(contentSetTest, pars, false);

% Compute Context Set
contextSetTest = DCIA_ComputeContextSet(initialResults, rankingTest, pars, false);

% Discriminant Information Analisys on Test Data
testDCIA = DCIA_DiscriminantContextInformationAnalysis(initialResults, contentSetTest, ...
                   contextSetTest, dataset, pars, false);

% Evaluate post-training model
[postTrainingModel, evalSplit] = DCIA_EvaluatePostTrainingModel(trainDCIA, testDCIA, dataset, pars, false);

% Compute results
results = DCIA_ComputeResults(initialResults, contentSetTest, postTrainingModel, evalSplit, pars, false);

fprintf('***************************************************************\n');
