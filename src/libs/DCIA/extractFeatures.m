function [ features ] = extractFeatures( dataset, pars )

features = [];
fprintf('Extracting features...');
t = tic;
if exist(strcat(pars.results.folder,'features.mat'),'file')
    load(strcat(pars.results.folder,'features.mat'));
else
    load(sprintf('./data/features/data_%s.mat', lower(dataset.name)));
    features.data = data;
    clear data;
    
%     % From Niki
%     elseif strcmp(dataset.name,'PRID')
%         load('/data/features/data_prid.mat');
%         features.data = data;
%         clear data;
%     elseif strcmp(dataset.name,'3DPeS')
%         %load('/data/features/data_3dpes.mat');
%         load('/data/features/data_3dpes3.mat');
%         features.data = data;
%         clear data;
%     elseif strcmp(dataset.name,'SAIVT38')
%         load('/data/features/data_saivt38.mat');
%         features.data = data;
%         clear data;
%     elseif strcmp(dataset.name,'CUHK02_P1')
%         load('/data/features/data_cuhk02_2.mat')
%         features.data = data;
%         clear data;
%     elseif strcmp(dataset.name,'i-LIDS_2cam')
%         load('/data/features/data_ilids2.mat')
%         features.data = data;
%         clear data;
%     else
%         features = featureExtraction(dataset,pars);
%         save(strcat(pars.results.folder,'features.mat'),'features');
%     end

    save(strcat(pars.results.folder,'features.mat'),'features');
end
fprintf('done in %.2f(s)\n', toc(t));

end

