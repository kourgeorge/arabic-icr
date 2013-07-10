function SegmentationPoints = GetWPSegmentationPointsFromResults(WPResults)
%GetWPSegmentationPointsFromResults Summary of this function goes here
%   Detailed explanation goes here
SegmentationPoints = [];
Sequence = [];
for i=1:length(WPResults)
    strokeSPs = WPResults(i).SegmentationPoints;
    for k=1:length(strokeSPs)
        SegmentationPoint.Point = strokeSPs{k}.Point+length(Sequence);
        SegmentationPoint.Candidates = strokeSPs{k}.Candidates;
        SegmentationPoints = [SegmentationPoints;SegmentationPoint ] ;  
    end
    Sequence = [Sequence;WPResults(i).Sequence;[Inf,Inf]];
end

end

