function [kernels] = kernelRepresentation(features,sets, trainFlag)

for ncp = 1:length(sets)
   for nt = 1:length(sets(ncp).train)
       if trainFlag
           %%% Cam A
           [kernels(ncp).trial(nt).KA_train, kernels(ncp).trial(nt).KA_test, kernels(ncp).trial(nt).meanA] = ...
               computeKernel(features.data, sets(ncp).train(nt).index(:,1), sets(ncp).train(nt).index(:,1));

           %%% Cam B
           [kernels(ncp).trial(nt).KB_train, kernels(ncp).trial(nt).KB_test, kernels(ncp).trial(nt).meanB] = ...
               computeKernel(features.data, sets(ncp).train(nt).index(:,2), sets(ncp).train(nt).index(:,2));
           
           % May have additional train split for 2nd model..
           if isfield(sets(ncp), 'train2')
                %%% Cam A
                [kernels(ncp).trial(nt).KA_train2, kernels(ncp).trial(nt).KA_test2, kernels(ncp).trial(nt).meanA2] = ...
                    computeKernel(features.data, sets(ncp).train2(nt).index(:,1), sets(ncp).train(nt).index(:,1));

                %%% Cam B
                [kernels(ncp).trial(nt).KB_train2, kernels(ncp).trial(nt).KB_test2, kernels(ncp).trial(nt).meanB2] = ...
                   computeKernel(features.data, sets(ncp).train2(nt).index(:,2), sets(ncp).train(nt).index(:,2));
           end
           
       else
           %%% Cam A
           [kernels(ncp).trial(nt).KA_train, kernels(ncp).trial(nt).KA_test, kernels(ncp).trial(nt).meanA] = ...
               computeKernel(features.data, sets(ncp).test(nt).index(:,1), sets(ncp).train(nt).index(:,1));

           %%% Cam B
           [kernels(ncp).trial(nt).KB_train, kernels(ncp).trial(nt).KB_test, kernels(ncp).trial(nt).meanB] = ...
               computeKernel(features.data, sets(ncp).test(nt).index(:,2), sets(ncp).train(nt).index(:,2));
           
           % May have additional train split for 2nd model..
           if isfield(sets(ncp), 'train2')
               %%% Cam A
               [kernels(ncp).trial(nt).KA_train2, kernels(ncp).trial(nt).KA_test2, kernels(ncp).trial(nt).meanA2] = ...
                   computeKernel(features.data, sets(ncp).test(nt).index(:,1), sets(ncp).train2(nt).index(:,1));

               %%% Cam B
               [kernels(ncp).trial(nt).KB_train2, kernels(ncp).trial(nt).KB_test2, kernels(ncp).trial(nt).meanB2] = ...
                   computeKernel(features.data, sets(ncp).test(nt).index(:,2), sets(ncp).train2(nt).index(:,2));
           end
       end
   end
end
