function [CandidateLetters,AllDictionarySorted] = GetClosestLetterCandidates( CandidateSequence, PositionLettersDS, MetricType ,NumOfClosest)
%GETCLOSESTLETTERCANDIDATES Summary of this function goes here
%   Detailed explanation goes here

Num=0;
CandidateLetters =  [];
for i = 1:size(PositionLettersDS,1)
    Letter = PositionLettersDS{i,1};
    LetterCandidates = PositionLettersDS{i,2};
    for j=1:size(LetterCandidates,2)
        LetterCandidate = LetterCandidates{j};
        switch (MetricType)
            case 'DTW',
                [p,q,D,Diff,WarpingPath] = DTWContXY(CandidateSequence,LetterCandidate);
            case 'Res_DTW'
                %%%% Restricted DTW Demo  %%%%%%
                [m1,n1] = size(CandidateSequence);
                [m2,n2] = size(LetterCandidate);
                r=abs(m2-m1)+5;
                Diff = Cons_DTW(CandidateSequence,LetterCandidate,r);
                
            case 'App_EMD',
                [f,Diff] = EmdContXY(CandidateSequence,LetterCandidate);
            case 'ERP',
                Diff = ERPContXY(CandidateSequence,LetterCandidate);
        end
        WPcell={Letter,Diff};
        CandidateLetters=[CandidateLetters ; WPcell];
        Num=Num+1;
    end
end

CandidateLetters = sortcell(CandidateLetters,[2,1]);
if (nargout==2)
    AllDictionarySorted = CandidateLetters;
end

CandidateLetters = CandidateLetters(1:NumOfClosest,:);


end

