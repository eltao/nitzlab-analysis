function [ spikeFormData ] = NatEmISIpcaFunction(spikeFormInput )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
spikeFormData = spikeFormInput;
for i=1:size(spikeFormData.rmapFilePath,2)
    load(char(spikeFormData.rmapFilePath(i)), 'tfileList','allTfiles');
    intervalDiff = diff(allTfiles{spikeFormData.neuronNumber(i)});
    [isiHist,edges] = histcounts(intervalDiff,1000,...
        'BinLimits',[0,1],'Normalization','probability');
    ISI(i,:)=isiHist; 
end

%PCA - see doc pca, it is very helpful
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(ISI,'Centered',false);
k=1; %num components
while sum(EXPLAINED(1:k))<80
    k = k+1;
end
spikeFormData.rawISI = isiHist;
spikeFormData.numComponents80Explained = k;
spikeFormData.isiPCTransformed = SCORE; %transformed data into principal component space
                %Rows of score correspond to observations, and columns correspond to components.
spikeFormData.isiPCs = COEFF; %eigenvectors of the covariance matrix
spikeFormData.isiEigenvalues = LATENT; %eigenvalues of the covariance matrix
spikeFormData.isiExplained = EXPLAINED; 
figure;
imagesc(SCORE(:,1:k)*COEFF(:,1:k)')
caxis([0 .06]);

end

