function [cmc] = compute_CMC(id_probe, rank_ids)

match = zeros(1, size(rank_ids,2));
for p=1:length(id_probe)

    id_gallery = rank_ids(p,:);
    
    rank = find(id_gallery == id_probe(p));
    match(rank) = match(rank) + 1;
    
end

cmc = 100 * (cumsum(match) / size(rank_ids,1));

end