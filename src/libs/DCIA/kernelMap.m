function [normalized_map] = kernelMap(imageSize,kernel)

H = imageSize(1);
W = imageSize(2);
map = ones(H,W);

if strcmp(kernel.type,'Gaussian')
    [xx,yy] = meshgrid(1:W,1:H);
    xx = xx(:);
    yy = yy(:);
    map = mvnpdf([xx,yy],kernel.mean,kernel.cov);
    map = reshape(map,[H,W]); 
end

normalized_map  = (map - min(min(map(:))) + realmin) ./ (max(max(map(:)))-min(min(map(:))));