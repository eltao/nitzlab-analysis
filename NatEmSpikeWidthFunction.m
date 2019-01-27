function [ spikeFormData ] = NatEmSpikeWidthFunction( spikeFormInput )
%NATEMSPIKEWIDTHFUNCTION calculates spike widths and adds them to
%spikeFormData
%sampling is 40000 Hz. Each point is 25 microseconds
%load(spikeFormInput);
spikeFormData = spikeFormInput;
nNeurons = size(spikeFormData.spikeAvg, 1);

for i = 1:nNeurons
    allChannelWidths = zeros(1,4);
    allChannelHeights = zeros(1,4);
    for j = 1:4
        currentInd = 60*(j-1)+1;   %starting index for the channel
        [maxPt, maxInd] = max(spikeFormData.spikeAvg(i, currentInd:currentInd+59));
        [minPt, minInd] = min(spikeFormData.spikeAvg(i, currentInd:currentInd+59));
        currSpikeWidth = abs(maxInd - minInd);
        currSpikeHeight = abs(maxPt-minPt);
        allChannelWidths(1,j) = currSpikeWidth;
        allChannelHeights(1,j) = currSpikeHeight;
    end
    [maxHeight, maxHeightInd] = max(allChannelHeights);
    maxSpikeWidth = allChannelWidths(maxHeightInd);
    spikeFormData.spikeWidthRaw(i) = maxSpikeWidth;
    spikeFormData.spikeWidthTetrodeWireIndex(i) = maxHeightInd; %num 1-4 corresponding to channel
end
end

