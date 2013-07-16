function [ SegmentationPointsData, SegmentationScore, SPIndexes] = GreedySegmentationSelection( minScoresTable, recognitionScoreTable )
%GREEDYSEGMENTATIONSELECTION Summary of this function goes here
%   Detailed explanation goes here

SegmentationScore = 0;
SPIndexes = [];

while (find(~isnan(minScoresTable)))
    [endI,startI]=find(minScoresTable==min(min(minScoresTable)));
    SPIndexes = [SPIndexes, startI, endI];
    
    SegmentationScore = SegmentationScore + minScoresTable(endI,startI);
    
    minScoresTable = RemoveIntervalFromMinMatrix(minScoresTable, startI, endI);
end
SPIndexes = unique(SPIndexes);

SegmentationPointsData = [];
for i=1:length(SPIndexes)-1
    SegmentationPointsData = [SegmentationPointsData; recognitionScoreTable(SPIndexes(i+1),SPIndexes(i))];
end

end