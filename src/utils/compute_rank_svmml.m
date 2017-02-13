function [dists, sort_idx, id_probe, rank_ids] = compute_rank_svmml(Method, testX, test_idx_pairs, test_ids)

% A = Method.A;
% B = Method.B;
% b = Method.b;
% [K_test] = ComputeKernelTest(train, test, Method); %compute the kernel matrix.
% K_test = test';

% for k = 1:size(ix_partition,1)
%     ix_ref = ix_partition(k,:) == 1;
%     if min(min(double(ix_partition))) < 0
%         ix_prob = ix_partition(k,:) ==-1; 
%     else
%         ix_prob = ix_partition(k,:) ==0;
%     end
%ref_ID = IDs(ix_ref);
%prob_ID = IDs(ix_prob);

% dis = 0;
% for c = 1:numel(test)
A = Method.A;
B = Method.B;
b = Method.b;
K_test = testX;

idx_probe = unique(test_idx_pairs(:,1),'stable');
idx_gallery = unique(test_idx_pairs(:,2),'stable');

K_probe = K_test(:,idx_probe);
K_gallery = K_test(:,idx_gallery);

f1 = 0.5*repmat(diag(K_probe'*A*K_probe),[1,length(idx_gallery)]);
f2 = 0.5*repmat(diag(K_gallery'*A*K_gallery)',[length(idx_probe),1]);       
f3 = K_probe'*B*K_gallery;
D = f1+f2-f3+b;
D = reshape(D', size(test_idx_pairs,1), 1);

id_probe = unique(test_ids(:,1), 'stable');
id_gallery = unique(test_ids(:,2), 'stable');
rank_ids = zeros(length(id_probe), length(id_gallery));
dists = zeros(length(id_probe), length(id_gallery));
sort_idx = zeros(length(id_probe), length(id_gallery));

dists2 = zeros(length(id_probe), length(id_gallery));

for i= 1:length(id_probe)
    
    idx = test_ids(:,1)==id_probe(i);
    idgal = test_ids(idx,2);
    [dists(i,:), sort_idx(i,:)] = sort(D(idx), 'ascend');
    rank_ids = idgal(sort_idx(i,:));
    
    [~, posg] = sort(rank_ids, 'ascend');
    dists2(i,:) = dists(i,posg);
 
end

for i= 1:length(id_probe)
    [dists(i,:), sort_idx(i,:)] = sort(dists2(i,:), 'ascend');
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
            for i =1:size(test,1)
                subp = bsxfun(@minus, test(i,:), train);
                subp = subp.^2;
                sump = bsxfun(@plus, test(i,:), train);
                K_test(:,i) =  sum(subp./(sump+1e-10),2);
            end
            K_test =exp(-K_test./sigma);
    end
end
end