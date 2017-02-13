function [KCCA] = euclideanMatching(split, features, trainFlag)

if trainFlag
    for nt = 1:length(split.train)
    
        idx_probe = split.train(nt).index(:,1);
        idx_gallery = split.train(nt).index(:,2);
        
        idx_probe = idx_probe(~isnan(idx_probe));
        idx_gallery = idx_gallery(~isnan(idx_gallery));

        featG = features(idx_gallery,:);
        featP = features(idx_probe,:);
        % Compute the cosine distance
        distMatrix = pdist2(featG,featP,'euclidean');

        % Nearest Neighbor (NN) classification
        [dist, pos] = sort(distMatrix);

        KCCA.trial(nt).rKCCA.dist = dist;
        KCCA.trial(nt).rKCCA.pos = pos;
    end
else
    for nt = 1:length(split.test)

        idx_probe = split.test(nt).index(:,1);
        idx_gallery = split.test(nt).index(:,2);
        
        idx_probe = idx_probe(~isnan(idx_probe));
        idx_gallery = idx_gallery(~isnan(idx_gallery));
        
        featG = features(idx_gallery,:);
        featP = features(idx_probe,:);
        % Compute the cosine distance
        distMatrix = pdist2(featG,featP,'euclidean');

        % Nearest Neighbor (NN) classification
        [dist, pos] = sort(distMatrix);

        KCCA.trial(nt).rKCCA.dist = dist;
        KCCA.trial(nt).rKCCA.pos = pos;
    end
end



