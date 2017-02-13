function [dists, sort_idx, id_probe, rank_ids] = compute_rank_KISSME(Method,X,test_idx_pairs,test_ids)


idx_probe = unique(test_idx_pairs(:,1),'stable');
idx_gallery = unique(test_idx_pairs(:,2),'stable');
D = zeros(length(idx_probe),length(idx_gallery));

featsProbe = X(:,idx_probe);
featsGallery = X(:,idx_gallery);

M = Method.ds.kissme.M;
D = sqdist(featsProbe, featsGallery ,M);
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
