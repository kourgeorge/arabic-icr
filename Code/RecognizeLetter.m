function [Candidates,SumDist] = RecognizeLetter( LetterSequence, LettersDataStructure, Position, RecParams )
%RECOGNIZELETTER Load the letters data structure and tries recognizes a
%letter in a given position.
%   Usage: k = dlmread(['C:\OCRData\GeneratedWordsMed\sample2\_8_.m']);
global pos;
pos = Position;

LettersDS = LettersDataStructure.LettersDS;
FeatureType = LettersDataStructure.FeatureType;
ResampleSize = LettersDataStructure.ResampleSize;

LetterPositionDS = getfield(LettersDS,Position);

NormalizedLetterSequence = NormalizeCont(LetterSequence);
[~,SimplifiedLetterSequence] = SimplifyContour( NormalizedLetterSequence);
ResampledLetterSequence = ResampleContour(SimplifiedLetterSequence,ResampleSize);
FeatureVector = CreateFeatureVectorFromContour(ResampledLetterSequence, FeatureType);

if (strcmp(RecParams.Alg(1),'EMD')==true)
    WaveletVector = CreateWaveletFromFV(FeatureVector);
    pcacoef = LetterPositionDS.COEFF.PCACOEFF;
    PCAWaveletVector = WaveletVector' * pcacoef;
    ReducedWaveletVector = out_of_sample(PCAWaveletVector,LetterPositionDS.COEFF);
    Candidates = GetCandidateskdTree(LetterPositionDS.KdTree,ReducedWaveletVector',LetterPositionDS.LettersMap, RecParams.NumCandidates,LetterPositionDS.FeaturesSpaceVectors,LetterPositionDS.SequencesArray);

    InputSequence = FeatureVector;
    for i=1: size(Candidates,1)    
        LetterCandidateFeatureVector = Candidates{i,4}';
        Diff = Cons_DTW(InputSequence,LetterCandidateFeatureVector{1},5);
        Candidates{i,2} = (Candidates{i,2}+Diff)/2;
    end

    Candidates = Candidates(:,1:3);
    
else
    %Classify using NN
    [NNCandidates,AllDictionarySorted] = GetClosestLetterCandidates( FeatureVector, PositionDS, RecParams.Alg{1} ,3);
    Candidates = NNCandidates;
end

if (nargout==2)
    SumDist = sum(cat(1,AllDictionarySorted{:,2}));
end

end


function Candidates = GetCandidateskdTree(KdTreee,vector,LettersMap, NumCandidates,FeaturesSpaceVectors,SequencesArray)
global pos;
[IDX,D] = knnsearch(KdTreee,vector','k',90);
Candidates= [];
for i=1:length(IDX)
    if (size (Candidates,1)==NumCandidates)
        return;
    end
    Diff = D(i);
    if (UniqueCandidate(AddPoisitionIndicator(LettersMap(IDX(i)),pos),Candidates))
        WPcell={ AddPoisitionIndicator(LettersMap(IDX(i)),pos),Diff , SequencesArray(IDX(i)),FeaturesSpaceVectors(IDX(i))};
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