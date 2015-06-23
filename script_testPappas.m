tic
%fname = strcat('/media/jsolisl/DATA/ISBI_CELLTRACKING/2015/',...
%    'ChallengeDatasets/Fluo-N2DH-GOWT1/01/t000.tif');
fname = 'images/t000.tif';
X = imread(fname);
X = double(X);

if size(X,3) > 1
    X = rgb2gray(X);
end
%X = imfilter(X, fspecial('gaussian'));
k = 2;

%initial segmentation (we use Otsu's method because YOLO)
[level] = multithresh(X, k-1);
%
XQ = imquantize(X,level);
newXQ = XQ;

W = size(X);
[M, N] = size(X);

Ui = zeros(M, N, k);
sig = var(double(X(:)));
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
        elseif q*b + 1 > M
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
        [xx1, yy1] = meshgrid(linspace(1,M,length(x)),...
            linspace(1,N,length(y)));
        [xx2, yy2] = meshgrid(1:M,1:N);
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
                        windy = N-1:N;
                    case 10
                        windy = 1:2;
                    case 11
                        windy = j-1:j+1;
                end
                
                myValue = XQ(i,j);
                W2Q = XQ(windx,windy);
                
                if ~isempty(W2Q(W2Q~=myValue))
                    myV = -bet*(length(W2Q(W2Q==myValue))-length(W2Q(W2Q~= ...
                        myValue)));
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
        disp('Max iterations reached!');
    end
    W = floor(W/2);
    nChanges = numel(X);
    n = 1;

end
toc
% test
[level] = multithresh(X, k-1);
XQ2 = imquantize(X,level);

imshowpair(XQ2, XQ,'montage');

%%
clc

tic 
fname = 'images/t000.tif';
IDX = adaptiveClustering(fname, 2);
toc

disp('done');
