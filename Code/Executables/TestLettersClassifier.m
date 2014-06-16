function [ output_args ] = TestLettersClassifier(  )
%TESTLETTERSCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');

[totalTimeIni, cpIni, numSamplesIni] = LetterPositionCrossValidation(LettersDataStructure.LettersDS.Ini);
[totalTimeMid, cpMid, numSamplesMid] = LetterPositionCrossValidation(LettersDataStructure.LettersDS.Mid);
[totalTimeFin, cpFin, numSamplesFin] = LetterPositionCrossValidation(LettersDataStructure.LettersDS.Fin);
[totalTimeIso, cpIso, numSamplesIso] = LetterPositionCrossValidation(LettersDataStructure.LettersDS.Iso);

totalSamplesNum = numSamplesIni+numSamplesMid+numSamplesFin+numSamplesIso;

IniFrac = numSamplesIni/totalSamplesNum;
MidFrac = numSamplesMid/totalSamplesNum;
FinFrac = numSamplesFin/totalSamplesNum;
IsoFrac = numSamplesIso/totalSamplesNum;

CaculateTotalTime = (totalTimeIni+totalTimeMid+totalTimeFin+totalTimeIso)/totalSamplesNum
CorrectRate = cpIni.CorrectRate*IniFrac+cpMid.CorrectRate*MidFrac+cpFin.CorrectRate*FinFrac+cpIso.CorrectRate*IsoFrac

end

function [totalTime, cp, numSamples] = LetterPositionCrossValidation(LetterPositionDS)

[FeaturesSpaceVectors,WaveletSpaceVectors,LettersGroups, ~] = ExpandLettersStructForSVM( LetterPositionDS.Struct);

sequenceVectors = LetterPositionDS.SequencesArray;
features=WaveletSpaceVectors;
%features = FlattenFeatureVectors( FeaturesSpaceVectors );

labeling = LettersGroups;
labelingCells = cellstr(LettersGroups);
cp = classperf(labelingCells);

totalTime = 0;
numSamples = size(LettersGroups,1);
kForNN = 10;
topK=5;

indices = crossvalind('Kfold', LettersGroups, 10);
for i = 1:10
    test = (indices == i);
    train = ~test;
    
    %%get the training set
    trainLabels = labeling(train);
    trainWaveletVectors = features(train,:);
    [trainFeatures, COEFF, ~] = DimensionalityReduction2( trainWaveletVectors, trainLabels, 0.98);
    
    %trainFeatures = trainWaveletVectors;
    
    %get the test set
    t1 = cputime;
    testFeatures = features(test,:);
    pcacoef = COEFF.PCACOEFF;
    PcaReduced = testFeatures * pcacoef;
    testFeatures = out_of_sample(PcaReduced,COEFF);
    e1 = cputime-t1;
    
    %class = knnclassify(testFeatures,trainFeatures,cellstr(trainLabels),3,'cityblock','random');
    
    KdTree = createns(trainFeatures,'NSMethod','kdtree','Distance','cityblock');
    t2 = cputime;
    [IDX,L1D] = knnsearch(KdTree,testFeatures,'k',kForNN);
    e2 = cputime-t2;
    e = e1+e2;
    testSetlabelingResults = trainLabels(IDX);
    
    trainSequences = sequenceVectors(train);
    testSequences = sequenceVectors(test);
    candidateSequences = trainSequences(IDX);
    [testSetlabelingResults,e3] = scoreCandidates (IDX,trainLabels,testSequences,candidateSequences);
    testSetlabelingResults = cell2mat(testSetlabelingResults(:,1:topK));
    e= e+e3;
    
    class = knnBestClass(testSetlabelingResults,labelingCells(test,:),topK);
    
    
    totalTime=totalTime+e;
    
    classperf(cp,class,test);
end
end

function bestClass = knnBestClass(knnClassification, trueClassification , k)

numInstances = size(trueClassification,1);
bestClass = cell(numInstances,1);

for i=1:numInstances
    correctClassification = false;
    for j=1:k
        if (trueClassification{i}==knnClassification(i,j))
            correctClassification = true;
            continue;
        end
    end
    if (correctClassification)
        bestClass(i) =  trueClassification(i);
    else
        bestClass(i) =  {knnClassification(i,1)};
    end
end
end

function sortedCandidateMatrix = sortCandidatesMatrix(candidateMatrix)
sortedCandidateMatrix = [];
for i=1:size(candidateMatrix,1)
    sampleCandidates= candidateMatrix(i,:);
    
    A = sampleCandidates;
    
    Afields = fieldnames(A);
    Acell = struct2cell(A);
    sz = size(Acell);
    
    % Convert to a matrix
    Acell = reshape(Acell, sz(1), []);      % Px(MxN)
    
    % Make each field a column
    Acell = Acell';                         % (MxN)xP
    
    % Sort by first field "name"
    Acell = sortrows(Acell, 2);
    
    % Put back into original cell array format
    Acell = reshape(Acell', sz);
    
    % Convert to Struct
    Asorted = cell2struct(Acell, Afields, 1);
    
    sortedCandidateMatrix = [sortedCandidateMatrix;Asorted];
end
end

function [testSetlabelingResults,scoringTime] = scoreCandidates (IDX,trainLabels,testSequences,candidateSequences)
numCandidates = size(IDX,2);
scoringTime = 0;
for column=1:numCandidates
    for row=1:size(IDX,1)
        candidate.label = trainLabels(IDX(row,column));
        t = cputime;
        candidate.scoring = Cons_DTW(candidateSequences{row,column},testSequences{row},5);
        e = cputime - t;
        scoringTime = scoringTime+ e;
        Diff(row,column) = candidate;
    end
end

Diff = sortCandidatesMatrix(Diff);
Diffcell = struct2cell(Diff);
Diffcell = Diffcell(1,:,:);
testSetlabelingResults = reshape(Diffcell, [], numCandidates);
end