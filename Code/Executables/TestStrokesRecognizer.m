function TestStrokesRecognizer()
%TESTSTROKESRECOGNIZER Summary of this function goes here
global LettersDataStructure;
global Statistics;
LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
StrokesDictionaryFolder  = 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\ParsedADABWords_Copy';

%HandleOutputFolder
Comments = input('Enter Experiment comments\n','s');
OutputFolder = ['C:\OCRData\StrokesSegmentationOutput (',Comments,')'];

if(~exist(OutputFolder,'dir'))
    mkdir(OutputFolder);
end

diary([OutputFolder,'\Results.txt']);
diary on;

fig = figure();
ax = axes();
Statistics = InitializeStatistics();
strokesFilesList = dir (StrokesDictionaryFolder);
for i=3:min (length(strokesFilesList),2000)
    current_object = strokesFilesList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    if (IsFile)
        Results = RecognizeWordStrokes( [StrokesDictionaryFolder,'\',FileName], false, OutputFolder, ax );
        CollectStatistics (Results);
    end
end
Statistics

SR = (Statistics.StrokesCorrectSegmentation/Statistics.NumStrokes)*100;
RR = (Statistics.StrokesCorrectRecognition/Statistics.NumStrokes)*100;
disp (['SR = ',num2str(round(SR))]);
disp (['RR = ',num2str(round(RR))]);

close(fig);
diary off;

end

function CollectStatistics (Results)
global Statistics;
if (isempty(Results))
    return;
end;

Statistics.NumWords = Statistics.NumWords + 1;
for i=1:length(Results)
    strokeLength = length(Results(i).Word);
    Statistics.NumStrokes = Statistics.NumStrokes + 1;
    Statistics.StrokesLengthDistribution(strokeLength) = Statistics.StrokesLengthDistribution(strokeLength) + 1;
    if (Results(i).Segmentation == 0)
        Statistics.StrokesCorrectSegmentation = Statistics.StrokesCorrectSegmentation + 1;
    end
    if (Results(i).Segmentation > 0)
        Statistics.StrokesOverSegmentation = Statistics.StrokesOverSegmentation + 1;
    end
    if (Results(i).Segmentation < 0)
        Statistics.StrokesUnderSegmentation = Statistics.StrokesUnderSegmentation + 1;
    end
    if (Results(i).Recognition == true)
        Statistics.StrokesCorrectRecognition = Statistics.StrokesCorrectRecognition + 1;
    end
end
end

function Statistics = InitializeStatistics()
    Statistics.NumWords = 0;
    Statistics.NumStrokes = 0;
    Statistics.StrokesLengthDistribution = zeros (1,10);
    Statistics.StrokesCorrectSegmentation = 0;
    Statistics.StrokesOverSegmentation = 0;
    Statistics.StrokesUnderSegmentation = 0;
    Statistics.StrokesCorrectRecognition = 0;
end