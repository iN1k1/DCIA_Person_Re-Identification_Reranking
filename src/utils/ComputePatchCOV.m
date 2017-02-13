% calculate the covariance matrix for each region of the input images.
% By Fei Xiong, 
%    ECE Dept, 
%    Northeastern University 
%    2013-11-04
% Input: 
%       I is the inuput RGB image. H*W*3
%       region: the pixel index for each region.
%       option is the struct contains the flag indicating which feature
%           channel is required to be computed.
% Output:
%       COV: the vectorized covariance matrix of each region of the input
%           image. Each row corresponds to the covariance matrix of a
%           region.
%       feature_list: the name of feature channels used to compute the covariance matrix.
function [COV, feature_list] = ComputePatchCOV(I, region, option)

Img=[];
Ihsv=[];

Ihsv=[];
Iycrcb=[];
Igradg=[];
Igradrgb = [];
Igradycrcb= [];
Igradhs=[];
delta = 1e-8;
    if option.YCrCb
        Iycrcb = colorspace('YCbCr<-RGB', I);
    end

    if option.HSV
        Ihsv = double(rgb2hsv(I));
        Ihsv = Ihsv(:,:,1:2);
    end
    
    if option.gradGray
        Igrad = zeros(size(I,1)*size(I,2),2);
        [Gx,Gy]= imgradientxy(rgb2gray(I));
        Igrad(:,1) = Gx(:);
        Igrad(:,2) = Gy(:);
        Igradg = int16(Igrad);
    end
    
    if option.gradRGB
        for j =1:3
            [Gx,Gy]= imgradientxy(I(:,:,j));
            Igradrgb(:,j*2-1) = Gx(:);
            Igradrgb(:,j*2) = Gy(:);
        end
    end
    
    if option.gradYCrCb
        for j =1:3
            [Gx,Gy]= imgradientxy(I(:,:,j));
            Igradycrcb(:,j*2-1) = Gx(:);
            Igradycrcb(:,j*2) = Gy(:);
        end
    end
    
    if option.gradHS
        for j =1:2
            [Gx,Gy]= imgradientxy(Ihsv(:,:,j));
            Igradhs(:,j*2-1) = Gx(:);
            Igradhs(:,j*2) = Gy(:);
        end
    end    
%     if option.rgbn
%         Irgbn{i,1} = double(I)./ (repmat(double(sum(I,3)),[1,1,3]) + delta);
%     end
%     
%     if option.logc
%         Ilogc{i,1}(:,:,1) = log(double(I(:,:,1))./ (double(I(:,:,2))+ delta));
%         Ilogc{i,1}(:,:,2) = log(double(I(:,:,3))./ (double(I(:,:,2))+ delta));
%     end
    

[X, Y]= meshgrid(1:size(I,2), 1:size(I,1));
% [X Y R G B H S Y Cr Cb GrayGX GrayGY RGX RGY GGX GGY BGX BGY
% HGX HGY SGX SGY YGX YGY CrGX CrGY CbGX CbGY]
feature_list ={ 'X', 'Y', 'R', 'G', 'B', 'H', 'S', 'Y', 'Cr', 'Cb',...
    'GrayGX', 'GrayGY', 'RGX', 'RGY', 'GGX', 'GGY', 'BGX', 'BGY',...
    'HGX', 'HGY', 'SGX', 'SGY', 'YGX', 'YGY', 'CrGX', 'CrGY', 'CbGX', 'CbGY'};
feat =double([X(:), Y(:), double(reshape(I,[],size(I,3))),double(reshape(Ihsv,[],size(Ihsv,3))),...
    double(reshape(Iycrcb,[],size(Iycrcb,3))), Igradg, Igradrgb,Igradhs, Igradycrcb]);


for i =1 : length(region)
    temp = cov(feat(region{i}, :));
    % make sure Semipositive Definite
    temp = (temp+temp')/2;
    [U V]=eig(temp);
    v= diag(V); v(v<0)=0; V = diag(v);
    temp =U*V*U';
    temp = (temp+temp')/2;
    COV(i, :) = single(temp(:));
end
return;