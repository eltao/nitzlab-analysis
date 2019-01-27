function [ spikeFormData ] = NatEmAutoCorrelationFunction( spikeFormInput )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
spikeFormData = spikeFormInput;
for i=1:size(spikeFormData.rmapFilePath,2)
    load(char(spikeFormData.rmapFilePath(i)), 'tfileList','allTfiles');
    spikeTimes = allTfiles{spikeFormData.neuronNumber(i)};

% spikeTimes = allTfiles{9};

    spikesByMs = zeros(1,1000*ceil(max(spikeTimes,[],1)));
    for spikeIndex = 1:size(spikeTimes,1)
        spikesByMs(1,floor(spikeTimes(spikeIndex)*1000+.5)) = 1;
    end

    autocorr = xcov(spikesByMs,1000);
    spikeFormData.autoCorrelation(i,:) = autocorr;
end
end
