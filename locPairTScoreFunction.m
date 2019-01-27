function [ locPairTScores ] = locPairTScoreFunction( meanSDCountByLoc )
%UNTITLED5 Summary of this function goes here
%   get t scores for each pair of locations

if size(meanSDCountByLoc,3)>1
    locPairTScores = nan(size(meanSDCountByLoc,1),size(meanSDCountByLoc,1),size(meanSDCountByLoc,3),2);
    for iNeuron = 1:size(meanSDCountByLoc,3)
        for iLoc1=1:size(meanSDCountByLoc,1)
            for iLoc2=iLoc1:size(meanSDCountByLoc,1)
                tScore=tVal(meanSDCountByLoc(iLoc1,:,iNeuron),meanSDCountByLoc(iLoc2,:,iNeuron));
                if meanSDCountByLoc(iLoc1,1,iNeuron)==0 && meanSDCountByLoc(iLoc1,2,iNeuron)==0 && ...
                        meanSDCountByLoc(iLoc2,1,iNeuron)==0 && meanSDCountByLoc(iLoc2,2,iNeuron)==0
                    tScore=0; %when mean rate and sd of both locs are 0, tscore is 0
                end
                %         pathAndBin1=meanSDByLoc(iLoc1,1:2);
                %         pathAndBin2=meanSDByLoc(iLoc2,1:2);
                locPairTScores(iLoc1,iLoc2,iNeuron,:) = [tScore abs(tScore)];
            end
        end
        disp(iNeuron);
    end
else
    locPairTScores = nan(size(meanSDCountByLoc,1),size(meanSDCountByLoc,1),2);
    for iLoc1=1:size(meanSDCountByLoc,1)
        for iLoc2=iLoc1:size(meanSDCountByLoc,1)
            tScore=tVal(meanSDCountByLoc(iLoc1,:),meanSDCountByLoc(iLoc2,:));
            if meanSDCountByLoc(iLoc1,1)==0 && meanSDCountByLoc(iLoc1,2)==0 && ...
                    meanSDCountByLoc(iLoc2,1)==0 && meanSDCountByLoc(iLoc2,2)==0
                tScore=0; %when mean rate and sd of both locs are 0, tscore is 0
            end
            %         pathAndBin1=meanSDByLoc(iLoc1,1:2);
            %         pathAndBin2=meanSDByLoc(iLoc2,1:2);
            locPairTScores(iLoc1,iLoc2,:) = [tScore abs(tScore)];
        end
    end
end

end