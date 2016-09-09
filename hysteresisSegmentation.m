function [BW,bwatt] = hysteresisSegmentation(X, levels)
%  SIMPLE HYSTERESIS SEEGMENTATION FROM LEVELS.
%
% If no levels are found, Otsu's method is used to compute the two levels.
%           - bwatt.quantified = imquantized(X,levels)
%           - bwatt.levels = levels.
%

if nargin < 2
    levels = multithresh(X,2);
end

BW = binaryFromLevels(X,levels);
