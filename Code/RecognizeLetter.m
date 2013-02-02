function [Candidates,SumDist] = RecognizeLetter( LetterSequence, LettersDataStructure, Position, Metric )
%RECOGNIZELETTER Load the letters data structure and tries recognizes a
%letter in a given position.
%   Usage: k = dlmread(['C:\OCRData\GeneratedWordsMed\sample2\_8_.m']);

LettersDS = LettersDataStructure.LettersDS;
FeatureType = LettersDataStructure.FeatureType;
ResampleSize = LettersDataStructure.ResampleSize;

if (strcmp(Position,'Ini'))
    SVMStruct = LettersDS.Ini.SVMStruct;
    COEFF = LettersDS.Ini.COEFF;
    PositionDS =  LettersDS.Ini.Struct;
    KdTreee = LettersDS.Ini.KdTree;
    LettersMap = LettersDS.Ini.LettersMap;
elseif (strcmp(Position,'Mid'))
    SVMStruct = LettersDS.Mid.SVMStruct;
    COEFF = LettersDS.Mid.COEFF;
    PositionDS =  LettersDS.Mid.Struct;
    KdTreee = LettersDS.Mid.KdTree;
    LettersMap = LettersDS.Mid.LettersMap;
elseif (strcmp(Position,'Fin'))
    SVMStruct = LettersDS.Fin.SVMStruct;
    COEFF = LettersDS.Fin.COEFF;
    PositionDS =  LettersDS.Fin.Struct;
    KdTreee = LettersDS.Fin.KdTree;
    LettersMap = LettersDS.Fin.LettersMap;
elseif (strcmp(Position,'Iso'))
    SVMStruct = LettersDS.Iso.SVMStruct;
    COEFF = LettersDS.Iso.COEFF;
    PositionDS =  LettersDS.Iso.Struct;
    KdTreee = LettersDS.Iso.KdTree;
    LettersMap = LettersDS.Iso.LettersMap;
else return;
end

%Sequence Pre-Processing = Normalization->Simplification->Resampling
NormalizedLetterSequence = NormalizeCont(LetterSequence);
SimplifiedLetterSequence = SimplifyContour( NormalizedLetterSequence);
ResampledLetterSequence = ResampleContour(SimplifiedLetterSequence,ResampleSize);

%Activate to see the subsequences that are given from ProcessNewPoint
%figure;
%scatter(ResampledLetterSequence(:,1),ResampledLetterSequence(:,2))

%Extract Feature Vector
FeatureVector = CreateFeatureVectorFromContour(ResampledLetterSequence, FeatureType);

%Classify using NN
[NNCandidates,AllDictionarySorted] = GetClosestLetterCandidates( FeatureVector, PositionDS, Metric ,3);
Candidates = NNCandidates;

%Clasiffy Vector using SVM 1
%CandidatesSVM1 = MultiSVMClassify( PositionDS, FeatureVector' );

%Reduce Dimensionality
FeatureVector = FeatureVector(:);
ReducedFeatureVector = COEFF*FeatureVector;

%Clasiffy Vector using SVM 2
%[predicted_label, accuracy, decision_values] = svmpredict([1], ReducedFeatureVector', SVMStruct);
%CandidatesSVM2 = char(predicted_label);

%Classify Using Kdtree
[index_vals,vector_vals,final_nodes] = kd_knn(KdTreee,ReducedFeatureVector',3,0);

ClosestWPs= [];
for i=1:length(index_vals)
    ClosestWPs = [ClosestWPs ; LettersMap(index_vals(i))];
end


if (nargout==2)
    SumDist = sum(cat(1,AllDictionarySorted{:,2}));
end

end

