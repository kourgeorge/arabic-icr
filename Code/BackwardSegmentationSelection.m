function [ SegmentationPointsData, SegmentationScore, SPIndexes] = BackwardSegmentationSelection( minScoresTable, recognitionScoreTable )
%BACKWARDSEGMENTATIONSELECTION Summary of this function goes here
%   Detailed explanation goes here

k = size(minScoresTable,1);
SegmentationScore = 0;
SegmentationPointsData = [];
SPIndexes = [k];
while (k>1)
    [~,minIndex] = min (minScoresTable(k,:));
    SegmentationPointsData = [SegmentationPointsData; recognitionScoreTable(k,minIndex)];
    SegmentationScore = SegmentationScore + minScoresTable (k,minIndex);
    k=minIndex;
    SPIndexes = [SPIndexes, minIndex];
end

SegmentationPointsData = fliplr(SegmentationPointsData);
SPIndexes = fliplr(SPIndexes);
end

