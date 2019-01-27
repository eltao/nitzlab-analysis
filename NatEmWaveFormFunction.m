function [ spikeFormData ] = NatEmWaveFormFunction( neuronList )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%in general:
%save neuron number somewhere
%check variable names

recListFID = fopen(neuronList);
spikeFormData = struct();
currentLine = fgetl(recListFID);

%reading into neuron list
entryNumber=0;
while ischar(currentLine)               %loop while there are still more recordings in neuron list 
    dataFile = currentLine;
    subNeuronInds = str2num(fgetl(recListFID));
    load(dataFile, 'tfileList');
    
    load('allPLXFiles.mat');
    nNeuron = size(subNeuronInds, 2);   %number of neurons in the recording
    for iNeuron = 1:nNeuron
        entryNumber = entryNumber + 1;  %indexing each neuron in spikeFormData
        
        %data file name
        spikeFormData.rmapFilePath(entryNumber) = cellstr(dataFile);
        
        %neuron number
        spikeFormData.neuronNumber(entryNumber) = subNeuronInds(iNeuron);
        
        %rec number
        recNum = dataFile(32:33); %was 9:10 without file path
        if strcmp(recNum(2),'_')
            recNum = recNum(1);
        end
        spikeFormData.rec(entryNumber) = (str2num(recNum));
        
        %rat name
        ratName = dataFile(26:27);
        spikeFormData.rat(entryNumber) = (str2num(ratName));
        
        %channel name/number/letter
        channelName = tfileList(subNeuronInds(1, iNeuron),1);
        spikeFormData.channel(entryNumber) = channelName;
        channelNumSt = (channelName{1,1}(5:6));
        channelNum = (str2num(channelNumSt));    %get chn number
        unitLetter = channelName{1,1}(7);        %get chn letter
        switch unitLetter
            case 'a';
                unitNum =1;
            case 'b';
                unitNum =2;
            case 'c';
                unitNum =3;
            case 'd';
                unitNum =4;
            case 'e';
                unitNum =5;
            case 'f';
                unitNum =6;
            case 'g';
                unitNum =7;
            case 'h';
                unitNum =8;
            case 'i';
                unitNum =9;
            case 'j';
                unitNum =10;
        end
        
        %find plexon file based on name in neuron list
        fileSubstring = dataFile(24:43);
        plxlistIndex = -1;
        for line=1:size(allPLXFiles,1)
            if ~isempty(strfind(allPLXFiles{line},fileSubstring))
                if plxlistIndex==-1 %aka if a plexon file was not previously found
                    plxlistIndex = line;
                else
                    disp('multiple Plexon files found');
                    return;
                end
            end
        end
        if plxlistIndex == -1
            disp('no Plexon file found');
            return;
        end
        plxName = allPLXFiles{plxlistIndex};
        spikeFormData.plexonFilePath(entryNumber) = cellstr(plxName);
       
        %initialize mean and sd waves
        meanWave = zeros(1,240);
        stdDevWave = zeros(1,240);
        
        %compose the wave
        startChannel = floor((channelNum-1)/4)*4+1;     %the first channel in the tetrode
        for currentChannel=startChannel:startChannel+3
            
            %get array of waves (every spike from entire recording) from plexon 
            % & take mean wave and sd of waves
            [numWaves, numPtsInWave, timeStamp, wave] = ...
                plx_waves(plxName, currentChannel, unitNum);
            newMeanWave = mean(wave, 1);
            newstdDevWave = std(wave, 1);
            
            if mod(currentChannel,4) == 0       %if start at channel 4, index to 181-240
                currentIndex = 181;
            else
                currentIndex = 60*(mod(currentChannel,4)-1)+1;
                %if current channel is 1, index is 1
                %if current channel is 2, index is 61 ...
            end
            if size(wave,1) > 1   %if wave data exists (channel wasn't closed)
                meanWave(currentIndex:currentIndex+numPtsInWave-1) = newMeanWave;
                stdDevWave(currentIndex:currentIndex+numPtsInWave-1) = newstdDevWave;
            end
            
        end
        spikeFormData.spikeAvg(entryNumber,:) = meanWave;
        spikeFormData.spikeStdDev(entryNumber,:) = stdDevWave;
        spikeFormData.ptsInWave(entryNumber,:) = numPtsInWave;
        
    end
    
    currentLine = fgetl(recListFID);
    currentLine = fgetl(recListFID);
end
end

