function [RecognitionResults, SumDist] = RecognizeSequence (Sequence , RecParams, Position, LettersDataStructure)
%RECOGNIZESEQUENCE return a list of the most similar letters with the
%distance from the given sequence.

%C = RecognizeLetter( Sequence, LettersDataStructure, Position, Alg);

C = [];

% if (strcmp(Position,'Fin') || strcmp(Position,'Mid'))
%     C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Mid', Alg)];
%     C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Fin', Alg)];
% else
%     C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Iso', Alg)];
%     C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Ini', Alg)];
% end

C = [C; RecognizeLetter( Sequence, LettersDataStructure, Position, RecParams)];

RecognitionResults = sortrows(C,2);
RecognitionResults = RecognitionResults(1:min(RecParams.NumCandidates,end),:);

if (nargout==2)
    SumDist = NaN;
end

        
        