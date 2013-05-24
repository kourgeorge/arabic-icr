function [Candidates,SumDist] = RecognizeLetter( LetterSequence, LettersDataStructure, Position, RecParams )
%RECOGNIZELETTER Load the letters data structure and tries recognizes a
%letter in a given position.
%   Usage: k = dlmread(['C:\OCRData\GeneratedWordsMed\sample2\_8_.m']);
global pos;
pos = Position;

LettersDS = LettersDataStructure.LettersDS;
FeatureType = LettersDataStructure.FeatureType;
ResampleSize = LettersDataStructure.ResampleSize;

if (strcmp(Position,'Ini'))
    SVMStruct = LettersDS.Ini.SVMStruct;
    COEFF = LettersDS.Ini.COEFF;
    PositionDS =  LettersDS.Ini.Struct;
    KdTreee = LettersDS.Ini.KdTree;
    LettersMap = LettersDS.Ini.LettersMap;
    FeaturesSpaceVectors = LettersDS.Ini.FeaturesSpaceVectors;
    
elseif (strcmp(Position,'Mid'))
    SVMStruct = LettersDS.Mid.SVMStruct;
    COEFF = LettersDS.Mid.COEFF;
    PositionDS =  LettersDS.Mid.Struct;
    KdTreee = LettersDS.Mid.KdTree;
    LettersMap = LettersDS.Mid.LettersMap;
    FeaturesSpaceVectors = LettersDS.Mid.FeaturesSpaceVectors;
    
elseif (strcmp(Position,'Fin'))
    SVMStruct = LettersDS.Fin.SVMStruct;
    COEFF = LettersDS.Fin.COEFF;
    PositionDS =  LettersDS.Fin.Struct;
    KdTreee = LettersDS.Fin.KdTree;
    LettersMap = LettersDS.Fin.LettersMap;
    FeaturesSpaceVectors = LettersDS.Fin.FeaturesSpaceVectors;
    
elseif (strcmp(Position,'Iso'))
    SVMStruct = LettersDS.Iso.SVMStruct;
    COEFF = LettersDS.Iso.COEFF;
    PositionDS =  LettersDS.Iso.Struct;
    KdTreee = LettersDS.Iso.KdTree;
    LettersMap = LettersDS.Iso.LettersMap;
    FeaturesSpaceVectors = LettersDS.Iso.FeaturesSpaceVectors;
    
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

if (strcmp(RecParams.Alg(1),'EMD')==true)
    WaveletVector = CreateWaveletFromFV(FeatureVector);
    pcacoef = COEFF.PCACOEFF;
    PCAWaveletVector = WaveletVector' * pcacoef;
    ReducedWaveletVector = out_of_sample(PCAWaveletVector,COEFF);
    Candidates = GetCandidateskdTree(KdTreee,ReducedWaveletVector',LettersMap, RecParams.NumCandidates,FeaturesSpaceVectors);

    InputSequence = FeatureVector;
    for i=1: size(Candidates,1)    
        LetterCandidate = Candidates{i,3}';
        [m1,~] = size(InputSequence);
        [m2,~] = size(LetterCandidate{1});
        [p,q,D,Diff,WarpingPath] = DTWContXY(InputSequence,LetterCandidate{1});
        Candidates{i,2} = Diff;
    end

    Candidates = Candidates(:,1:3);
    
else
    %Classify using NN
    [NNCandidates,AllDictionarySorted] = GetClosestLetterCandidates( FeatureVector, PositionDS, RecParams.Alg{1} ,3);
    Candidates = NNCandidates;
end
%Clasiffy Vector using SVM 1
%CandidatesSVM1 = MultiSVMClassify( PositionDS, FeatureVector' );

%Reduce Dimensionality
FeatureVector = FeatureVector(:);
%ReducedFeatureVector = COEFF*FeatureVector;

%Clasiffy Vector using SVM 2
%[predicted_label, accuracy, decision_values] = svmpredict([1], ReducedWaveletVector', SVMStruct);
%CandidatesSVM2 = char(predicted_label);

if (nargout==2)
    SumDist = sum(cat(1,AllDictionarySorted{:,2}));
end

end


function Candidates = GetCandidateskdTree(KdTreee,vector,LettersMap, NumCandidates,FeaturesSpaceVectors)
global pos;
[IDX,D] = knnsearch(KdTreee,vector','k',90);
Candidates= [];
for i=1:length(IDX)
    if (size (Candidates,1)==NumCandidates)
        return;
    end
    %Diff = dist2(vector_vals(i,:), vector');  %Approx. EMD is an L1 Metric, thus this is wrong. 
    Diff = D(i);
    if (UniqueCandidate(AddPoisitionIndicator(LettersMap(IDX(i)),pos),Candidates))
        WPcell={ AddPoisitionIndicator(LettersMap(IDX(i)),pos),Diff , FeaturesSpaceVectors(IDX(i))};
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

function res = AddPoisitionIndicator (Letter, Pos)
switch Pos
    case 'Ini' 
        res = [Letter,'_'];
    case 'Mid' 
        res = ['_', Letter, '_'];
    case 'Fin'
        res = ['_',Letter];
    otherwise
        res = Letter;
end
end