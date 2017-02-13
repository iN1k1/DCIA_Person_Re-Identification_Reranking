% calculate the histogram and moment for each region of the images.
% By Fei Xiong, 
%    ECE Dept, 
%    Northeastern University 
%    2013-11-04
% Input: 
%       I is the inuput RGB image. H*W*3
%       region_idx: the pixel index for each region.
%       BBox: the bounding boxes in the image, each row is in the format of
%          [x_topleft y_topleft x_rightbottom y_rightbottom].
%       option is the struct contains the flag indicating which feature
%           channel is required to be computed.
% Output:
%       F: the vectorized covariance matrix of each region of the input
%           image. Each row corresponds to the covariance matrix of a
%           region.
%       feature_list: the name of feature channels used to compute the covariance matrix.

function [F, feature_idx] = ComputePatchHistogramMoment(I, region_idx,BBox, nbin)
F=[];
ix_feat =0;
% RGB Channel
Irgb = reshape(double(I),[],3);
for i =1:length(region_idx)
    F(:, (i-1)*3+ix_feat+[1:3]) = hist(Irgb(region_idx{i},:), 0:256/nbin:255);
    FL(:,(i-1)*3+ix_feat+[1:3]) = repmat([1:3], nbin, 1); % feature channel label
end


ix_feat =size(F,2);
% YUV/YCbCr channel
Iyuv =rgb2ycbcr(uint8(I));
Iyuv = double(reshape(Iyuv,[],3));
for i =1:length(region_idx)
    F(:, (i-1)*3+ix_feat+1) = hist(Iyuv(region_idx{i},1), 16:((235-15)/nbin):235);
    F(:, (i-1)*3+ix_feat+[2:3]) = hist(Iyuv(region_idx{i},2:3), 16:((240-15)/nbin):240);
    FL(:,(i-1)*3+ix_feat+[1:3]) = repmat([7:9], nbin, 1); % feature channel label
end

ix_feat =size(F,2);
% HSV Channel
Ihsv =rgb2hsv(uint8(I));
Ihsv = double(reshape(Ihsv,[],3));
for i =1:length(region_idx)
    F(:, (i-1)*3+ix_feat+[1:3]) = hist(Ihsv(region_idx{i},:), 1e-5:1/nbin:1);
    FL(:,(i-1)*3+ix_feat+[1:3]) = repmat([10:12], nbin, 1); % feature channel label
end

ix_feat =size(F,2);
F= bsxfun(@times, F, 1./sum(F)); % normalization
F= F(:);
% extract the feature index for each feature channels
FL=FL(:);
ix_feat =size(F,1);
feature_idx.RGBr= find(FL==1); feature_idx.RGBg= find(FL==2); feature_idx.RGBb= find(FL==3);
feature_idx.YUVy= find(FL==7); feature_idx.YUVu= find(FL==8); feature_idx.YUVv= find(FL==9);
feature_idx.HSVh= find(FL==10); feature_idx.HSVs= find(FL==11); feature_idx.HSVv= find(FL==12);

% extract the LBP histogram
k=1;
LBP_Mapping(k) = getmapping(8,'u2'); LBPname{k}= 'n8u2'; k= k+1;
% option.LBP_Mapping(k) = getmapping(8,'ri'); LBPname{k}= 'n8ri'; k= k+1;
LBP_Mapping(k) = getmapping(8,'riu2'); LBPname{k}= 'n8riu2'; k= k+1;
LBP_Mapping(k) = getmapping(16,'u2'); LBPname{k}= 'n16u2'; k= k+1;
% option.LBP_Mapping(k) = getmapping(16,'ri'); LBPname{k}= 'n16ri'; k= k+1;
LBP_Mapping(k) = getmapping(16,'riu2'); LBPname{k}= 'n16riu2'; k= k+1;

Igray =rgb2gray(uint8(I));
for k =1: length(LBP_Mapping)
    for r =1:3
        % For the 8 neighbors LBP, extract the histogram with radius 1, 2
        % and 3.
        % For the 16 neighbors LBP, extract the histogram with radius 2, 3
        % and 4.
        switch LBP_Mapping(k).samples
            case 8
                radius = r;
            case 16
                radius = r+1;
        end
        lbpname = [ LBPname{k} 'r' num2str(radius)];
        ix_st =size(F,1);
        if min(abs(BBox(1,[1 2]) - BBox(1,[3 4]) + 1)/2) < radius
            ix_end = ix_st-1;
        else
            for i =1:size(BBox,1)
                F(ix_feat+[1:LBP_Mapping(k).num]) = lbp(Igray(BBox(i,2):BBox(i,4), BBox(i,1):BBox(i,3),:),radius,LBP_Mapping(k).samples,LBP_Mapping(k),'nh')';
                ix_feat =size(F,1);
            end
            ix_end = size(F,1);
        end
        feature_idx = setfield(feature_idx,lbpname,[(ix_st+1):ix_end]');
    end
end

% Extract the first 3 order moment
% RGB channel
FL=zeros(size(F));
for i =1:length(region_idx)
    ix_feat =size(F,1);
    Irgb = double(Irgb);
    mrgb = mean(Irgb(region_idx{i},:));
    F(ix_feat+[1:3]) =  mrgb;
    F(ix_feat+[4:6]) =  std(Irgb(region_idx{i},:));
    IrgbM3 = bsxfun(@minus, Irgb(region_idx{i},:), mrgb);
    IrgbM3 = mean(IrgbM3.^3);
    F(ix_feat+[7:9]) =  nthroot(IrgbM3,3);
    FL(ix_feat+[1:9]) = [1 1 1 2 2 2 3 3 3];
end
feature_idx.RGBm1= find(FL==1); feature_idx.RGBm2= find(FL==2); feature_idx.RGBm3= find(FL==3);

% YUV channel
FL=zeros(size(F));
for i =1:length(region_idx)
    ix_feat =size(F,1);
    myuv = mean(Iyuv(region_idx{i},:));
    F(ix_feat+[1:3]) =  myuv;
    F(ix_feat+[4:6]) =  std(Iyuv(region_idx{i},:));
    IyuvM3 = bsxfun(@minus, Iyuv(region_idx{i},:), myuv);
    IyuvM3 = mean(IyuvM3.^3);
    F(ix_feat+[7:9]) =  nthroot(IyuvM3,3);
    FL(ix_feat+[1:9]) = [1 1 1 2 2 2 3 3 3];
end
feature_idx.YUVm1= find(FL==1); feature_idx.YUVm2= find(FL==2); feature_idx.YUVm3= find(FL==3);

% HSV channel
FL=zeros(size(F));
for i =1:length(region_idx)
    ix_feat =size(F,1);
    mhsv = mean(Ihsv(region_idx{i},:));
    F(ix_feat+[1:3]) =  mhsv;
    F(ix_feat+[4:6]) =  std(Ihsv(region_idx{i},:));
    IhsvM3 = bsxfun(@minus, Ihsv(region_idx{i},:), mhsv);
    IhsvM3 = mean(IhsvM3.^3);
    F(ix_feat+[7:9]) =  nthroot(IhsvM3,3);
    FL(ix_feat+[1:9]) = [1 1 1 2 2 2 3 3 3];
end
feature_idx.HSVm1= find(FL==1); feature_idx.HSVm2= find(FL==2); feature_idx.HSVm3= find(FL==3);
return;