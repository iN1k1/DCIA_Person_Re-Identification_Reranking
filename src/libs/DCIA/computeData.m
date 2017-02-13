function [data] = computeData(img,mask,kernel,slices,torso,legs,config)

data = [];

% RGB color space
if config.RGB.enabled
    imgData = im2double(img);
    imgData = eqHist(imgData,config.RGB.histOp);
    imgData = imMasked(imgData,mask);
    binEdges = NM_hist_bin_edges(config.RGB.bins, 'RGB');
    for i = 1:length(config.RGB.channels)
        if strcmp(config.RGB.channels(i),'1')
            h = slcHist(imgData(:,:,i),kernel,slices,binEdges{i},config.RGB.excludeRange,config.RGB.normalize);
            data = [data h]; 
        end
    end
end
% HSV color space
if config.HSV.enabled
    imgData = colorspace('HSV<-RGB',im2double(img));
    imgData = eqHist(imgData,config.HSV.histOp);
    imgData = imMasked(imgData,mask);
    binEdges = NM_hist_bin_edges(config.HSV.bins, 'HSV');
    for i = 1:length(config.HSV.channels)
        if strcmp(config.HSV.channels(i),'1')
            h = slcHist(imgData(:,:,i),kernel,slices,binEdges{i},config.HSV.excludeRange,config.HSV.normalize);
            data = [data h]; 
        end
    end
end
% Lab color space
if config.Lab.enabled
    imgData = colorspace('Lab<-RGB',im2double(img));
    imgData = eqHist(imgData,config.Lab.histOp);
    imgData = imMasked(imgData,mask);
    binEdges = NM_hist_bin_edges(config.Lab.bins, 'Lab');
    for i = 1:length(config.Lab.channels)
        if strcmp(config.Lab.channels(i),'1')
            h = slcHist(imgData(:,:,i),kernel,slices,binEdges{i},config.Lab.excludeRange,config.Lab.normalize);
            data = [data h]; 
        end
    end
end
% PHOG
if config.phog.enabled
    if config.phog.evaluateDifferentChannels == false
        imgData = im2double(rgb2gray(img));
    else
        %imgData = colorspace('HSV<-RGB',im2double(img));
        imgData = im2double(img);
    end
    imgData = eqHist(imgData,config.phog.histOp);
    for i=1:size(imgData,3)
        h = anna_phog(imgData(:,:,i), config.phog.bin, config.phog.angle, config.phog.levels, [torso(2);torso(4);torso(1);torso(3)]);
        data = [data h'];
    end
    for i=1:size(imgData,3)
        h = anna_phog(imgData(:,:,i), config.phog.bin, config.phog.angle, config.phog.levels, [legs(2);legs(4);legs(1);legs(3)]);
        data = [data h'];
    end
end
% LBP
if config.lbp.enabled
    %imgData = colorspace('HSV<-RGB',im2double(img));
    imgData = im2double(img);
    imgData = eqHist(imgData,config.lbp.histOp);
    mapping = getmapping(config.lbp.points,config.lbp.mapping);
    dataT = imgData(torso(2):torso(4),torso(1):torso(3),:);
    h = lbp(dataT, config.lbp.radius, config.lbp.points, mapping,'nh');
    data = [data h];
    dataL = imgData(legs(2):legs(4),legs(1):legs(3),:);
    h = lbp(dataL, config.lbp.radius, config.lbp.points, mapping,'nh');
    data = [data h];
end

data(isnan(data)) = 0;

end

function [outImg] = eqHist(inImg,histOp)

if size(inImg, 3) == 3
    switch histOp
        case 'eq'
            imgHSV = colorspace('HSV<-RGB',inImg);
            imgHSV = cat(3,imgHSV(:,:,1),imgHSV(:,:,2),histeq(imgHSV(:,:,3)));
            outImg = colorspace('HSV<-HSV',imgHSV);
        case 'norm'
            imgHSV = colorspace('HSV<-RGB',inImg);
            image = imgHSV(:,:,3);
            minIntensity = min(image(:));
            range = max(image(:)) - minIntensity;
            imgHSV(:,:,3) = (image-minIntensity) / range;
            imgHSV = cat(3,imgHSV(:,:,1),imgHSV(:,:,2),imgHSV(:,:,3));
            outImg = colorspace('HSV<-HSV',imgHSV);
        case 'norm-eq'
            imgHSV = colorspace('HSV<-RGB',inImg);
            image = imgHSV(:,:,3);
            minIntensity = min(image(:));
            range = max(image(:)) - minIntensity;
            imgHSV(:,:,3) = (image-minIntensity) / range;
            imgHSV = cat(3,imgHSV(:,:,1),imgHSV(:,:,2), histeq(imgHSV(:,:,3)));
            outImg = NM_colorconverter(imgHSV, 'HSV', outputColorSpace);             
        otherwise
            outImg = inImg;            
    end
end

end

function [outImg] = imMasked(inImg,mask)

if size(inImg,3) == 3
    ch1 = inImg(:,:,1);
    ch2 = inImg(:,:,2);
    ch3 = inImg(:,:,3);
    ch1(mask==0) = -inf;
    ch2(mask==0) = -inf;
    ch3(mask==0) = -inf;
    outImg = cat(3,ch1,ch2,ch3);
else
    ch1 = inImg(:,:,1);
    ch1(mask==0) = -inf;
    outImg = ch1;
end

end

function [binEdges] = NM_hist_bin_edges(bins, imageColorSpace)
%NM_HIST_BIN_EDGES Summary of this function goes here
% 
% [OUTPUTARGS] = NM_HIST_BIN_EDGES(INPUTARGS) Explain usage here
% 
% Examples: 
% 
% Provide sample usage code here
% 
% See also: List related files here

% Author:    Niki Martinel
% Date:      2013/08/19 14:08:48
% Revision:  0.1
% Copyright: Niki Martinel, 2013

% If Lab color space is selected color histogram bins 
% should be set to a range that include negative values. 
% According to the Lab color space definition image can have positive and
% negative values for a* and b*.
if strcmpi(imageColorSpace, 'Lab') == 1
    binEdges{1} = 0:(100/bins(1)):100;
    binEdges{2} = -128:(256/bins(2)):128;
    binEdges{3} = -128:(256/bins(3)):128;
%elseif strcmpi(imageColorSpace, 'LCH') == 1
%    binEdges{1} = 0:(100/bins(1)):100;
%    binEdges{2} = 0:(100/bins(2)):100;
%    binEdges{3} = 0:(360/bins(3)):360;
elseif any(strcmpi(imageColorSpace, {'HSV', 'HSL', 'HSI'})) == 1
    binEdges{1} = 0:(360/bins(1)):360;
    binEdges{2} = 0:(1/bins(2)):1;
    binEdges{3} = 0:(1/bins(3)):1;
elseif strcmpi(imageColorSpace, 'YCbCr') == 1
    binEdges{1} = 16:(219/bins(1)):235;
    binEdges{2} = 16:(224/bins(2)):240;
    binEdges{3} = 16:(224/bins(3)):240;
elseif strcmpi(imageColorSpace, 'Luv') == 1
    binEdges{1} = 0:(100/bins(1)):100;
    binEdges{2} = -134:(256/bins(2)):220;
    binEdges{3} = -140:(256/bins(3)):122;
elseif strcmpi(imageColorSpace, 'YPbPr') == 1
    binEdges{1} = 0:(1/bins(1)):1;
    binEdges{2} = -0.5:(1/bins(2)):0.5;
    binEdges{3} = -0.5:(1/bins(3)):0.5;
%elseif strcmpi(imageColorSpace, 'YUV') == 1
%    binEdges{1} = 16:(1/bins(1)):235;
%    binEdges{2} = -0.45:(0.9/bins(2)):0.45;
%    binEdges{3} = -0.65:(1.3/bins(3)):0.65;  
%elseif strcmpi(imageColorSpace, 'XYZ') == 1
%    binEdges{1} = 0:(95/bins(1)):95;
%    binEdges{2} = 0:(100/bins(2)):100;
%    binEdges{3} = 0:(110/bins(3)):110;
else
    binEdges{1} = 0:(1/bins(1)):1;
    binEdges{2} = 0:(1/bins(2)):1;
    binEdges{3} = 0:(1/bins(3)):1;
end

end


