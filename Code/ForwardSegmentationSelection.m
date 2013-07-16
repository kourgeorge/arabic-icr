function [ SegmentationPointsData, SegmentationScore, SPIndexes] = ForwardSegmentationSelection( minScoresTable, recognitionScoreTable)
%FORWARDSEGMENTATIONSELECTION Summary of this function goes here
%   Detailed explanation goes here

k = 1;
SegmentationPointsData = [];
SegmentationScore = 0;
SPIndexes = [1];
while (k<=size(minScoresTable,2))
    [~,minIndex] = min (minScoresTable(:,k));
    SegmentationPointsData = [SegmentationPointsData; recognitionScoreTable(minIndex,k)];
    SegmentationScore = SegmentationScore + minScoresTable(minIndex,k);
    k=minIndex;
    SPIndexes = [SPIndexes, minIndex];
end


end

