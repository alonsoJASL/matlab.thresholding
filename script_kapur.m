% script file: Kapur Thresholding
%
close all
clc

warning('off','all');

%fname_osx = strcat('~/Documents/propio/PhD/ISBI/ISBI_Challenge/',...
%    'ChallengeDataSets/Fluo-N2DH-GOWT1/01/t000.tif');
%I = imread(fname_osx);

fname = strcat('/media/jsolisl/DATA/ISBI_CELLTRACKING/2015/',...
    'ChallengeDatasets/Fluo-N2DH-GOWT1/01/t000.tif');
I = imread(fname);

I = imfilter(I, fspecial('gaussian'));

c = cputime;
[LEVEL, maxPhi] = kapursegment(I,10);
c = cputime -c;

%
seg1 = imquantize(I,LEVEL);

RGB1 = label2rgb(seg1);

figure
imshowpair(I,RGB1,'montage');
axis off;
title('Original                               JASLs Segmentation');

disp(LEVEL');
disp(maxPhi);
disp(c);