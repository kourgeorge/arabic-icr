function [ SegmentationPointsData, SegmentationScore] = BackwardSegmentationSelection( minScoresTable, recognitionScoreTable )
%BACKWARDSEGMENTATIONSELECTION Summary of this function goes here
%   Detailed explanation goes here

k = size(minScoresTable,1);
SegmentationScore = 0;
SegmentationPointsData = [];
while (k>1)
    [~,minIndex] = min (minScoresTable(k,:));
    SegmentationPointsData = [SegmentationPointsData; recognitionScoreTable(k,minIndex)];
    SegmentationScore = SegmentationScore + minScoresTable (k,minIndex);
    k=minIndex;
end

SegmentationPointsData = fliplr(SegmentationPointsData);

end

