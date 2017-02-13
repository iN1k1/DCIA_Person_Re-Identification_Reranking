function [newFeatData, number_component, PCAplot] = simplePCA(data,  weights, PCAType, pcaNum, pcaImportance)

%% weighted mean
weightsMatrix = repmat(weights,1,size(data,1));
dataMean = wmean(data',weightsMatrix)';

%% Centered data
dataO = bsxfun(@minus,data,dataMean);

%% Computing standard PCA
[u,s,~]= svd(dataO,0);

if PCAType == 2
    PCAcompNum = pcaNum;
elseif PCAType == 3
    s = diag(s);
    acuEV = (pcaNum*sum(s(:)))/100;
    sumEV = 0;
    auxNum = 0;
    for i = 1:length(s)
        sumEV = sumEV + s(i);
        auxNum = auxNum + 1;
        if(sumEV >= acuEV)
            break;
        end
    end
    PCAcompNum = auxNum;
end

number_component = PCAcompNum;
if size(u,2) < number_component
    number_component = size(u,2);
else
    number_component = PCAcompNum;
end

if pcaImportance
    dataProjection = u(:,1:number_component)' * centeredData;
    dataBackProjection = (u(:,1:number_component)*dataProjection) + repmat(dataMean,1,size(auxData,2));
    newFeatData = data - dataBackProjection;
else
    dataProjection = u(:,(number_component+1):end)' * centeredData;
    dataBackProjection = (u(:,(number_component+1):end)*dataProjection) + repmat(dataMean,1,size(auxData,2));
    newFeatData = dataBackProjection;
end
    
PCAplot.Dp = u(:,1:2)' * centeredData;

PCAplot.eigenval1 = s(1,1);
PCAplot.eigenval2 = s(2,2);


