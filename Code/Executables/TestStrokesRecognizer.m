function TestStrokesRecognizer()
%TESTSTROKESRECOGNIZER Summary of this function goes here
global LettersDataStructure;
LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
StrokesDictionaryFolder  = 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\ParsedADABWords';

%HandleOutputFolder
Comments = input('Enter Experiment comments\n','s');
OutputFolder = ['C:\OCRData\StrokesSegmentationOutput (',Comments,')'];

if(~exist(OutputFolder,'dir'))
    mkdir(OutputFolder);
end

TotalStrokes = 0;
TotalCorrectRecognition = 0;
TotalCorrectSegmentation = 0;
fig = figure();
ax = axes();
strokesFilesList = dir (StrokesDictionaryFolder);
for i=3:min (length(strokesFilesList),500)
    current_object = strokesFilesList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name
    if (IsFile)
        [ NumOfWordParts ,NumOfCorrectRecognition, NumOfCorrectlySegmentedStrokes] = RecognizeStrokeFromFile( [StrokesDictionaryFolder,'\',FileName], false, ax, OutputFolder );
        TotalStrokes = TotalStrokes + NumOfWordParts;
        TotalCorrectRecognition = TotalCorrectRecognition + NumOfCorrectRecognition;
        TotalCorrectSegmentation = TotalCorrectSegmentation + NumOfCorrectlySegmentedStrokes;
    end
end
RecognitionResults = TotalCorrectRecognition/TotalStrokes
SegmentationResults = TotalCorrectSegmentation/TotalStrokes

end

