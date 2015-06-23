function [Phi, H] = imageHistEntropy(k, p)
%                     IMAGE HISTOGRAM ENTROPY
% 
% Image entropy calculator for the Kapur's method of histogram entropy. It
% doesn't consider any other input other than the image to analyse and the 
% $p$ levels set by vector $k \in \mathb{R}^p$. 
%
% Optionally, it also returns the values for vector H of individual 
% entropies depending on the number of levels. 
% 
% usage: 
%       (1) [Phi] = imageHistEntropy(k, p)
%       (2) [Phi, H] = imageHistEntropy(k, p)
% 
% input: 
%           k := (integer) Scalar (or vector) containing the levels 
%           (between min(L) and max(L)) that have been selected to serve
%           the segmentation. The vector k will be sorted. The value of k
%           should be between 1:length(L), so that L(k*) is the threshold.
%           p := (double) Probabilities of the numel(M) levels of the 
%           image matrix.
%
% output: 
%         Phi := Full entropy computed by the Phi(k) = sum(H(Ai)).
%           H := (OPTIONAL) Vector of the individual entropies for each of
%           the p values in k.
%
% 
%
% Jose Alonso Solis-Lemus (2015)
%

if nargin ~= 2
    help imageHistEntropy
    Phi = [];
    H = [];
    return 
end

nC = length(k)+1;
L = length(p);
h = zeros(nC,1);

for i=1:nC
    if i==1
        low = 1;
        high = k(1);
    elseif i==nC
        low = k(i-1)+1;
        high = L;
    else 
        low = k(i-1)+1;
        high = k(i);
    end
    Pk = sum(p(low:high));
    pP = p(low:high)./Pk;
    pP = pP(pP~=0);
    h(i) = - pP'*log(pP);
    
end

Phi = sum(h);
if nargout > 1
    H = h;
end

