function [ meanSDCountFRByLoc, meanSDCircSDCountHDByLoc,...
    locationLookupTable, locationFeatureTable ] = analogyFRandHDFinder(...
    recFiles, recFileIndexEachNeuron, neuronIndexInRecEachNeuron,...
    pathListAllRecs, correctedHDAllNeurons, posPathAndBinAllNeurons)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


[ locationLookupTable, locationFeatureTable ] = TTLocationLookupTableBuilder();
nNeurons = numel(recFileIndexEachNeuron);
meanSDCountFRByLoc = nan(max(locationLookupTable(:)),3,nNeurons);
meanSDCircSDCountHDByLoc = nan(max(locationLookupTable(:)),4,nNeurons);

oldiRec = 0;
for iOverallNeuron = 1:nNeurons
    iRec = recFileIndexEachNeuron(iOverallNeuron);
    if iRec ~= oldiRec
        oldiRec = iRec;
        recFile = recFiles{iRec};
        load(recFile, 'LinearRates','MeanLinearRates');
        pathList = pathListAllRecs{iRec};
        nPaths = numel(pathList);
        
    end
    neuronNumberInRec = neuronIndexInRecEachNeuron(iOverallNeuron);
    
    %% Get FR for each bin.
    allFRPerLoc = cell(max(locationLookupTable(:)),1);
    for iPath=1:nPaths
        lengthOfPath = size(LinearRates{iPath},2);
        frOfInterest = squeeze(LinearRates{iPath}(neuronNumberInRec,2:end-1,:,1));
        whereToPutFRs = locationLookupTable(sub2ind(size(locationLookupTable),...
            repmat(pathList(iPath),lengthOfPath-2,1),[2:lengthOfPath-1]'));
        
        for iBin = 1:length(whereToPutFRs)
            allFRPerLoc{whereToPutFRs(iBin)} = [ allFRPerLoc{whereToPutFRs(iBin)}, frOfInterest(iBin,:) ];
        end
    end
    
    meanSDCountFRByLoc(:,:,iOverallNeuron) = [cellfun(@mean,allFRPerLoc),...
        cellfun(@std,allFRPerLoc),...
        cellfun(@numel,allFRPerLoc)];
    
    %% Get direction of each bin. 0 = Room North (Towards the top of the
    %  room as seen by tracking camera)
    allHDPerLoc = cell(max(locationLookupTable(:)),1);
    
    iNeuHDRadians = correctedHDAllNeurons{iOverallNeuron};
    iNeuPath = posPathAndBinAllNeurons{iOverallNeuron}(:,1);
    iNeuPathBin = posPathAndBinAllNeurons{iOverallNeuron}(:,2);
    %     timeStamps = timeStampsAllRecs{iRec};
    
    %     for iTimeSegment = 2:nTimeSegments
    %         if iTimeSegment == 2
    %             pathList = [1,2,3,4,9,10]; % Only non rotation paths.
    %         elseif iTimeSegment == 3
    %             pathList = [11,12,13,14,19,20]; % Only rotation paths.
    %         end
    %         hdRadiansRelevant = iNeuHDRadians(...
    %             timeStamps(iTimeSegment*2-1):timeStamps(iTimeSegment*2));
    %         posPathRelevant = iNeuPath(...
    %             timeStamps(iTimeSegment*2-1):timeStamps(iTimeSegment*2));
    %         posPathBinRelevant = iNeuPathBin(...
    %             timeStamps(iTimeSegment*2-1):timeStamps(iTimeSegment*2));
    
    for iPath = 1:nPaths
        %             currPathSamples = posPathRelevant==pathList(iPath);
        %             currPathBin = posPathBinRelevant(currPathSamples);
        %             currPathHDRadians = hdRadiansRelevant(currPathSamples);
        
        currPathSamples = iNeuPath==pathList(iPath);
        currPathBin = iNeuPathBin(currPathSamples);
        currPathHDRadians = iNeuHDRadians(currPathSamples);
        
        whereToPutHDs = locationLookupTable(sub2ind(size(locationLookupTable),...
            repmat(pathList(iPath),sum(currPathSamples),1),currPathBin));
        for iBin = 1:length(whereToPutHDs)
            if ~isnan(whereToPutHDs(iBin)) && ~isnan(currPathHDRadians(iBin))
                allHDPerLoc{whereToPutHDs(iBin)} = ...
                    [allHDPerLoc{whereToPutHDs(iBin)},...
                    currPathHDRadians(iBin) ];
            end
        end
    end
    
    for iCell = 1:numel(allHDPerLoc)
        if isempty(allHDPerLoc{iCell})
            allHDPerLoc{iCell} = 0;
        end
    end
    allHDPerLoc = cellfun(@transpose,allHDPerLoc,'UniformOutput',false);
    [normalStd, circStd] = cellfun(@circ_std,allHDPerLoc);
    meanSDCircSDCountHDByLoc(:,:,iOverallNeuron) = ...
        [cellfun(@circ_mean,allHDPerLoc),...
        normalStd,circStd,...
        cellfun(@numel,allHDPerLoc)];
end
end

