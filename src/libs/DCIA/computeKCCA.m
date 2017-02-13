function [rKCCA] = computeKCCA(kernels,pars)

for ncp = 1:length(kernels)
    for nt = 1:length(kernels(ncp).trial)
        kernel = kernels(ncp).trial(nt);
        [rKCCA(ncp).trial(nt).rKCCA.dist, rKCCA(ncp).trial(nt).rKCCA.pos] = ...
            KCCA(kernel.KA_train,kernel.KB_train,kernel.KA_test,kernel.KB_test, pars.KCCA);
        if isfield(kernel, 'KA_train2')
            [rKCCA(ncp).trial(nt).rKCCA2.dist, rKCCA(ncp).trial(nt).rKCCA2.pos] = ...
                KCCA(kernel.KA_train2,kernel.KB_train2,kernel.KA_test2,kernel.KB_test2, pars.KCCA);
        end
    end
end
