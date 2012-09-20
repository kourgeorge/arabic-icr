function [RecognitionResults,SumDist] = RecognizeSequenceOLD(Sequence , Alg, Position, LettersDataStructure)
%RECOGNIZESEQUENCE Summary of this function goes here
%   Detailed explanation goes here

FeatureType = 0;
if (strcmp(Alg(1),'EMD'))
    %EMD
else
    %DTW
end

if (strcmp(Alg(2),'MSC'))
    FeatureType = 1;
    FeatureName = 'Angular';
else
    FeatureType = 2;
    FeatureName = 'ShapeContext';
end

if (strcmp(Alg(3),'kdTree'))
    kdTreeFilePath = ['C:\OCRData\kdTree',Position,'\',FeatureName];

    C = RecognizeLetter( Sequence, LettersDataStructure, Position, 'DTW');
    %C = RecognizeWPkdTree( Sequence, kdTreeFilePath, FeatureType, 3 );
    %C_Dist = CalculateSumDistanceCandidatesFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType ,C);
    RecognitionResults = [];
    for i=1:length(C)
        RecognitionResults = [RecognitionResults;{C(i,1),C{i,2}}];%CalculateSumDistanceCandidatesFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType ,C(i))}];
    end
else
    LSHFilePath = ['C:\OCRData\LSH',Letters,'\',FeatureName];
    SumDist=CalculateSumDistanceFromCenters_LSH( Sequence, LSHFilePath, FeatureType );
    C = RecognizeWPLSH( Sequence, kdTreeFilePath, FeatureType, 3 );
    C_Dist =  CalculateSumDistanceCandidatesFromCenters_LSH( Sequence, LSHFilePath, FeatureType ,C);
end
if (nargout==2)
    SumDist=C{4}+C{5}+C{6};%CalculateSumDistanceFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType );
end
