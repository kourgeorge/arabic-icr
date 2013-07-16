function [ SegmentationPointsData, SegmentationScore, SPIndexes] = YASegmentationSelection ( minScoresTable, recognitionScoreTable )
%YASEGMENTATIONSELECTIONALGORITHM Summary of this function goes here
%   Detailed explanation goes here

NumCandidates = size(minScoresTable,1);
candidatesSet = 2:1:NumCandidates-1;
SPIndexes = [1,NumCandidates];
SegmentationScore = 0;
P1 = 1;
P2 = NumCandidates;
while (~isempty(candidatesSet))
    
    [~,endP1] = min (minScoresTable(:,P1));
    SPIndexes = [SPIndexes, endP1];
    candidatesSet = candidatesSet(candidatesSet>endP1);
    SegmentationScore = SegmentationScore + minScoresTable(endP1,P1);
    minScoresTable = RemoveIntervalFromMinMatrix(minScoresTable, P1, endP1);
    P1 = endP1;
    
    [~,beginP2] = min (minScoresTable(P2,:));
    SPIndexes = [SPIndexes, beginP2];
    candidatesSet =  candidatesSet(candidatesSet<beginP2);
    SegmentationScore = SegmentationScore + minScoresTable(P2,beginP2);
    minScoresTable = RemoveIntervalFromMinMatrix(minScoresTable, beginP2, P2);
    P2 = beginP2;
    
end
SPIndexes = unique(SPIndexes);
SegmentationPointsData = [];
for i=1:length(SPIndexes)-1
    SegmentationPointsData = [SegmentationPointsData; recognitionScoreTable(SPIndexes(i+1),SPIndexes(i))];
end
end

