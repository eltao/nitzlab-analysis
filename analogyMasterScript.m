% Analogy Command Script

% load('D:\axisCellPaper\FinalAnalysisResults\MainDataset\SubPaperDataStruct.mat');
% load('D:\axisCellPaper\FinalAnalysisResults\MainDataset\SubPaperNeuronStruct.mat');
% NS = SubPaperNeuronStruct;
% DS = SubPaperDataStruct;

%% Gives FR and HD data for all neurons.
[ meanSDCountFRByLoc, meanSDCircSDCountHDByLoc, locationLookupTable, locationFeatureTable, segmentClosenessMat ] = ...
    analogyFRandHDFinder(DS.recFile,NS.recCount,NS.neuronIndex,DS.pathList,...
    NS.posHDRadiansAllCorrected,NS.posPathAndBinAll);

% Just grab paths 1-10 - do so by grabbing the spots with data in the first
% neuron and grabbing the same spots for all neurons.
occupiedRows = squeeze(~isnan(meanSDCountFRByLoc(:,1,1)));
occupiedMeanSDCountFRByLoc = meanSDCountFRByLoc(occupiedRows,:,:);
occupiedMeanSDCircSDCountHDByLoc = meanSDCircSDCountHDByLoc(occupiedRows,:,:);
save analogyRawData occ* mean* *Table segment*

% % A nice check - compare results of neuron 11 in above results to Emily's
% % neuron 11 as computed below.
% load('allSubNeurons.mat');
% replaceDrive = @(x) ['F',x(2:end)];
% allSubNeurons.rmapFilePath = cellfun(replaceDrive, allSubNeurons.rmapFilePath, 'UniformOutput',false);
% analogyMeanSDByLoc = meanSDByTrackLocFunction(allSubNeurons, 11);
% meanSDCircSDCountHDByLoc(:,:,11);

% This takes awhile. ~30min
locPairTScores = locPairTScoreFunction( occupiedMeanSDCountFRByLoc );
save locPairTScores locPairTScores -v7.3

%%
occupiedLocationFeatureTable = locationFeatureTable(occupiedRows,:);
occupiedFeatureCombos = featureBingo(occupiedLocationFeatureTable,segmentClosenessMat);
occupiedDirAxisCombos = nan(size(occupiedMeanSDCountFRByLoc,1),...
    size(occupiedMeanSDCountFRByLoc,1),2,size(occupiedMeanSDCountFRByLoc,3));
for iNeuron = 1:size(occupiedMeanSDCountFRByLoc,3)
    occupiedDirAxisCombos(:,:,:,iNeuron) = featureBingoDirAndAxis(occupiedMeanSDCircSDCountHDByLoc(:,1,iNeuron));
end

% occupiedCompleteFeatureCombos = [...
%     repmat(occupiedFeatureCombos,[1,1,1,size(occupiedMeanSDCountFRByLoc,3)]),...
%     occupiedDirAxisCombos];
save analogyDataMinusTScoresAndDirCombos occ* mean* *Table segment*
save occupiedDirAxisCombos occupiedDirAxisCombos -v7.3

%% Results and Interpretation
for i = 1:size(occupiedFeatureCombos,3);
    figure;
    pcolor(occupiedFeatureCombos(:,:,i));
    shading INTERP
end
figure;
pcolor(occupiedDirAxisCombos(:,:,1,1));
shading INTERP
figure;
pcolor(occupiedDirAxisCombos(:,:,2,1));
shading INTERP

% occupiedDirAxisCombos(:,:,1,1);
% occupiedMeanSDCircSDCountHDByLoc(:,:,1);


%Feature Order
% 1) Baseline/Composite/AllPoints
% 2) Distance on segment (percent - 0 at beginning of seg, 1 at end)
% 3) Direction of travel at this location (radians - 0 is Room N)
% 4) Axis of travel at this location (radians - 0 is Room N/S)
% 5) Distance from reward (bins/cm - they are the same)
% 6) - combo 5&(7|segmentClose) - place (spatial coherence)
% 7) Segment Identifier
% X Segment from reward
% X Distance on segment (bins/cm - they are the same)
% X In/Out/Not a Finish
% X L/R/Not a Finish
% X - analogy same as 1 - cm
% X - analogy same as 1 - percent
% X - place (spatial coherence)
% X - direction & analogy
% X - axis & analogy

% combos = [ ...
%     2,5; ...
%     3,5; ...
%     2,4; ...
%     3,4; ...
%     1,8; ...
%     1,9];
featureBingoOrder     = [2 5 7];
%in occFeatCombos, col= [1 2 3]

fired = occupiedMeanSDCountFRByLoc(:,1,:)>0;
triangleMask = triu(ones(size(fired,1),size(fired,1)),1);
similarityValues = nan(7,size(occupiedDirAxisCombos,4));
for i = 1:size(occupiedDirAxisCombos,4) %542
    firedMat = bsxfun(@or,squeeze(fired(:,1,i)),squeeze(fired(:,1,i))');
    thisNeu = locPairTScores(:,:,i,2);
    similarityValues(1,i) = nanmean(thisNeu(firedMat & triangleMask));
    for j = 1:3
        validSpots = thisNeu(logical(occupiedFeatureCombos(:,:,j)) ...
            & firedMat & triangleMask);
        similarityValues(featureBingoOrder(j),i) = nanmean(validSpots(:));
    end
    validSpots = thisNeu(logical(occupiedDirAxisCombos(:,:,1,i)) ...
            & firedMat & triangleMask);
    similarityValues(4,i) = nanmean(validSpots(:));
    validSpots = thisNeu(logical(occupiedDirAxisCombos(:,:,2,i)) ...
            & firedMat & triangleMask);
    similarityValues(3,i) = nanmean(validSpots(:));
%     for j = 1:4 %# of combos
%         validSpots = thisNeu(logical(occupiedFeatureCombos(:,:,combos(j,1)))...
%             & logical(occupiedFeatureCombos(:,:,combos(j,2)))...
%             & firedMat & triangleMask);
%         similarityValues(j+10,i) = nanmean(validSpots(:));
%     end
    validSpots = thisNeu(logical(occupiedFeatureCombos(:,:,2))...
        & (logical(occupiedFeatureCombos(:,:,3)) | logical(occupiedFeatureCombos(:,:,4)))...
            & firedMat & triangleMask);
    similarityValues(6,i) = nanmean(validSpots(:));
%     validSpots = thisNeu(logical(occupiedFeatureCombos(:,:,combos(6,1)))...
%         & logical(occupiedDirAxisCombos(:,:,2,i))...
%             & firedMat & triangleMask);
%     similarityValues(16,i) = nanmean(validSpots(:));
end
similarityValuesNormed = similarityValues./repmat(similarityValues(1,:),7,1);
save similarityValues similarity* 

%% Plotting Code

% CA1 Data
% load('F:\JL1HPCResultsAnalyzedAxisCellPaperStyle\JL1HPC2DRMapsAxisCellStyle.mat')
% rmaps2D = filter2DMatrices(JL1HPCFullTrackIsRunning2DRMaps,0);
% load('D:\JL1HPCResultsAnalyzedAxisCellPaperStyle\JL1HPCNeuronStruct.mat');
% NS = JL1HPCNeuronStruct;

% SUB Data
% load('D:\axisCellPaper\FinalAnalysisResults\MainDataset\SubPaperNeuronStruct.mat')
% NS = SubPaperNeuronStruct;
load('D:\axisCellPaper\Analyses\Visualize\figureColormap.mat');
% load('D:\axisCellPaper\FinalAnalysisResults\MainDataset\FIGURE_2DRMAPS.mat')
% rmaps2D = fullTrackIsRunning2DRMapsNanConv;


% rmaps2D = twoDRMapsPathsOnlyHPC;
rmaps2D = twoDRMapsPathsOnlySUB;
mapToUse = hotMapClipped;
overallFR = NS.overallMeanFR;
% listToShow=[11 460 467]; %axis       %randperm(size(overallFR,1));
listToShow=[512 481 462 62 246 443 457 408 18]; %direction, last 4 axis
% listToShow=[173 126 171 107 155 82 492 1]; %location analogy
% listToShow=[150 221]; %place
% listToShow=[93 437]; %no coherence
% listToShow=[230 262 522 60]; %spatial
% listToShow=[1:43]; % HPC
for i = 1:size(listToShow,2)%(overallFR,1)
    figure(100)
    bar(similarityValuesSUB(1:6,listToShow(i)));
    axis([0,7,0,3]);
    set(gca,'xtick',1:6);
    set(gca,'xticklabel',{'All', ...
        'Progress through segment (%)', ...
        'Axis analogy',...
        'Direction analogy',...
        'Location Analogy',...
        'Spatial coherence / place (cm)'});
    set(gca,'XTickLabelRotation',-45);
    title(['Neuron ',num2str(listToShow(i)),' - Mean T-Scores']);
    ylabel('t-score');
    figure(101)
    bar(similarityValuesNormedSUB(1:6,listToShow(i)));
    axis([0,7,0,1.5]);
    set(gca,'xtick',1:6);
    set(gca,'xticklabel',{'All', ...
        'Progress through segment (%)', ...
        'Axis analogy',...
        'Direction analogy',...
        'Location Analogy',...
        'Spatial coherence / place (cm)'});
    set(gca,'XTickLabelRotation',-45);
    title(['Neuron ',num2str(listToShow(i)),' - Normed Mean T-Scores']);
    ylabel('t-score normed');
    figure(102)
    caxisMax = 2*overallFR(listToShow(i),2);
    sc(rmaps2D(:,:,listToShow(i))',[0,caxisMax],parula,'w',...
        isnan(rmaps2D(:,:,listToShow(i))'));
    
    disp(listToShow(i));
    disp(overallFR(listToShow(i),2));
    disp(similarityValuesSUB(1,listToShow(i)));
    pause;
end





