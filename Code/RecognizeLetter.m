function [Candidates,SumDist] = RecognizeLetter( LetterSequence, LettersDataStructure, Position, Alg )
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

if (strcmp(Alg(1),'EMD')==true)
    WaveletVector = CreateWaveletFromFV(FeatureVector);
    ReducedWaveletVector = COEFF*WaveletVector;
    Candidates = GetCandidateskdTree(KdTreee,ReducedWaveletVector,LettersMap);
else
    %Classify using NN
    [NNCandidates,AllDictionarySorted] = GetClosestLetterCandidates( FeatureVector, PositionDS, Alg{1} ,3);
    Candidates = NNCandidates;
end
%Clasiffy Vector using SVM 1
%CandidatesSVM1 = MultiSVMClassify( PositionDS, FeatureVector' );

%Reduce Dimensionality
FeatureVector = FeatureVector(:);
%ReducedFeatureVector = COEFF*FeatureVector;

%Clasiffy Vector using SVM 2
%[predicted_label, accuracy, decision_values] = svmpredict([1], ReducedFeatureVector', SVMStruct);
%CandidatesSVM2 = char(predicted_label);

if (nargout==2)
    SumDist = sum(cat(1,AllDictionarySorted{:,2}));
end

end


function Candidates = GetCandidateskdTree(KdTreee,vector,LettersMap)
[index_vals,vector_vals,~] = kd_knn(KdTreee,vector',6,0);
Candidates= [];
for i=1:length(index_vals)
    if (size (Candidates,1)==3)
        return;
    end
    Diff = dist2(vector_vals(i,:), vector');
    if (UniqueCandidate(LettersMap(index_vals(i)),Candidates))
        WPcell={LettersMap(index_vals(i)),Diff};
        Candidates=[Candidates ; WPcell];
    end
end
end

function res =  UniqueCandidate(Letter,Candidates)
res = true;
if (size (Candidates,1) == 0 )
    return;
end
for i=1:size (Candidates,1)
    if (strcmp(Candidates(i,1),Letter))
        res = false;
    end
end
end