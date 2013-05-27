function [RecognitionResults, SumDist] = RecognizeSequence (Sequence , RecParams, Position, LettersDataStructure)
%RECOGNIZESEQUENCE return a list of the most similar letters with the
%distance from the given sequence.

%C = RecognizeLetter( Sequence, LettersDataStructure, Position, Alg);

C = [];

if (strcmp(Position,'Mid'))
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Mid', RecParams)];
end
if (strcmp(Position,'Fin'))
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Fin', RecParams)];
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Mid', RecParams)];
end
if (strcmp(Position,'Iso'))
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Iso', RecParams)];
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Ini', RecParams)];
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Fin', RecParams)];
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Mid', RecParams)];
end

if (strcmp(Position,'Ini'))
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Ini', RecParams)];
    C = [C; RecognizeLetter( Sequence, LettersDataStructure, 'Mid', RecParams)];
    
end

%C = [C; RecognizeLetter( Sequence, LettersDataStructure, Position, RecParams)];

RecognitionResults = sortrows(C,2);
RecognitionResults = RecognitionResults(1:min(RecParams.NumCandidates,end),:);

if (nargout==2)
    SumDist = NaN;
end

        
        