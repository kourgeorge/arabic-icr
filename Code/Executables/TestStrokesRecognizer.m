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
startFileIndex = 1000;
Statistics = InitializeStatistics();
strokesFilesList = dir (StrokesDictionaryFolder);
for i=3+startFileIndex:startFileIndex+min (length(strokesFilesList),20)
    current_object = strokesFilesList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    if (IsFile)
        [WPsResults,Name] = RecognizeWordStrokes( [StrokesDictionaryFolder,'\',FileName], false); %%,OutputFolder%% );
        Statistics = CollectStatistics (Statistics, WPsResults, GetNumWordsInName (Name));
        disp([num2str(i-2-startFileIndex),': ',Name]);
    end
end
Statistics

WPSR = (Statistics.WPsCorrectSegmentation/Statistics.NumWPs)*100;
WPRR = (Statistics.WPsCorrectRecognition/Statistics.NumWPs)*100;
WPAvgTime = Statistics.TotalTime/Statistics.NumWPs;
AvgStrokesPerWP = Statistics.NumStrokes/Statistics.NumWPs;
WPOS = (Statistics.WPsOverSegmentation/(Statistics.NumWPs-Statistics.WPsCorrectSegmentation))*100;
WPUS = (Statistics.WPsUnderSegmentation/(Statistics.NumWPs-Statistics.WPsCorrectSegmentation))*100;
NamesSR = (Statistics.NamesCorrectSegmentation/Statistics.NumNames)*100;
WordsAvgTime = Statistics.TotalTime/Statistics.NumWords;
AvgWPsPerWord = Statistics.NumWPs/Statistics.NumWords;

disp (['WPSR = ',num2str(WPSR)]);
disp (['WPRR = ',num2str(WPRR)]);
disp (['WPOS = ',num2str(WPOS)]);
disp (['WPUS = ',num2str(WPUS)]);
disp (['WPAvgTime = ',num2str(WPAvgTime)]);
disp(' ');
disp (['Names SR = ',num2str(NamesSR)]);
disp (['Names AvgTime = ',num2str(WordsAvgTime)]);
disp(' ');
disp (['Avg strokes per WP = ',num2str(AvgStrokesPerWP)]);
disp (['Avg WPs per Word = ',num2str(AvgWPsPerWord)]);
disp ('')
disp (['Estimated Words SR = ',num2str(((WPSR/100)^AvgWPsPerWord)*100)]);

diary off;

end

function Statistics = CollectStatistics (Statistics, WPsResults, NumWords)
Statistics.NumNames = Statistics.NumNames + 1;
Statistics.NumWords = Statistics.NumWords + NumWords;
NameSegmentedCorrectly = true;
for i=1:length(WPsResults)
    strokeLength = length(WPsResults(i).Word);
    Statistics.NumWPs = Statistics.NumWPs + 1;
    Statistics.NumStrokes = Statistics.NumStrokes + WPsResults(i).NumStrokes;
    Statistics.WPsLengthDistribution(strokeLength) = Statistics.WPsLengthDistribution(strokeLength) + 1;
    if (WPsResults(i).Segmentation == 0)
        Statistics.WPsCorrectSegmentation = Statistics.WPsCorrectSegmentation + 1;
    end
    if (WPsResults(i).Segmentation > 0)
        Statistics.WPsOverSegmentation = Statistics.WPsOverSegmentation + 1;
        NameSegmentedCorrectly = false;
    end
    if (WPsResults(i).Segmentation < 0)
        Statistics.WPsUnderSegmentation = Statistics.WPsUnderSegmentation + 1;
        NameSegmentedCorrectly = false;
    end
    if (WPsResults(i).Recognition == true)
        Statistics.WPsCorrectRecognition = Statistics.WPsCorrectRecognition + 1;
    end
    Statistics.TotalTime = Statistics.TotalTime + WPsResults(i).time;
end
if (NameSegmentedCorrectly==true)
    Statistics.NamesCorrectSegmentation = Statistics.NamesCorrectSegmentation + 1;
end
end

function Statistics = InitializeStatistics()
Statistics.NumNames = 0;
Statistics.NumWords = 0;
Statistics.NumWPs = 0;
Statistics.NumStrokes = 0;
Statistics.WPsLengthDistribution = zeros (1,10);
Statistics.WPsCorrectSegmentation = 0;
Statistics.WPsOverSegmentation = 0;
Statistics.WPsUnderSegmentation = 0;
Statistics.WPsCorrectRecognition = 0;
Statistics.NamesCorrectSegmentation = 0;
Statistics.TotalTime = 0;
end


function numWords = GetNumWordsInName (Name) 
Name = strtrim(Name);
spaces = strfind(Name, ' ');
numWords = length(spaces) + 1;
end