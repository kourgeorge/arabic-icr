function [SegmentedCorrectly, TP_SP, FP_SP, FN_SP] = IsWPSegmentedCorrectly( WPResults,WPInfo)
%ISWPSEGMENTEDCORRECTLY Summary of this function goes here
%   Detailed explanation goes here

Sequence = WPInfo.Sequence;
GT_SPIndexes = WPInfo.SPs;
GT_SP_Array = zeros(length(GT_SPIndexes),1);
nomatch = 0;
for i=1:length(WPResults)
    currentSP = WPResults(i).Point;
    matchedToTrueSP = false;
    %look for the corresponding Segmentation Point is the GT.
    for k=1:length(GT_SPIndexes)
        if(GT_SPIndexes(k) < currentSP)
            InfoMeas = InformationMeasure(Sequence(GT_SPIndexes(k):currentSP,:),1/75);
        else
            InfoMeas = InformationMeasure(Sequence(currentSP:GT_SPIndexes(k),:),1/75);
        end
        if (InfoMeas < 1)
            GT_SP_Array(k) = GT_SP_Array(k) + 1;
            matchedToTrueSP = true;
            break;
        end
    end
    if (~matchedToTrueSP)
        nomatch = nomatch+1; %no corresponding true SP for the current SP.
    end
end

TP_SP = sum(GT_SP_Array>=1);
FP_SP = nomatch + sum(GT_SP_Array>1);
FN_SP = sum(GT_SP_Array == 0);

if (nomatch ==0 && FP_SP == 0 && FN_SP == 0 && all(GT_SP_Array))
    SegmentedCorrectly = true;
else
    SegmentedCorrectly = false;
end
