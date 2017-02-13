function [nData,  number_component, PCAplot] = robustPCA(data, weights, PCAType, pcaNum, pcaImportance)

%% weighted mean
weightsMatrix = repmat(weights,1,size(data,1));
dataMean = wmean(data',weightsMatrix)';

%% Centered data
dataO = bsxfun(@minus,data,dataMean);

%% Computing standard PCA
[u,s,~]= svd(dataO,0);

if PCAType == 0
    PCAcompNum = pcaNum;
elseif PCAType == 1
    sn = diag(s);
    acuEV = (pcaNum*sum(sn(:)))/100;
    sumEV = 0;
    auxNum = 0;
    for i = 1:length(sn)
        sumEV = sumEV + sn(i);
        auxNum = auxNum + 1;
        if(sumEV >= acuEV)
            break;
        end
    end
    PCAcompNum = auxNum;
end

N = 1;
beta=2.3; % Parameter ....
number_component = PCAcompNum;
if size(u,2) < number_component
    number_component = size(u,2);
else
    number_component = PCAcompNum;
end

%% Compute scale statistics
Sigmaf=zeros(size(data,1),1);
if pcaImportance 
    cini=(u(:,1:number_component)'*(dataO));
    error=dataO-u(:,1:number_component)*cini;
else
    cini=(u(:,(number_component+1):end)'*(dataO));
    error=dataO-u(:,(number_component+1):end)*cini;
end
medianat=median(abs(error(:)));
error2=error(:)-medianat;
Sigmaft=sqrt(3)*1.4826*median(abs(error2(:)));

for i=1+N:size(data,1)-1-N
    errorlo=error(i-N:i+N,:);
    medianat=median(abs(errorlo(:)));
    error2=error(i-N:i+N,:)-medianat;
    Sigmaf(i)=beta*sqrt(3)*1.4826*median(abs(error2(:)));         
end
Sigmaf=Sigmaf(:);
Sigmaf=max(Sigmaf,Sigmaft*ones(size(Sigmaf)));
Sigmai=3*Sigmaf;

clear error error2 medianat Sigmaft errorlo x y i ind index j

%% Initialize RPCA
mean_ini=median(data')';
if pcaImportance
    basis_ini=u(:,1:number_component)+randn(size(data,1),number_component);
else
    basis_ini=u(:,(number_component+1):end);
    basis_ini=basis_ini+randn(size(data,1),size(basis_ini,2));
end
c_ini=pinv(basis_ini)*(dataO);
%Here we use the principal components as initial guess, 
%but we can add random noise to the basis and run several times the algorithm to get the solution with lowest minimum.


%% Compute RPCA
[rob_mean,Bg,cg,info,Sigma]=rob_pca(data,number_component,300,1,Sigmaf,Sigmai,2,basis_ini,c_ini,mean_ini);   

%% Compute outliers
error=data-rob_mean*ones(1,size(data,2))-Bg*cg;
Sigmat=(Sigmaf*ones(1,size(data,2)));
temp=abs(error)<(Sigmat/sqrt(3));
W2=(Sigmat./((Sigmat+error.^2).^2)).*temp;

clear Sigmat temp error

%Add bases until the preserve energy as defined in the paper is bigger than 0.9 (in this case 24 bases)
%to compute weighted principal component analysis, (We use alternated weighted least squares the normalized gradient version is coming soon... )
%The initial guess is the one given by rob_pca, as before
%we can add random noise to it, run several times the algorithm and get the solution with lowest minimum.

bases=15; % not used
[Bgw,cgw,info,meanw]=weighted_pca(data,W2,bases,25,2,[Bg 0.0001*randn(size(Bg,1),bases-size(Bg,2))],[cg ; 0.0001*randn(bases-size(Bg,2),size(data,2))],rob_mean);   

%The images will be reconstructed as   	 
%rec=meanw*ones(1,size(data,2))+Bgw*cgw;
%To visualize them just write  				 
%imagesc(reshape(rec(:,i),sizeim))
%nData = data-meanw*ones(1,size(data,2))+Bgw*cgw;

if pcaImportance
    nData = data-(meanw*ones(1,size(data,2))+Bgw*cgw);
else
    nData = meanw*ones(1,size(data,2))+Bgw*cgw;
end

EV2 = Bgw(:,1:2)';
PCAplot.Dp = EV2 * (data-(meanw*ones(1,size(data,2))));

PCAplot.eigenval1 = s(1,1);
PCAplot.eigenval2 = s(2,2);


ndataMean = mean(nData')';
ndataO = bsxfun(@minus,nData,ndataMean);
[nu,ns,~]= svd(ndataO,0);

PCAplot.nDp = nu(:,1:2)' * ndataO;
PCAplot.neigenval1 = ns(1,1);
PCAplot.neigenval2 = ns(2,2);


