function [ spikeFormData ] = NatEmFiringRateFunction( spikeFormInput )
%UNTITLED2 calculates firing rate of all neurons in spikes/second
spikeFormData = spikeFormInput;
for i=1:size(spikeFormData.rmapFilePath,2)
    load(char(spikeFormData.rmapFilePath(i)), 'tfileList','allTfiles','pixelDvt');
    totalTime = size(pixelDvt,1)/60;    %total time in seconds
    totalSpikes = size(allTfiles{spikeFormData.neuronNumber(i)},1);
    firingRate = totalSpikes/totalTime;
    spikeFormData.firingRate(i) = firingRate;
end
end

