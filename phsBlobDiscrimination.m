function [dataL, numN] = phsBlobDiscrimination(Xb, minblob)
%     PHAGOSIGHT MINBLOB DISCRIMINANT
% Takes an image segmented and removes the smaller segmented areas assuming
% them as noise. Default value for minBlob gets calculated with the mean
% ans standard deviation of the objects founsd on the image Xb, and we take
% the minimum between that and 60. 
% 

if nargin < 2
    minimB = 60;
    regS = regionprops(Xb);
           
    M = mean([regS.Area]);
    S = std([regS.Area]);

    minblob = max(minimB,(M-3*S)/4);
end

[dataL,numNeutrop] = bwlabeln(ismember(Xb, find([regS.Area]>minblob)));

if nargout > 1
    numN = numNeutrop;
end
    
    
