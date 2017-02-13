function  [dist, pos] = ComputeDists(kfeat, gfeat, features, train_idx, algo, kernel, pars)
    switch lower(pars.model)
        case 'kcca'
            [kTestA, kTestB]  = rekernelRepresentation(kfeat,gfeat,features(train_idx(:,1),:),features(train_idx(:,2),:),kernel.meanA,kernel.meanB);
            [dist, pos] = KCCA(kernel.KA_train,kernel.KB_train,kTestA,kTestB, pars.KCCA);
        case 'kissme'
            M = algo.ds.kissme.M;
            D = sqdist(kfeat', gfeat', M);
            [dist, pos] = sort(D,'ascend');
        case 'svmml'
            A = algo.A;
            B = algo.B;
            b = algo.b;

            K_probe = kfeat';
            K_gallery = gfeat';

            f1 = 0.5*repmat(diag(K_probe'*A*K_probe),[1,size(gfeat,1)]);
            f2 = 0.5*repmat(diag(K_gallery'*A*K_gallery)',[size(kfeat,1),1]);       
            f3 = K_probe'*B*K_gallery;
            D = f1+f2-f3+b;

            [dist, pos] = sort(D,'ascend');
            
        case 'euclidean'
            D = pdist2(gfeat,kfeat,'euclidean');
            [dist, pos] = sort(D,'ascend');
    end
    
    if any(strcmpi(pars.model, {'kissme', 'svmml'}))
        dist = reshape(dist, [], 1);
        pos = reshape(pos, [], 1);
    end
end