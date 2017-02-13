function [allFeatures] = featuresPreProcessing(AlgoOption, allFeatures)

if ~isempty(strfind(AlgoOption.func, 'PCCA')) && strcmp(AlgoOption.kernel, 'linear') 
    % linear kernel for PCCA using sqrt
    allFeatures = sqrt(allFeatures);
end
if AlgoOption.doPCA == 1
    if ~strcmp(AlgoOption.func,'KISSME')
%                 For svmml, L2 normalization is applied, for KISSME do
%                 nothing
        allFeatures = normc_safe(allFeatures); % L2 normalizaiton
    end
else
    % Others apply L1 normalization                
    allFeatures = bsxfun(@times, allFeatures, 1./(sum(allFeatures,2)+eps));
    if ~strcmp(AlgoOption.kernel, 'chi2-rbf')
        allFeatures = allFeatures*100;
    end

end

if AlgoOption.doPCA
    % the pca function already centers the data
    [coeffs,pc,latent] = pca(allFeatures');
    if isempty(AlgoOption.PCAdim)
        pcadim =  sum(cumsum(latent)/sum(latent)<0.95);
    else
        pcadim = AlgoOption.PCAdim;
    end
    allFeatures = pc(:,1:pcadim)';
end