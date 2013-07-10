function [ SegmentationPointsData, SegmentationScore] = GreedySegmentationSelection( minScoresTable, recognitionScoreTable )
%GREEDYSEGMENTATIONSELECTION Summary of this function goes here
%   Detailed explanation goes here

SegmentationScore = 0;
SPI = [];
SegmentationPointsData = [];
while (find(~isnan(minScoresTable)))
    [endI,startI]=find(minScoresTable==min(min(minScoresTable)));
    SPI = [SPI; startI ; endI];
    
    SegmentationScore = SegmentationScore + minScoresTable(endI,startI);
    for k=startI:endI-1
        minScoresTable(:,k) = NaN;
    end
    
    for k=startI+1:endI
        minScoresTable(k,:) = NaN;
    end
    
    for c=1:startI
        minScoresTable(endI:end,c)=NaN;
    end
end
SPI = unique(SPI);
for i=1:length(SPI)-1
    SegmentationPointsData = [SegmentationPointsData; recognitionScoreTable(SPI(i+1),SPI(i))];
end

end

