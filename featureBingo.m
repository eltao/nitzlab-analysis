function [ featureCombos, thresholds ] = featureBingo( locationFeatureTable, segmentClosenessMat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% compare each feature with itself for matrices of same-feature locations
%set thresholds - always half the real window value.
%thresholds = [7.5 7.5 .10, NaN, NaN, NaN, NaN, pi/18, pi/18]; %rat length, rat length, ehhhhh small, ... 10*2 deg, 10*2 deg
thresholds = [.10, 7.5 NaN];

% Features Coded (Columns) **coded from locationFeatureTable ***added here
% 1) Baseline/Composite/AllPoints (not included in features)
% **2) Distance on segment (percent - 0 at beginning of seg, 1 at end)
% 3) Direction of travel at this location (radians - 0 is Room N)
% 4) Axis of travel at this location (radians - 0 is Room N/S)
% **5) Distance from reward (bins/cm - they are the same)
% ***6) - combo 5&(7|segmentClose) - place (spatial coherence)
% **7) Segment Identifier



% Features Coded OLD WAY (Columns)
% 1) Distance from reward (bins/cm - they are the same)
% 2) Distance on segment (bins/cm - they are the same)
% 3) Distance on segment (percent - 0 at beginning of seg, 1 at end)
% 4) Segment Identifier
% 5) Segment from reward
% 6) In/Out/Not a Finish
% 7) L/R/Not a Finish
% 8) Direction of travel at this location (radians - 0 is Room N)
% 9) Axis of travel at this location (radians - 0 is Room N/S)


featureCombos = nan(size(locationFeatureTable,1),size(locationFeatureTable,1),size(locationFeatureTable,2));
for iFeature = 1:size(locationFeatureTable,2)
    switch iFeature
        case {3}
            featureCombos(:,:,iFeature) = ...
                bsxfun(@eq,locationFeatureTable(:,iFeature),...
                locationFeatureTable(:,iFeature)');
        case {1,2}
            featureCombos(:,:,iFeature) = ...
                abs(bsxfun(@minus,locationFeatureTable(:,iFeature),...
                locationFeatureTable(:,iFeature)'))...
                <= thresholds(iFeature);
        case {8}
            featureCombos(:,:,iFeature) = ...
                abs(bsxfun(@circ_dist2,locationFeatureTable(:,iFeature),locationFeatureTable(:,iFeature)')) <= thresholds(iFeature);
        case {9}
            featureCombos(:,:,iFeature) = ...
                abs(bsxfun(@circ_dist2,2*locationFeatureTable(:,iFeature),2*locationFeatureTable(:,iFeature)')/2) <= thresholds(iFeature);
    end
end
for i = 1:length(locationFeatureTable)
    for j = 1:length(locationFeatureTable)
        featureCombos(i,j,size(locationFeatureTable,2)+1) = segmentClosenessMat(locationFeatureTable(i,3),locationFeatureTable(j,3));
    end
end
end

