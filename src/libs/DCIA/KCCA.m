function [dist, pos] = KCCA(KA_train, KB_train, KA_test, KB_test, pars)

% Compute M eigenvectors  to represent the semantic projections
[nalpha, nbeta, r] = kcanonca_reg_ver2(KB_train,KA_train,pars.reconstructionError,pars.regularisationPar,0,0);
[KA_train_K,KA_test_K,KB_train_K,KB_test_K] = center_kcca(KA_train,KA_test,KB_train,KB_test);

% Project the probe and gallery samples to the common space
pA = KA_test_K * nbeta;
pB = KB_test_K * nalpha;

% Compute the cosine distance
distMatrix = pdist2(pB,pA,'cosine');

% Nearest Neighbor (NN) classification
[dist, pos] = sort(distMatrix);


function [train_a_ker,test_a_ker,train_b_ker,test_b_ker] = center_kcca(train_a_ker,test_a_ker,train_b_ker,test_b_ker)

l =size(train_b_ker, 1);
j = ones(l,1);
test_b_ker = test_b_ker - (ones(size(test_b_ker))*train_b_ker) / l - (test_b_ker*(j*j'))/l +((j'*train_b_ker*j)*ones(size(test_b_ker)))/(l^2);

l =size(train_a_ker, 1);
j = ones(l,1);
test_a_ker = test_a_ker - (ones(size(test_a_ker))*train_a_ker) / l - (test_a_ker*(j*j'))/l +((j'*train_a_ker*j)*ones(size(test_a_ker)))/(l^2);