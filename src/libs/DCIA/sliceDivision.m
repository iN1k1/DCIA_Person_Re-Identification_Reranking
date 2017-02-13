function [area] = sliceDivision(imgSize,sliceNumber)

area = zeros(sliceNumber,4); 
sliceWidth = round(imgSize(1)/sliceNumber);
for i = 1:sliceNumber
    area(i,:) = [1+sliceWidth*(i-1) 1 1+sliceWidth*(i)-1 imgSize(2)];
end