function res = GetCandidatesFromRecState( RecState )
%GETCANDIDATESFROMRECSTATE Summary of this function goes here
%   Detailed explanation goes here
res = '';
segmentationPoints = RecState.SegmentationPoints;
for i=1:length(segmentationPoints) 
    if (i==1)
        startIndex = num2str(1);
    else
        BLCCPP = segmentationPoints{i-1}.Point;
        startIndex = num2str(BLCCPP);
    end
    LCCP =  segmentationPoints{i};
    LCCPP = LCCP.Point;
    endIndex = num2str(LCCPP);
    i_str = num2str(i);
    %res = [res, 'Letter : ',i_str,',  ',startIndex,' - ',endIndex, sprintf('\n')];
    CurrCan = LCCP.Candidates(:,1);
    str = '';
    for j=1:size(CurrCan,1)
        str = [str,' ',CurrCan{j}];
    end
    res = [res, 'Letter ', num2str(i), ':  ',str, sprintf('\n')];
end


end

