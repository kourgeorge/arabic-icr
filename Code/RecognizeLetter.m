function [Candidates,SumDist] = RecognizeLetter( LetterSequence, LettersDataStructure, Position, Metric )
%RECOGNIZELETTER Load the letters data structure and tries recognizes a
%letter in a given position.
%   Usage: k = dlmread(['C:\OCRData\GeneratedWordsMed\sample2\_8_.m']);
%          Old - RecognizeLetter( k, 'C:\OCRData\TargetFolder\LettersDS', 'Mid', 'DTW' )

LettersDS = LettersDataStructure.LettersDS;
FeatureType = LettersDataStructure.FeatureType;
ResampleSize = LettersDataStructure.ResampleSize;

if (strcmp(Position,'Ini'))
    PositionDS = LettersDS.Ini;
elseif (strcmp(Position,'Mid'))
    PositionDS = LettersDS.Mid;
elseif (strcmp(Position,'Fin'))
    PositionDS = LettersDS.Fin;
elseif (strcmp(Position,'Iso'))
    PositionDS = LettersDS.Iso;
else return;
end
ResampledLetterSequence = ResampleContour(LetterSequence,ResampleSize);
SequenceFV = CreateFeatureVectorFromContour(ResampledLetterSequence, FeatureType);

%[NNCandidates,AllDictionarySorted] = GetClosestLetterCandidates( SequenceFV, PositionDS, Metric ,3);
Candidates = MultiSVMClassify( PositionDS, SequenceFV' );

if (nargout==2)
SumDist = sum(cat(1,AllDictionarySorted{:,2}));
end

end

