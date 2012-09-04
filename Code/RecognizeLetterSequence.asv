function [RecognitionResults,SumDist] = RecognizeLetterSequence(Sequence , Alg, Position, LettersMatrix)
%RECOGNIZESEQUENCE Summary of this function goes here
%   Detailed explanation goes here

if (strcmp(Alg(2),'MSC'))
    FeatureType = 1;
    FeatureName = 'Angular';
else
    FeatureType = 2;
    FeatureName = 'ShapeContext';
end

if (strcmp(Alg(3),'kdTree'))
    kdTreeFilePath = ['C:\OCRData\kdTree',Position,'\',FeatureName];
   
    C = RecognizeLetter( Sequence, kdTreeFilePath, FeatureType, 3 );
    
    RecognitionResults = [];
    for i=1:length(C)
        RecognitionResults = [RecognitionResults;{C(i),CalculateSumDistanceCandidatesFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType ,C(i))}];
    end
else
    LSHFilePath = ['C:\OCRData\LSH',Letters,'\',FeatureName];
    SumDist=CalculateSumDistanceFromCenters_LSH( Sequence, LSHFilePath, FeatureType );
    C = RecognizeWPLSH( Sequence, kdTreeFilePath, FeatureType, 3 );
    C_Dist =  CalculateSumDistanceCandidatesFromCenters_LSH( Sequence, LSHFilePath, FeatureType ,C);
end
if (nargout==2)
    SumDist=CalculateSumDistanceFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType );
end
