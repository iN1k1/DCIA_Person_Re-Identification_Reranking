function [D,md] = kernel_expchi2(X,Y,omega)
    
  D = zeros(size(X,1),size(Y,1));
  parfor i=1:size(Y,1)
    d = bsxfun(@minus, X, Y(i,:));
    s = bsxfun(@plus, X, Y(i,:));
    D(:,i) = sum(d.^2 ./ (s+eps), 2);
  end
	
  md = mean(mean(D));
  
  if nargin < 3
    omega = md;
  end
	
  D = exp( - 1/(2*omega) .* D);