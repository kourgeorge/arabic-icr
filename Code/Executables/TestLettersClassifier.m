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
features = FlattenFeatureVectors( FeaturesSpaceVectors );

labeling = LettersGroups;
labelingCells = cellstr(LettersGroups);
cp = classperf(labelingCells);

totalTime = 0;
numSamples = size(LettersGroups,1);
k = 5;

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
    [IDX,~] = knnsearch(KdTree,testFeatures,'k',k);    
    e2 = cputime-t2;
    
    class = knnBestClass(trainLabels(IDX),labelingCells(test,:),k);
    
    e = e1+e2;
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