function [kfeatMatch, gfeatMatch, pGalleryIdx, pGalleryIDs] = ...
generateListsToRanking(probe, match, idx, IDs, features, VEDataProbe, VEDataGallery)

%kfeatMatch = features(match,:);
kfeatMatch = VEDataGallery(match,:);

pGalleryIdx = idx(:,2);
pGalleryIDs = IDs(:);

pos = find(pGalleryIdx==match);
pGalleryIdx(pos(:)) = idx(probe,1);
pGalleryIDs(pos(:)) = IDs(probe);

%gfeatMatch = features(pGalleryIdx,:);
gfeatMatch = features(pGalleryIdx,:);
gfeatMatch(pos(:),:) = VEDataProbe(idx(probe,1),:);


