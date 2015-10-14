function [binaryImage, dataL] = binaryFromLevels(X, levels)
%                       BINARY FROM LEVELS
%
% Build binary image from thresholding levels. Optionally returns labeled
% image as well. Supports both one (default) or two levels to do the
% segmentation. 
% 

numLevels = length(levels);
switch numLevels
    case 1
        binaryImage = X > levels;
        dataL = bwlabeln(binaryImage);
        
    case 2
        LowT = bwlabeln(X>levels(1));
        ToKeep = unique(LowT.*(X>levels(2)));
        [dataL,~] = bwlabeln(ismember(LowT,ToKeep(2:end)));
        binaryImage = dataL > 0;
        
    otherwise
        binaryImage = [];
        dataL = [];
        help binaryFromLevels;
        return;
end
