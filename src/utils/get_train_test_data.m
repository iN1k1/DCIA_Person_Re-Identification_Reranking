function [trainFeatures, train_ids_new, train_idx_pair, testFeatures, test_idx_pair] = get_train_test_data(allFeatures, train, test)
   
trainFeatures = [];
train_ids_new = [];
train_idx_pair = [];
testFeatures = [];
test_idx_pair = [];
    
if ~isempty(train)
    train_ids = train.ID;
    train_idx_pair = train.index;
end
if ~isempty(test)
    test_ids = test.ID;
    test_idx_pair = test.index;
end
 
if ~isempty(train)
    
    % Training feats
    [idx_train_camA,ia] = unique(train_idx_pair(:,1), 'stable');
    [idx_train_camB,ib] = unique(train_idx_pair(:,2), 'stable');
    train_ids_new = [train_ids(ia,1); train_ids(ib,2)];
    trainFeatures = allFeatures(:,[idx_train_camA idx_train_camB]);

    counter = 1;
    train_idx_pair_new = zeros(size(train_idx_pair));
    for idx=idx_train_camA'
       ix = train_idx_pair(:,1) == idx; 
       train_idx_pair_new(ix,1) = counter;
       counter = counter + 1;
    end
    for idx=idx_train_camB'
       ix = train_idx_pair(:,2) == idx; 
       train_idx_pair_new(ix,2) = counter;
       counter = counter + 1;
    end
    train_idx_pair = train_idx_pair_new;
    clear train_idx_pair_new;
end

if ~isempty(test)
    % Test feats
    [idx_test_camA, ia] = unique(test_idx_pair(:,1), 'stable');
    [idx_test_camB, ib] = unique(test_idx_pair(:,2), 'stable');
    testFeatures = allFeatures(:,[idx_test_camA; idx_test_camB]); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

    counter = 1;
    test_idx_pair_new = zeros(size(test_idx_pair));
    for idx=idx_test_camA'
       ix = test_idx_pair(:,1) == idx; 
       test_idx_pair_new(ix,1) = counter;
       counter = counter + 1;
    end
    for idx=idx_test_camB'
       ix = test_idx_pair(:,2) == idx; 
       test_idx_pair_new(ix,2) = counter;
       counter = counter + 1;
    end
    test_idx_pair = test_idx_pair_new;
    clear test_idx_pair_new;

end
