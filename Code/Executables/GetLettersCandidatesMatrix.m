function [ LettersMatrix ] = GetLettersCandidatesMatrix( RecResults )
%GetLettersCandidatesMatrix Summary of this function goes here
%   Detailed explanation goes here
LetterIndex = 1;
for i=1:size(RecResults,2)
    StrokeRecResults = RecResults(i);
    for j=1:length(StrokeRecResults.SegmentationPoints)
        LettersRecResults = StrokeRecResults.SegmentationPoints{j};
        LetterCandidates = LettersRecResults.Candidates;
        LetterCandidates = LetterCandidates(:,1:2);
        LetterCandidatesMat = cell2mat(LetterCandidates(:,2));
        SumCandidates = sum(LetterCandidatesMat);
        LetterCandidatesMat = bsxfun(@rdivide,repmat( SumCandidates,length(LetterCandidatesMat),1),LetterCandidatesMat);
        SumCandidates = sum(LetterCandidatesMat);
        LetterCandidatesMat = bsxfun(@ldivide,repmat( SumCandidates,length(LetterCandidatesMat),1),LetterCandidatesMat);
        
        for Candidateindex=1:length(LetterCandidatesMat)
            LetterCandidates{Candidateindex,2} = LetterCandidatesMat(Candidateindex);
            LetterInfo.Label = LetterCandidates{Candidateindex,1};
            LetterInfo.Score = LetterCandidates{Candidateindex,2};
            LettersMatrix(LetterIndex,Candidateindex) = LetterInfo; 
        end
        LetterIndex = LetterIndex +1;
    end
end
end

