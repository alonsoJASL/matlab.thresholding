% script file : Otsu method
%
close all;
clc;

warning('off','all');

%fname_osx = strcat('~/Documents/propio/PhD/ISBI/ISBI_Challenge/',...
%    'ChallengeDataSets/Fluo-N2DH-GOWT1/01/t000.tif');
%I = imread(fname_osx);

fname = strcat('/media/jsolisl/DATA/ISBI_CELLTRACKING/2015/',...
    'ChallengeDatasets/Fluo-N2DH-GOWT1/01/t000.tif');
I = imread(fname);

I = imfilter(I, fspecial('gaussian'));

q = 2;

c1 = cputime;
[LEVEL, maxSIG] = graythreshn(I,q);
c1 = cputime -c1;
c2 = cputime;
TH = multithresh(I,q);
c2 = cputime - c2;

seg1 = imquantize(I,TH);
seg2 = imquantize(I,LEVEL);

RGB1 = label2rgb(seg1);
RGB2 = label2rgb(seg2);

figure
imshowpair(RGB1,RGB2,'montage');
axis off;
title('OTSUs segmentation                               JASLs Segmentation');

disp(LEVEL');
disp([c2 c1]);