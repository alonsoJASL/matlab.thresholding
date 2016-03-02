function [jaccardIdx, jaccardDist] = jaccardIndex(Xb, Xgt)
%                       JACCARD INDEX AND DISTANCE
% Computes the Jaccard Index of similarity between two binary images. If
% provided, the structure xatt will aid in computing the index for various
% images.
%

switch nargin
    case {0, 1}
        disp('ERROR. At least two images must be provided.');
        jaccardIdx = [];
        if nargout > 1
            jaccardDist = [];
        end
        return;
    case 2
        ji = 0;        
        
        [~,~,~,numImages] = size(Xb);
        for k=1:numImages
            inter = Xb(:,:,:,k) & Xgt(:,:,:,k);
            uni = Xb(:,:,:,k) | Xgt(:,:,:,k);
            ji = ji + sum(inter(:))/sum(uni(:));
        end
        jaccardIdx = ji/numImages;
        if nargout > 1
            jaccardDist = 1-jaccardIdx;
        end
        
    %case 3
        
    otherwise
        disp('ERROR.');
        jaccardIdx = [];
        if nargout > 1
            jaccardDist = [];
        end
        return;
end