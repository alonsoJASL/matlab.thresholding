function [BW, edgehandles] = complexedge(dataIn)
% COMPLEX EDGE DETECTION.
% Does not return a binary image. 
%
% usage: [BW, edgeshandles] = complexedge(Xg)
% 
[Xcanny] = edge(dataIn,'canny', multithresh(dataIn,2));
[Xacanny] = edge(dataIn,'approxcanny', multithresh(dataIn,2));
[Xprewitt] = edge(dataIn,'Prewitt');
[Xlog] = edge(dataIn,'log');
[Xrob] = edge(dataIn,'Roberts');

BW = mean(cat(3,Xcanny,Xacanny, Xprewitt,Xlog,Xrob),3);

if nargout > 1
    edgehandles.canny = Xcanny;
    edgehandles.approxcanny = Xacanny;
    edgehandles.prewitt = Xprewitt;
    edgehandles.log = Xlog;
    edgehandles.roberts = Xrob;
end