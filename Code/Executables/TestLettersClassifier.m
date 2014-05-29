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

features=WaveletSpaceVectors;
%features = FlattenFeatureVectors( FeaturesSpaceVectors );

labeling = LettersGroups;
labelingCells = cellstr(LettersGroups);
cp = classperf(labelingCells);

totalTime = 0;
numSamples = size(LettersGroups,1);

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
    t = cputime;    
    testFeatures = features(test,:);
    pcacoef = COEFF.PCACOEFF;
    PcaReduced = testFeatures * pcacoef;
    testFeatures = out_of_sample(PcaReduced,COEFF);
    
    class = knnclassify(testFeatures,trainFeatures,cellstr(trainLabels),3,'cityblock','nearest');
    e = cputime-t;
    
    totalTime=totalTime+e;
    
    classperf(cp,class,test); 
end
end