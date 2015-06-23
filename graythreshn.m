function [LEVEL, maxSIG] = graythreshn(I,q)
%                        GRAYTHRESH N
% Global image multiple threshold selection using Otsu's method.
%
% usage:
%

if nargin < 2
    q = 2;
end

[n,x] = imhist(I);
N = numel(I);
p = n/N;

NP = 200;
SIGB = zeros(1,NP);

k = sort(randi([x(2) x(end-1)], q, NP));

v = zeros(size(k));
gBest = 0;
pBest = zeros(size(k));
pBestValue = zeros(NP,1);
c1 = 1;
c2 = 1;
maxIter = 100;
count = 1;

%countMax = 0;
while count <= maxIter% && countMax <= 10
    for i=1:NP
       
        [w,u,~] = setvalues(k(:,i),p);
        
        uT = w'*u;
    
        %siW = w'*si;
        SIGB(i) = w'*(u-uT).^2;
            
        if pBestValue(i) < SIGB(i)
            pBest(:,i) = k(:,i);
            pBestValue(i) = SIGB(i);
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
LEVEL = k(:,whoBest);
maxSIG = gBest;

end


function [W, U, SIG] = setvalues(k,p)

nC = length(k) +1;
L = length(p);
w = zeros(nC,1);
u = zeros(nC,1);
sig = zeros(nC,1);

for i=1:nC
    if i==1
        low = 1;
        high = k(1);
    elseif i==nC
        low = k(i-1) + 1;
        high = L;
    else
        low = k(i-1)+1;
        high = k(i);
    end
   
    w(i) = sum(p(low:high));

    J = (low:high)';
    PW = p(low:high) ./ w(i);
        
    u(i) = J'*PW;
    sig(i) = (J-u(i)).^2'*(p(low:high)./w(i));
    
end

W = w;
U = u;
SIG = sig;
end


