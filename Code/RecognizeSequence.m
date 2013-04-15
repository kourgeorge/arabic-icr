function [RecognitionResults, SumDist] = RecognizeSequence (Sequence , Alg, Position, LettersDataStructure)
%RECOGNIZESEQUENCE return a list of the most similar letters with the
%distance from the given sequence.

%C = RecognizeLetter( Sequence, LettersDataStructure, Position, Alg);

C = [];
C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Iso', Alg)];
C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Ini', Alg)];
C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Mid', Alg)];
C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Fin', Alg)];

RecognitionResults = sortrows(C,2);
RecognitionResults = RecognitionResults(1:5,:);

if (nargout==2)
    SumDist = NaN;
end

        
        