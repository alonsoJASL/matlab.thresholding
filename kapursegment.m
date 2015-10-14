function [LEVEL, maxPhi] = kapursegment(I,q)
%                       KAPUR SEGMENTATION
% 

if nargin < 2
    q = 2;
end
I = double(I);
I = I./max(I(:));

I = im2uint8(I);

[n,x] = imhist(I);
N = numel(I);
p = n/N;

NP = 200;
Phi = zeros(1,NP);

k = sort(randi([x(2) x(end-1)], q, NP));

v = zeros(size(k));
gBest = 0;
pBest = zeros(size(k));
pBestValue = zeros(NP,1);
c1 = 1;
c2 = 1;
maxIter = 100;
count = 1;

while count <= maxIter
    
    for i=1:NP
        Phi(i) = imageHistEntropy(k(:,i),p);
    
        if pBestValue(i) < Phi(i)
            pBest(:,i) = k(:,i);
            pBestValue(i) = Phi(i);
        end
    end
    [gBest, whoBest] = max(pBestValue);
    
    for i=1:NP  
        v(:,i) = v(:,i) + c1*randi([0 1])*(pBest(:,i)-k(:,i)) + ...
            c2*randi([0 1])*(k(:,whoBest)-k(:,i));
        
        for j=1:length(k(:,i))
            if k(j,i) + v(j,i) < 0 || k(j,i) + v(j,i) > 255
                v(j,i) = 0;             
            end
        end            
            k(:,i) = k(:,i) + v(:,i);
            
            k(:,i) = sort(k(:,i));
            
    end
    count = count + 1;   
    %disp([count gBest]);
end

maxPhi = gBest;
LEVEL = k(:,whoBest);
