% Calculate the distance between two covariance matrix via generalized
% eigenvalue decomposition
% By Fei Xiong, 
%    ECE Dept, 
%    Northeastern University 
%    2013-11-04
% X1 : The vectorized covariance matrices. Each row is a vectorized covariance matrix. 
% X2 : The vectorized covariance matrices. Each row is a vectorized covariance matrix.
% d  : The distance vector between 2 set of  covariance matrix. d(i)
% contains the distance between the i-th covariance in X1 and X2.
function [d] = Compute_COV_Distance(X1,X2)
covsz= sqrt(size(X1,2));
for i =1:size(X1,1)
    C1 =double(reshape(X1(i,:),covsz, covsz));
    C2 =double(reshape(X2(i,:),covsz, covsz));
    C1 = (C1+C1')/2;
    C2 = (C2+C2')/2;
    ln_ev = abs(eig(C1,C2+1e-10*eye(28)));
    if sum(isnan(ln_ev))>0 || sum(isinf(ln_ev))>0
        warning('singular matrix')
    end
    ln_ev = ln_ev(~isinf(ln_ev));
    ln_ev = log2(ln_ev);
    d(i) = single(sqrt(sum(ln_ev.^2)));
end
return;