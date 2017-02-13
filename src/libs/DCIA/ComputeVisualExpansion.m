function [VEData] = ComputeVisualExpansion(features, split, pcaFeatUse, pcaFeat, pars)

features.data = single(features.data);

% std(features.data(:))
% mean(features.data(:))
% min(features.data(:))
% max(features.data(:))

if pars.use
    % learning the feature transformation for a camera pair and Compute synthetic images
    for i = 1:length(split.train)

        featTrainA = features.data(split.train(i).index(:,1),:);
        featTrainB = features.data(split.train(i).index(:,2),:);
        allFeat = features.data;
        ls=int32(1:size(featTrainA,1));
        w=[];

        rtensparam.nbterms = pars.treeNumber;
        rtensparam.bootstrap=0;
        rtensparam.mart = 0;
        rtensparam.rtparam.nmin=5;
        rtensparam.rtparam.varmin=0;
        rtensparam.rtparam.savepred=1; % after test, set to 0
        rtensparam.rtparam.bestfirst=0;
        rtensparam.rtparam.rf=1;
        rtensparam.rtparam.extratrees=0;
        rtensparam.rtparam.adjustdefaultk=1;
 
        [treeProbe, var_imp] = rtenslearn_c(featTrainA,featTrainB,ls,w,rtensparam,0);
        VED = ComputeSyntheticImage(treeProbe,allFeat);
        mse = mean(mean((VED-allFeat).^2));
        VEData.VEprobe.feat{i} = double(VED);
        VEData.VEprobe.error(i) = sqrt(mse);
        
        if pcaFeatUse
            
            pcaFeat = single(pcaFeat);
            
            featTrainA = pcaFeat(split.train(i).index(:,1),:);
            featTrainB = pcaFeat(split.train(i).index(:,2),:);
            allFeat = pcaFeat;
            ls=int32(1:size(featTrainA,1));
            w=[];
            
            [treeProbe, var_imp] = rtenslearn_c(featTrainA,featTrainB,ls,w,rtensparam,0);
            VED = ComputeSyntheticImage(treeProbe,allFeat);
            mse = mean(mean((VED-allFeat).^2));
            VEData.VEprobe.PCAfeat{i} = double(VED);
            VEData.VEprobe.PCAerror(i) = sqrt(mse);

            [treeGallery, var_imp] = rtenslearn_c(featTrainB,featTrainA,ls,w,rtensparam,0);
            VED = ComputeSyntheticImage(treeGallery,allFeat);
            mse = mean(mean((VED-allFeat).^2));
            VEData.VEgallery.PCAfeat{i} = double(VED);
            VEData.VEgallery.PCAerror(i) = sqrt(mse);
        else
            [treeGallery, var_imp] = rtenslearn_c(featTrainB,featTrainA,ls,w,rtensparam,0);
            VED = ComputeSyntheticImage(treeGallery,allFeat);
            mse = mean(mean((VED-allFeat).^2));
            VEData.VEgallery.feat{i} = double(VED);
            VEData.VEgallery.error(i) = sqrt(mse);
        end

    end
else
    for i = 1:length(split.train)
        
        allFeat = features.data;

        VEData.VEprobe.feat{i} = double(allFeat);
        VEData.VEprobe.error(i) = 0;
        
        if pcaFeatUse
            VEData.VEprobe.PCAfeat{i} = double(pcaFeat);
            VEData.VEprobe.PCAerror(i) = 0;

            VEData.VEgallery.PCAfeat{i} = double(pcaFeat);
            VEData.VEgallery.PCAerror(i) = 0;
        else
            VEData.VEgallery.feat{i} = double(allFeat);
            VEData.VEgallery.error(i) = 0;
        end

    end
end

function [VEData] = ComputeSyntheticImage(treeEnsemble,data)

VEData = 0;

global XTS;
global tree;

XTS = data;

treesNumber = length(treeEnsemble.trees);

idx = randperm(treesNumber);

for t = 1:round((2*treesNumber)/3)
    tree = treeEnsemble.trees(idx(t));
    VEData = VEData + tree.weight*rtpred();
end

function [YTS]=rtpred()

% Test a multiple output regression tree
  
% inputs:
%   tree: a tree output by the function rtenslearn_c
%   YLS: outputs for the learning sample cases
%   XTS: inputs for the test cases
% Output:
%   YTS: output predictions for the test cases

global assignednodets
global XTS
global tree

Nts=size(XTS,1);
assignednodets=zeros(Nts,1);

verbose=0;

YTS=zeros(Nts,size(tree.predictions,2));

if (verbose)
fprintf('computation of indexes\n');
end

getleafts(1,1:Nts);

if (verbose)
fprintf('computation of predictions\n');
end  

for i=1:Nts
YTS=tree.predictions(tree.indexprediction(assignednodets),:);
end    
  
function getleafts(currentnode,currentrows)

global assignednodets
global XTS
global tree

testattribute=tree.testattribute(currentnode);

if testattribute==0 % a leaf
assignednodets(currentrows)=currentnode;
else
testthreshold=tree.testthreshold(currentnode);
leftind=(XTS(currentrows,testattribute)<testthreshold);
rightind=~leftind;
getleafts(tree.children(currentnode,1),currentrows(leftind));
getleafts(tree.children(currentnode,2),currentrows(rightind));
end

