function [KCCA] = modelTest(modelParam, split, algo, trainFlag)


AlgoOption = modelParam.AlgoOption;
allFeatures = modelParam.allFeatures;
nTrial = modelParam.nTrial;


for nt=1:nTrial
    
   % TEST
   % Each algorithm gives back the following data for each trial indexed by
   % nt:
   %
   % - dists is a matrix of size NUM_PROBE_PERSONS x NUM_GALLERY_PERSONS
   %    containing the distance between each of them
   % - id_probe is of size NUM_PROBE_PERSONS x 1
   %    each row is the ID of the probe person
   % - rank_ids is of size NUM_PROBE_PERSONS x NUM_GALLERY_PERSONS
   %    where for each PROBE PERSON the IDs of the gallery persons are
   %    sorted according to the distance to the probe.
   % 
   % For instance:
   % i = 1;
   % ID = id_probe(i) is the ID of the probe person
   % dists(i,:) is the distance between the person with id ID in ascending
   % order. That is dist(i,1) < dist(i,2) < dist(i,3), ....
   % rank_ids(i,:) gives the gallery IDs ranked in ascending order. That is
   % rank_ids(i,1) is the ID of the gallery person that is rank first.
   if trainFlag
       
       test2 = split.test22;
       
       % Get train and test partitions
       test_ids = test2(nt).ID;

       [~, ~, ~, testFeatures, test_idx_pair] = get_train_test_data(allFeatures, [], test2(nt));
       switch AlgoOption.func
            case {'svmml'}
                [dists, pos, ~, ~] = compute_rank_svmml(algo, testFeatures, test_idx_pair, test_ids);
            case {'KISSME'}
                [dists, pos, ~, ~] = compute_rank_KISSME(algo, testFeatures, test_idx_pair, test_ids);
            otherwise
                error('Invalid Method');
       end
   else
       
       test = split.test2;
       
       
       % Get train and test partitions
       test_ids = test(nt).ID;

       [~, ~, ~, testFeatures, test_idx_pair] = get_train_test_data(allFeatures, [], test(nt));
       
       switch AlgoOption.func
            case {'svmml'}
                [dists, pos, ~, ~] = compute_rank_svmml(algo, testFeatures, test_idx_pair, test_ids);
            case {'KISSME'}
                [dists, pos, ~, ~] = compute_rank_KISSME(algo, testFeatures, test_idx_pair, test_ids);
            otherwise
               error('Invalid Method');
       end
   end
   
   KCCA.trial(nt).rKCCA.dist = dists';
   KCCA.trial(nt).rKCCA.pos = pos';
   
end