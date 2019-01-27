function [ rateMap ] = fast2DRMapFunction (rMapFileName, cellNum)
% rMapFileName=char(allSubNeurons.rmapFilePath(1));
load(rMapFileName,'pos','allTfiles','narrowGaussianNormed');
% In this code pos is 3 columns - times, x,y
% allTfiles is a cell array with each of the tfiles in order.
sampleRate = 60; % 60 Hz recording position sampling.
nCells = length(allTfiles);

%% Check that both processedDvt and the spikes are all sorted ascending and
% pos and processedDvt are equal.
if any(diff(pos(:,1))<0)
    disp(['Pos is not in chronological order.']);
    return
end
for iCell = 1:nCells
    if any(diff(allTfiles{iCell})<0)
        disp(['Neuron ', num2str(iCell),' spikes are not in chronological order.']);
        return;
    end
end
tic;
%% Calc nSpikes for each sample.
posNSpikes = zeros(size(pos,1),nCells);
nSamples = size(pos,1);
for iCell=1:nCells
% iCell = cellNum
    tfile = allTfiles{iCell};
    posIndex = 1;
    for iSpike =1:length(tfile)
        % Cycle through dvt until you hit the time that this spike goes to.
        while tfile(iSpike) > (pos(posIndex,1)+(1/(2*sampleRate))) &&...
                posIndex <= nSamples
            posIndex = posIndex+1;
        end
        if posIndex > nSamples
            disp('Spikes exist after the last sample!');
            return
        else
            posNSpikes(posIndex,iCell) = posNSpikes(posIndex,iCell) + 1;
        end
    end
end
toc;
tic;
%% TwoD Ratemap
maxX = 700;
maxY = 500;
rates = zeros(maxX,maxY,nCells);
spikes = zeros(maxX,maxY,nCells);

occs = repmat(hist3(pos(:,2:3),{1:maxX, 1:maxY}),[1,1,1]);%nCells]);
for iPos = 1:length(pos)
    %for iCell = 1:nCells
    iCell = cellNum;
        spikes(pos(iPos,2),pos(iPos,3),:) = ...
            spikes(pos(iPos,2),pos(iPos,3),:) + ...
            reshape(posNSpikes(iPos,:),[1,1,nCells]);
    %end
end
toc;
%for iCell = 1:nCells
iCell = cellNum;
    rates(:,:,iCell) = conv2(spikes(:,:,iCell)./occs(:,:,iCell),...
        narrowGaussianNormed,'same');
%end
toc;
tic;
rateMap = rates(:,:,iCell);
end
% %% Old TwoD Ratemap
% for iCell = 1:nCells
%     tfile = allTfiles{iCell};
%     maxX = 700;
%     maxY = 500;
%     posSpikes=zeros(maxX,maxY);
%     posOccs=zeros(maxX,maxY);
%     posRates=zeros(maxX,maxY);
%     
%     for iPos=1:length(pos)
%         if (any(pos(iPos,2:3) <= 1))
%         else
%             posOccs(pos(iPos,2),pos(iPos,3)) = ...
%                 posOccs(pos(iPos,2),pos(iPos,3))+1;
%             
%             spikes = find(tfile>=(pos(iPos,1)-1/(sampleRate*2)) &...
%                 tfile<(pos(iPos,1)+1/(sampleRate*2)));
%             posSpikes(pos(iPos,2),pos(iPos,3)) = ...
%                 posSpikes(pos(iPos,2),pos(iPos,3))+length(spikes);
%         end
%     end
%     
%     isOcc = posOccs>0;
%     posRates(isOcc) = (posSpikes(isOcc)./posOccs(isOcc))*sampleRate;
%     posRates(~isOcc) = -.0001;
%     
%     % Filter 2D Ratemap
%     posRates=conv2(posRates,narrowGaussianNormed,'same');
%     TwoDRateMaps(iCell,:,:,1)=posRates;
%     TwoDRateMaps(iCell,:,:,2)=posSpikes;
%     TwoDRateMaps(iCell,:,:,3)=posOccs;
% end
% toc;