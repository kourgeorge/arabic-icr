function GetCandidatesFromRecState( RecState )
%GETCANDIDATESFROMRECSTATE Summary of this function goes here
%   Detailed explanation goes here
for i=1:RecState.LCCPI
    if (i==1)
        startIndex = num2str(0);
    else
        BLCCPP = RecState.CriticalCPs(i-1).Point;
        startIndex = num2str(BLCCPP);
    end
    LCCP =  RecState.CriticalCPs(i);
    LCCPP = LCCP.Point;
    endIndex = num2str(LCCPP);
    i_str = num2str(i);
    disp (['State : ',i_str,',  ',startIndex,' - ',endIndex])
    CurrCan = LCCP.Candidates(:,1);
    str = '';
    for j=1:size(CurrCan,1)
        str = [str,' ',CurrCan{j}{1}];
    end
    disp(['Candidates:  ',str])
end


end

