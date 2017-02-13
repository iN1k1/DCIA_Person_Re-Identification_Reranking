% Calculates the distance between sets of vectors.
% Script inherited from 
%       
%       Piotr's Image&Video Toolbox      Version 2.0
%       Copyright (C) 2007 Piotr Dollar.  [pdollar-at-caltech.edu]
%       Please email me if you find bugs, or have suggestions or questions!
%       Licensed under the Lesser GPL [see external/lgpl.txt]
%
%       and
%
%       Dahua Lin - slmetric_pw
%
% Let X be an m-by-p matrix representing m points in p-dimensional space
% and Y be an n-by-p matrix representing another set of points in the same
% space. This function computes the m-by-n distance matrix D where D(i,j)
% is the distance between X(i,:) and Y(j,:).  This function has been
% optimized where possible, with most of the distance computations
% requiring few or no loops.
%
% The metric can be one of the following:
%
%   - euclidean / sqeuclidean:
%       Euclidean / SQUARED Euclidean distance.  Note that 'sqeuclidean'
%       is significantly faster.
%
%   - chisq
%       The chi-squared distance between two vectors is defined as:
%           d(x,y) = sum( (xi-yi)^2 / (xi+yi) ) / 2;
%       The chi-squared distance is useful when comparing histograms.
%
%   - cosine
%       Distance is defined as the cosine of the angle between two vectors.
%
%   - emd
%       Earth Mover's Distance (EMD) between positive vectors (histograms).
%       Note for 1D, with all histograms having equal weight, there is a simple
%       closed form for the calculation of the EMD.  The EMD between histograms
%       x and y is given by the sum(abs(cdf(x)-cdf(y))), where cdf is the
%       cumulative distribution function (computed simply by cumsum).
%
%   - L1
%       The L1 distance between two vectors is defined as:  sum(abs(x-y));
%
%   - eucdist        Euclidean distance: 
%                       $ ||x - y|| $
%
%   - sqdist         Square of Euclidean distance: 
%                       $ ||x - y||^2 $
%
%   - dotprod        Canonical dot product: 
%                          $ <x,y> = x^T * y $ 
%
%   - nrmcorr        Normalized correlation (cosine angle):
%                          $ (x^T * y ) / (||x|| * ||y||) $
%
%   - corrdist       Normalized Correlation distance
%                          $ 1 - nrmcorr(x, y) $
%
%   - angle          Angle between two vectors (in radian)  
%                          $ arccos (nrmcorr(x, y)) $
%   - quadfrm        Quadratic form:  
%                          $ x^T * Q * y $
%                         Q is specified in the 1st extra parameter 
%
%   - quaddiff:       Quadratic form of difference:
%                          $ (x - y)^T * Q * (x - y) $
%                         Q is specified in the 1st extra parameter 
%
%   - cityblk:        City block distance (abssum of difference)
%                          $ sum_i |x_i - y_i| $
%
%   - maxdiff:        Maximum absolute difference  
%                          $ max_i |x_i - y_i| $
%
%   - mindiff:        Minimum absolute difference
%                          $ min_i |x_i - y_i| $
%
%   - minkowski:      Minkowski distance
%                          $ (\sum_i |x_i - y_i|^p)^(1/p) $
%                         The order p is specified in the 1st extra parameter
%
%   - wsqdist:        Weighted square of Euclidean distance     
%                          $ \sum_i w_i (x_i - y_i)^2 $
%                         the weights w is specified in 1st extra parameter 
%                         as a d x 1 column vector    
%
%   - hamming:        Hamming distance with threshold t
%                          \{
%                              ht1 = x > t
%                              ht2 = y > t
%                              d = sum(ht1 ~= ht2)                  
%                          \}
%                         use threshold t as the first extra param.
%                         (by default, t is set to zero).
%
%   - hamming_nrm:    Normalized hamming distance, which equals the
%                          ratio of the elements that differ.
%                          \{
%                              ht1 = x > t
%                              ht2 = y > t
%                              d = sum(ht1 ~= ht2) / length(ht1)                
%                          \}
%                          use threshold t as the first extra param.
%                         (by default, t is set to zero).
%
%   - intersect:      Histogram Intersection
%                           $ d = sum min(x, y) / min(sum(x), sum(y))$
%
%   - intersectdis:   Histogram intersection distance
%                           $ d = 1 - sum min(x, y) / min(sum(x), sum(y)) $
%
%   - kldiv:          Kull-back Leibler divergence
%                           $ d = sum x(i) log (x(i) / y(i)) $
%
%   - jeffrey:        Jeffrey divergence
%                           $ d = KL(h1, (h1+h2)/2) + KL(h2, (h1+h2)/2) $

% USAGE
%  D = NM_pdist( X, Y, [metric], otherPars )
%
% INPUTS
%  X        - [m x p] matrix of m p-dimensional vectors
%  Y        - [n x p] matrix of n p-dimensional vectors
%
% OUTPUTS
%  D        - [m x n] distance matrix
%
% EXAMPLE
%  [X,IDX] = demoGenData(100,0,5,4,10,2,0);
%  D = NM_pdist( X, X, 'sqeuclidean' );
%


function D = NM_pdist( X, Y, metric, varargin )

%% parse and verify input arguments
availableDistanceMetrics = {'sqeuclidean', 'euclidean', 'L1', 'cosine', 'emd', 'chisq', 'orid', ...
                            'eucdist', 'sqdist', 'dotprod', 'nrmcorr', 'corrdist', ...
                            'angle', 'quadfrm', 'quaddiff', 'cityblk', 'maxdiff', ...
                            'mindiff', 'minkowski', 'wsqdist', 'hamming', 'hamming_nrm', ...
                            'intersect', 'intersectdis', 'kldiv', 'jeffrey' };
if isempty(strmatch(metric, availableDistanceMetrics, 'exact'))
    error('nm_pdist:invalidMetric', 'Input argument (metrix) is not valid');
end
   
%narginchk(3, inf);
error(nargchk(3, inf, nargin));
builtin('assert', isa(X, class(Y)), 'nm_pdist:invalidarg', 'X and Y should be of the same class.');
if isempty(X) || isempty(Y)
    D = [];
    return;
end

switch metric
  case {0,'sqeuclidean'}
    D = distEucSq( X, Y );
  case 'euclidean'
    D = sqrt(distEucSq( X, Y ));
  case 'L1'    
    D = distL1( X, Y );
  case 'cosine'
    D = distCosine( X, Y );
  case 'emd'
    D = distEmd( X, Y );
  case 'chisq'
    D = distChiSq( X, Y );
  case 'orid'
    D = distOrientation( X, Y);   
  otherwise
    D = slmetric_pw(X', Y', metric, varargin);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = distOrientation(X, Y)

if size(X,2) == 1
    auxX = X;
    auxY = Y';
else
    auxX = X';
    auxY = Y;
end
D = zeros(size(auxX,1),size(auxX,1));
for i = 1:size(auxX,1)
    unwXY = unwrap([ones(1,size(auxX,1)).*auxX(i); auxY].*(pi/180)).*(180/pi);
    D(i,:) = abs(unwXY(2,:)-unwXY(1,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = distL1( X, Y )

m = size(X,1);  n = size(Y,1);
mOnes = ones(1,m); D = zeros(m,n);
for i=1:n
  yi = Y(i,:);  yi = yi( mOnes, : );
  D(:,i) = sum( abs( X-yi),2 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = distCosine( X, Y )

if( ~isa(X,'double') || ~isa(Y,'double'))
  error( 'Inputs must be of type double'); end;

p=size(X,2);
XX = sqrt(sum(X.*X,2)); X = X ./ XX(:,ones(1,p));
YY = sqrt(sum(Y.*Y,2)); Y = Y ./ YY(:,ones(1,p));
D = 1 - X*Y';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = distEmd( X, Y )

Xcdf = cumsum(X,2);
Ycdf = cumsum(Y,2);

m = size(X,1);  n = size(Y,1);
mOnes = ones(1,m); D = zeros(m,n);
for i=1:n
  ycdf = Ycdf(i,:);
  ycdfRep = ycdf( mOnes, : );
  D(:,i) = sum(abs(Xcdf - ycdfRep),2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = distChiSq( X, Y )

%%% supposedly it's possible to implement this without a loop!
%m = size(X,1);  n = size(Y,1);
%mOnes = ones(1,m); D = zeros(m,n);
%for i=1:n
%  yi = Y(i,:);  yiRep = yi( mOnes, : );
%  s = yiRep + X;    d = yiRep - X;
%  D(:,i) = sum( d.^2 ./ (s+eps), 2 );
%end
%D = D/2;
%D = NM_chi2dist(X',Y');
D = slmetric_pw(X',Y','chisq');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = distEucSq( X, Y )

%if( ~isa(X,'double') || ~isa(Y,'double'))
 % error( 'Inputs must be of type double'); end;
m = size(X,1); n = size(Y,1);
%Yt = Y';
XX = sum(X.*X,2);
YY = sum(Y'.*Y',1);
D = XX(:,ones(1,n)) + YY(ones(1,m),:) - 2*X*Y';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function D = distEucSq( X, Y )
%%%% code from Charles Elkan with variables renamed
% m = size(X,1); n = size(Y,1);
% D = sum(X.^2, 2) * ones(1,n) + ones(m,1) * sum(Y.^2, 2)' - 2.*X*Y';


%%% LOOP METHOD - SLOW
% [m p] = size(X);
% [n p] = size(Y);
%
% D = zeros(m,n);
% onesM = ones(m,1);
% for i=1:n
%   y = Y(i,:);
%   d = X - y(onesM,:);
%   D(:,i) = sum( d.*d, 2 );
% end


%%% PARALLEL METHOD THAT IS SUPER SLOW (slower then loop)!
% % From "MATLAB array manipulation tips and tricks" by Peter J. Acklam
% Xb = permute(X, [1 3 2]);
% Yb = permute(Y, [3 1 2]);
% D = sum( (Xb(:,ones(1,n),:) - Yb(ones(1,m),:,:)).^2, 3);


%%% USELESS FOR EVEN VERY LARGE ARRAYS X=16000x1000!! and Y=100x1000
% call recursively to save memory
% if( (m+n)*p > 10^5 && (m>1 || n>1))
%   if( m>n )
%     X1 = X(1:floor(end/2),:);
%     X2 = X((floor(end/2)+1):end,:);
%     D1 = distEucSq( X1, Y );
%     D2 = distEucSq( X2, Y );
%     D = cat( 1, D1, D2 );
%   else
%     Y1 = Y(1:floor(end/2),:);
%     Y2 = Y((floor(end/2)+1):end,:);
%     D1 = distEucSq( X, Y1 );
%     D2 = distEucSq( X, Y2 );
%     D = cat( 2, D1, D2 );
%   end
%   return;
% end
