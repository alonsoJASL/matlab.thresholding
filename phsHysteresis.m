function [levels, latt] = phsHysteresis(X, alphabeta)
%       PHAGOSIGHT HYSTERESIS
% 
% Returns the levels calculated by ISBI's PhagoSight taking into account
% the min value, mode and parameters alpha and beta. 
% 
if nargin < 2
    alpha_G     = 0.180608;
    beta_G      = 0.251385;
else
    alphabeta = sort(alphabeta);
    alpha_G     = alphabeta(1);
    beta_G      = alphabeta(2); 
end

otsu = multithresh(X, 1);
otsuLevs = [0.95 1.05].*otsu;

modeData = mode(X(:));
minData = min(X(:));
if otsuLevs(1) < minData
    otsuLevs(1) = minData;
end

levels(1) = modeData + alpha_G*(otsuLevs(1) - minData);
levels(2) = modeData + beta_G*(otsuLevs(2) - minData);

if nargout > 1
    latt.modeData = modeData;
    latt.minData = minData;
    latt.phsOtsu = otsuLevs;
    latt.alphabeta = [alpha_G beta_G];
end