function [dists, id_probe, rank_ids] = compute_rank2(Method, trainX, testX, test_idx_pairs, test_ids)

A = Method.P; % Projection vector
if strcmp(Method.name,'oLFDA')
    K_test = testX';
else
    [K_test] = ComputeKernelTest(trainX, testX, Method); %compute the kernel matrix.
end

idx_probe = unique(test_idx_pairs(:,1),'stable');
idx_gallery = unique(test_idx_pairs(:,2),'stable');

K_prob = K_test(:, idx_probe);
K_ref = K_test(:, idx_gallery);
D = zeros(length(idx_probe), length(idx_gallery));
parfor i =1: size(K_prob,2)
    diff = bsxfun(@minus, K_ref,K_prob(:,i));
    diff = A*diff;
    D(i, :) = D(i, :) + sum(diff.^2,1);
end

D = reshape(D', size(test_idx_pairs,1), 1);

id_probe = unique(test_ids(:,1), 'stable');
id_gallery = unique(test_ids(:,2), 'stable');
rank_ids = zeros(length(id_probe), length(id_gallery));
dists = zeros(length(id_probe), length(id_gallery));

for i= 1:length(id_probe)
    
    idx = test_ids(:,1)==id_probe(i);
    idgal = test_ids(idx,2);
    [dists(i,:), sort_idx] = sort(D(idx), 'ascend');
    rank_ids(i,:) = idgal(sort_idx);
 
end
end



% Calculate the kernel matrix for train and test set.
% TODO: Replace the ComputeKernel function in  ComputeKernel.m
% Input: 
%       Method: the distance learning algorithm struct. In this function
%               only field used "kernel", the name of the kernel function. 
%       train: The data used to learn the projection matric. Each row is a
%               sample vector. Ntr-by-d
%       test: The data used to test and calculate the CMC for the
%               algorithm. Each row is a sample vector. Nts-by-d
function [K_test] = ComputeKernelTest(train, test, Method)

if (size(train,2))>2e4 && (strcmp(Method.kernel, 'chi2') || strcmp(Method.kernel, 'chi2-rbf'))
    % if the input data matrix is too large then use parallel computing
    % tool box.
    matlabpool open
    
    switch Method.kernel
        case {'linear'}
            K_test = train * test';
        case {'chi2'}
            parfor i =1:size(test,1)
                dotp = bsxfun(@times, test(i,:), train);
                sump = bsxfun(@plus, test(i,:), train);
                K_test(:,i) = 2* sum(dotp./(sump+1e-10),2);
            end
        case {'chi2-rbf'}
            sigma = Method.rbf_sigma;
            parfor i =1:size(test,1)
                subp = bsxfun(@minus, test(i,:), train);
                subp = subp.^2;
                sump = bsxfun(@plus, test(i,:), train);
                K_test(:,i) =  sum(subp./(sump+1e-10),2);
            end
            K_test =exp(-K_test./sigma);
    end
    matlabpool close
else
    switch Method.kernel
        case {'linear'}
            K_test = train * test';
        case {'chi2'}
            for i =1:size(test,1)
                dotp = bsxfun(@times, test(i,:), train);
                sump = bsxfun(@plus, test(i,:), train);
                K_test(:,i) = 2* sum(dotp./(sump+1e-10),2);
            end
        case {'chi2-rbf'}
            sigma = Method.rbf_sigma;
            parfor i =1:size(test,1)
                subp = bsxfun(@minus, test(i,:), train);
                subp = subp.^2;
                sump = bsxfun(@plus, test(i,:), train);
                K_test(:,i) =  sum(subp./(sump+1e-10),2);
            end
            K_test =exp(-K_test./sigma);
    end
end
end