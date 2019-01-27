function [spikeFormData] = NatEmKmeanCluster4CenFunction( spikeFormData, jakeSaysAxis )
%NATEMKMEANCLUSTER4CENFUNCTION Run K-means clustering with 4 centers on spikeFormData. 
%This program runs K-Means 500 times and plots the clusters having the least total error.
%Parameter spikeFormDataName is the name of the spikeFormData you wish to
%have the KMeans algorithm run on.
%clusterMatrix columns 
%   [PCs (variable #columns, usually 5) | spike widths | firing rate]
% load('spikeFormDataName');

%norm spike width and firing rate data before adding to clusterMatrix
maxSpikeWidth = max(spikeFormData.spikeWidthRaw);
normSpikeWidth = spikeFormData.spikeWidthRaw/maxSpikeWidth;

maxFiringRate = max(spikeFormData.firingRate);
normFiringRate = spikeFormData.firingRate/maxFiringRate;

k = spikeFormData.numComponents80Explained;
topPCs = spikeFormData.isiPCTransformed(:,1:k);
%normalize the columns of PCs
minPCs = min(topPCs,[],1); %vector containing min values of columns of PCs
zeroedPCs = topPCs + repmat(minPCs,size(topPCs,1),1);
maxPCs = max(max(zeroedPCs,[],1)); %scalar containing max value of all columns of PCs
normTopPCs = zeroedPCs ./ maxPCs;

clusterMatrix = [normTopPCs normSpikeWidth' normFiringRate'];
numCols = size(clusterMatrix,2);

kMeanData= struct(); %saves centers, errors, and point assignments from each clustering iteration
kMeanData.totalCenters=zeros(500,numCols*4);
kMeanData.totalErrors=zeros(500,1);
kMeanData.totalAssignments = zeros(size(spikeFormData.rec,2),500);
for run=1:500
    
    randomCenterId = randi([1 size(clusterMatrix,1)],[4 1]);
    centers = clusterMatrix(randomCenterId,:);

    iteration = 0;
    prevCenters = zeros(size(centers));
    while prevCenters ~= centers 
        iteration = iteration + 1;
        dist = zeros(size(clusterMatrix,1),size(centers,1));
        for j=1:size(centers,1) %distance formula for as many dimensions as are in clusterMatrix
            distSquared = 0;
            for dim = 1:numCols
                distSquared = distSquared + (clusterMatrix(:,dim) - centers(j,dim)).^2;
            end
            dist(:,j) = sqrt(distSquared);
        end

        prevCenters = centers;
        [minDist, minDistInd] = min(dist,[],2);
        for i=1:size(centers,1)
            centers(i,:) = mean(clusterMatrix(minDistInd == i,:));
        end
    end
    
    %this line transforms the rectangular matrix of centers into a single
    %row so it can be stored with centers from all 500 runs
    kMeanData.totalCenters(run,:) = [centers(1,:) centers(2,:) centers(3,:) centers(4,:)];
   
    totalError = sum(minDist);    %error calculation
    kMeanData.totalErrors(run,1) = totalError;
    
    kMeanData.totalAssignments(:,run) = minDistInd;
    
end

%% find the minimum error centers

[minError, indMinError] = min(kMeanData.totalErrors);

%reformat centers into rectangular matrix for easier plotting
minECenters(1,:) = kMeanData.totalCenters(indMinError,1:numCols);
minECenters(2,:) = kMeanData.totalCenters(indMinError,numCols+1:numCols*2);
minECenters(3,:) = kMeanData.totalCenters(indMinError,numCols*2+1:numCols*3);
minECenters(4,:) = kMeanData.totalCenters(indMinError,numCols*3+1:numCols*4);

%the center ID that corresponds to each point
pointCenterID = kMeanData.totalAssignments(:,indMinError);

spikeFormData.clusterMatrix = clusterMatrix;
spikeFormData.clusterCenters = minECenters;
spikeFormData.clusterPointIDs = pointCenterID;

%% plotting the minimum error centers

figure();

dim1 = 1; %index of the column you want to plot, i.e. PC1
dim2 = 2;
dim3 = 3;
subplot(1,3,1);
scatter3(clusterMatrix(pointCenterID == 1,dim1), ...
    clusterMatrix(pointCenterID == 1,dim2),clusterMatrix(pointCenterID == 1,dim3),20,'r','filled');
hold on; 
scatter3(minECenters(1,dim1),minECenters(1,dim2),minECenters(1,dim3), ...
    80,'Marker','x','MarkerEdgeColor',[0.6 0 0],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 2,dim1), ...
    clusterMatrix(pointCenterID == 2,dim2),clusterMatrix(pointCenterID == 2,dim3),20,'b','filled');
scatter3(minECenters(2,dim1),minECenters(2,dim2),minECenters(2,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0 0.6],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 3,dim1), ...
    clusterMatrix(pointCenterID == 3,dim2),clusterMatrix(pointCenterID == 3,dim3),20,'g','filled');
scatter3(minECenters(3,dim1),minECenters(3,dim2),minECenters(3,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0.6 0],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 4,dim1), ...
    clusterMatrix(pointCenterID == 4,dim2),clusterMatrix(pointCenterID == 4,dim3),20,'c','filled');
scatter3(minECenters(4,dim1),minECenters(4,dim2),minECenters(4,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0.6 0.6],'LineWidth',4);
xlabel('PC 1');
ylabel('PC 2');
zlabel('PC 3');

dim1 = 1;
dim2 = 3;
dim3 = 4;
subplot(1,3,2);
scatter3(clusterMatrix(pointCenterID == 1,dim1), ...
    clusterMatrix(pointCenterID == 1,dim2),clusterMatrix(pointCenterID == 1,dim3),20,'r','filled');
hold on; 
scatter3(minECenters(1,dim1),minECenters(1,dim2),minECenters(1,dim3), ...
    80,'Marker','x','MarkerEdgeColor',[0.6 0 0],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 2,dim1), ...
    clusterMatrix(pointCenterID == 2,dim2),clusterMatrix(pointCenterID == 2,dim3),20,'b','filled');
scatter3(minECenters(2,dim1),minECenters(2,dim2),minECenters(2,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0 0.6],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 3,dim1), ...
    clusterMatrix(pointCenterID == 3,dim2),clusterMatrix(pointCenterID == 3,dim3),20,'g','filled');
scatter3(minECenters(3,dim1),minECenters(3,dim2),minECenters(3,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0.6 0],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 4,dim1), ...
    clusterMatrix(pointCenterID == 4,dim2),clusterMatrix(pointCenterID == 4,dim3),20,'c','filled');
scatter3(minECenters(4,dim1),minECenters(4,dim2),minECenters(4,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0.6 0.6],'LineWidth',4);
xlabel('PC 3');
ylabel('PC 4');
zlabel('Spike Width');

dim1 = 1;
dim2 = numCols-1;
dim3 = numCols;
subplot(1,3,3);
scatter3(clusterMatrix(pointCenterID == 1,dim1), ...
    clusterMatrix(pointCenterID == 1,dim2),clusterMatrix(pointCenterID == 1,dim3),20,'r','filled');
hold on; 
scatter3(minECenters(1,dim1),minECenters(1,dim2),minECenters(1,dim3), ...
    80,'Marker','x','MarkerEdgeColor',[0.6 0 0],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 2,dim1), ...
    clusterMatrix(pointCenterID == 2,dim2),clusterMatrix(pointCenterID == 2,dim3),20,'b','filled');
scatter3(minECenters(2,dim1),minECenters(2,dim2),minECenters(2,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0 0.6],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 3,dim1), ...
    clusterMatrix(pointCenterID == 3,dim2),clusterMatrix(pointCenterID == 3,dim3),20,'g','filled');
scatter3(minECenters(3,dim1),minECenters(3,dim2),minECenters(3,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0.6 0],'LineWidth',4);
scatter3(clusterMatrix(pointCenterID == 4,dim1), ...
    clusterMatrix(pointCenterID == 4,dim2),clusterMatrix(pointCenterID == 4,dim3),20,'c','filled');
scatter3(minECenters(4,dim1),minECenters(4,dim2),minECenters(4,dim3),80, ...
    'Marker','x','MarkerEdgeColor',[0 0.6 0.6],'LineWidth',4);
hold on;
scatter3(clusterMatrix(jakeSaysAxis,dim1), ...
    clusterMatrix(jakeSaysAxis,dim2),clusterMatrix(jakeSaysAxis,dim3),40,'k','filled');
xlabel('PC 1');
ylabel('Spike Width');
zlabel('Firing Rate');

figure;

scatter3(clusterMatrix(jakeSaysAxis,dim1), ...
    clusterMatrix(jakeSaysAxis,dim2),clusterMatrix(jakeSaysAxis,dim3),40,'k','filled');
xlabel('PC 1');
ylabel('Spike Width');
zlabel('Firing Rate');
end

