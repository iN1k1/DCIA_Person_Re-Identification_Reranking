function [result] = slcHist(dataMatrix,kernel,slices,nbins,excludeRange,normalize)

result = [];
for i = 1:size(slices,1)
    slcData = dataMatrix(slices(i,1):slices(i,3),slices(i,2):slices(i,4));
    slcKernel = kernel(slices(i,1):slices(i,3),slices(i,2):slices(i,4));
    dataVec = reshape(slcData,1,[]);
    kernelVec = reshape(slcKernel,1,[]);
    dataVec(dataVec>=excludeRange(1) & dataVec<=excludeRange(2)) = -inf;
    [histw, ~] = histwc(dataVec(dataVec>-inf), kernelVec(dataVec>-inf), nbins);
    histw(end-1) = histw(end-1) + histw(end);
    histw(end) = [];
    if normalize
        normalizedHistw = histw/norm(histw,1);
        result = [result normalizedHistw'];
    else
        result = [result histw'];
    end
end

end