function [IDX] = adaptiveClustering(I, k)
%       ADAPTIVE CLUSTERING SEGMENTATION
%
% Adaptive clustering for image segmentation. It works with the algorithm
% proposed by Pappas et. al (1992). One give an image and the number of
% classes the image is going to be segmented on.
%
% USAGE:
%       (1) IDX = adaptiveClustering(I,k)
%       (2) IDX = adaptiveClustering(fname, k)
%
% INPUT (1):
%           I := Image matrix.
%           k := (int) number of classses
% INPUT (2):
%       fname := (string) Path to image file.
%           k := (int) number of classes.
%
% OUTPUT:
%         IDX := segmented matrix with labels from 1 to k.
%
%
% -----------------------------------------------------------------------
% Jose Alonso Solis-Lemus (2015)
%

if k < 2
    fprintf('%s: ERROR, a number of classes must be specified.\n', mfilename);
    IDX = [];
    return;
end

if ischar(I)
    X = imread(I);
    if size(X,3) > 1
        X = rgb2gray(X);
    end
else
    if size(I,3) > 1
        X = rgb2gray(I);
    else
        X = I;
    end
end
X = double(X);

%initial segmentation (we use Otsu's method because YOLO)
XQ = imquantize(X,multithresh(X, k-1));
newXQ = XQ;

W = size(X);
M = W(1); N = W(2);

Ui = zeros(M, N, k);
sig = var(X(:));
bet = mean(X(:))/sqrt(sig);
%
Wmin = 7;
n = 1;
nmax = 10;
nChanges = numel(X);
nConvergence = sqrt(prod(W))/10;

while sqrt(prod(W)) > Wmin
    while nChanges >= nConvergence && n <= nmax
        
        a = floor(W(1)/2);
        b = floor(W(2)/2);
        r = floor(M/a);
        q = floor(N/b);
        
        x = (0:r).*a + 1;
        y = (0:q).*b + 1;
        
        if r*a + 1 < M
            x(end+1) = M;
        elseif r*a + 1 > M
            x(end) = M;
        end
        if q*b + 1 < N
            y(end+1) = N;
        elseif q*b + 1 > N
            y(end) = N;
        end
        miniUi = zeros(length(x), length(y), k);
        %
        for i=1:length(x)
            testi = (i>1) + 10*(i<length(x));
            switch testi
                case 1 % x(i)=M
                    windx = x(i-1):M;
                case 10 % i=1
                    windx = 1:x(i+1);
                case 11 % i>1 && x(i)<M
                    windx = x(i-1):x(i+1);
            end
            for j=1:length(y)
                testj = (j>1) + 10*(j<length(y));
                switch testj
                    case 1 % j=N
                        windy = y(j-1):N;
                    case 10 % i=1
                        windy = 1:y(j+1);
                    case 11 % i>1 && i<M
                        windy = y(j-1):y(j+1);
                end
                WIN = X(windx,windy);
                WINQ = XQ(windx, windy);
                
                for i1=1:k
                    miniUi(i,j,i1) = mean(WIN(WINQ==i1));
                end
            end
            
        end
        %
        [xx1, yy1] = meshgrid(linspace(1,N,length(y)),...
            linspace(1,M,length(x)));
        [xx2, yy2] = meshgrid(1:N,1:M);
        miniUi(isnan(miniUi)) = 0;
        Uxs = zeros(M,N);

        for i1=1:k
            Ui(:,:,i1) = interp2(xx1, yy1, miniUi(:,:,i1), xx2,yy2);
        end
        for i=1:M
            testi = (i>1) + 10*(i<M);
            switch testi
                case 1
                    windx = M-1:M;
                case 10
                    windx = 1:2;
                case 11
                    windx = i-1:i+1;
            end
            for j=1:N
                testj = (j>1) + 10*(j<N);
                switch testj
                    case 1
                        %windy = N-1:N;
                        W2Q = XQ(windx,N-1:N);
                    case 10
                        %windy = 1:2;
                        W2Q = XQ(windx,1:2);
                    case 11
                        %windy = j-1:j+1;
                        W2Q = XQ(windx,j-1:j+1);
                end
                
                myValue = XQ(i,j);
                %W2Q = XQ(windx,windy);
                
                if ~isempty(W2Q(W2Q~=myValue))
                    myV = -bet*(length(W2Q(W2Q==myValue))-...
                        length(W2Q(W2Q~=myValue)));
                    myAll = -(X(i,j)-Ui(i,j,myValue))^2/sig-myV;
                    for r=1:k
                        Vr =  -bet*(length(W2Q(W2Q==r))-length(W2Q(W2Q~=r)));
                        aux = -(X(i,j)-Ui(i,j,r))^2/sig-Vr;
                        
                        if aux > myAll
                            myValue = r;
                            myV = Vr;
                            myAll = aux;
                            newXQ(i,j) = r;
                        end
                    end
                   
                end
            end
        end
        MCH = XQ~=newXQ;
        nChanges = length(MCH(MCH~=0));
        XQ = newXQ;
        n = n+1;
    end
    if n == nmax
        fprintf('%s: Max iterations reached!\n', mfilename);
    end
    W = floor(W/2);
    nChanges = numel(X);
    n = 1;
end

IDX = newXQ;

