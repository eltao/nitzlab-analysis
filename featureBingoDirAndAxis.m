function [ featureCombos, thresholds ] = featureBingoDirAndAxis( dirFeatureTable)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% compare each feature with itself for matrices of same-feature locations
%set thresholds
thresholds = [pi/18, pi/18]; % 10 deg*2, 10deg*2

% Features for this version
% 1) Direction of travel at this location (radians - 0 is Room N)
% 2) Axis of travel at this location (radians - 0 is Room N/S)
featureCombos = nan(size(dirFeatureTable,1),size(dirFeatureTable,1),2);
featureCombos(:,:,1) = ...
    abs(bsxfun(@circ_dist2,dirFeatureTable,dirFeatureTable')) <= thresholds(1);
featureCombos(:,:,2) = ...
    abs(bsxfun(@circ_dist2,2*dirFeatureTable,2*dirFeatureTable')/2) <= thresholds(2);    
end

