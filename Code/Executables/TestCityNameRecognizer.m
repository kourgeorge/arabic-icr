function TestCityNameRecognizer()
%TestCityNameRecognizer Summary of this function goes here
global LettersDataStructure;
global Statistics;
LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
CityNamesXMLFolder  = 'C:\Users\kour\Second Degree\Hand Writing recognition\arabic-icr\Data\TestSet';

Comments = input('Enter Experiment comments\n','s');
OutputFolder = ['C:\OCRData\StrokesSegmentationOutput (',Comments,')'];

if(~exist(OutputFolder,'dir'))
    mkdir(OutputFolder);
end

xmlFolder = dir(fullfile(CityNamesXMLFolder,'*.xml'));

diary([OutputFolder,'\Results.txt']);
diary on;
disp(Comments);
disp(CityNamesXMLFolder);

NumSamples = 1000;

%startFileIndex = 1000;
Statistics = InitializeStatistics();
for i=1:min (length(xmlFolder),NumSamples)
    current_object = xmlFolder(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    if (IsFile)
        disp([num2str(i),': ','                  ',FileName]);
        [WPsResults,Name] = RecognizeCityName( [CityNamesXMLFolder,'\',FileName], false);%, OutputFolder );
        Statistics = CollectStatistics (Statistics, WPsResults, GetNumWordsInName (Name));
        
    end
end
Statistics
ShowStatistics(Statistics);
diary off;

end

function Statistics = CollectStatistics (Statistics, WPsResults, NumWords)
Statistics.NumNames = Statistics.NumNames + 1;
Statistics.NumWords = Statistics.NumWords + NumWords;
NameSegmentedCorrectly = true;
for i=1:length(WPsResults)
    WPLength = length(WPsResults(i).WPLabel);
    Statistics.NumWPs = Statistics.NumWPs + 1;
    Statistics.NumStrokes = Statistics.NumStrokes + WPsResults(i).NumStrokes;
    Statistics.WPsLengthDistribution(WPLength) = Statistics.WPsLengthDistribution(WPLength) + 1;
    
    if (WPsResults(i).CorrectSegmentation == true)
        Statistics.WPsCorrectSegmentation = Statistics.WPsCorrectSegmentation + 1;
        Statistics.SPTruePositive = Statistics.SPTruePositive + WPsResults(i).TP_SP;
        
    else
        NameSegmentedCorrectly = false;
        Statistics.SPFalsePositive = Statistics.SPFalsePositive + WPsResults(i).FP_SP;
        Statistics.SPTruePositive = Statistics.SPTruePositive + WPsResults(i).TP_SP;
        Statistics.SPFalseNegative = Statistics.SPFalseNegative + WPsResults(i).FN_SP;
    end
    
    if (WPsResults(i).CorrectRecognition == true)
        Statistics.WPsCorrectRecognition = Statistics.WPsCorrectRecognition + 1;
    end
    Statistics.TotalTime = Statistics.TotalTime + WPsResults(i).time;
end
if (NameSegmentedCorrectly==true)
    Statistics.NamesCorrectSegmentation = Statistics.NamesCorrectSegmentation + 1;
end
end


function ShowStatistics(Statistics)
%WP Level Info
WPSR = (Statistics.WPsCorrectSegmentation/Statistics.NumWPs)*100;
WPRR = (Statistics.WPsCorrectRecognition/Statistics.NumWPs)*100;
%WPOS = (Statistics.WPsOverSegmentation/(Statistics.NumWPs-Statistics.WPsCorrectSegmentation))*100;
%WPUS = (Statistics.WPsUnderSegmentation/(Statistics.NumWPs-Statistics.WPsCorrectSegmentation))*100;
WPAvgTime = Statistics.TotalTime/Statistics.NumWPs;

%City Names Level Info
NamesSR = (Statistics.NamesCorrectSegmentation/Statistics.NumNames)*100;
NamesAvgTime = Statistics.TotalTime/Statistics.NumNames;

%Words Level Info
WordsAvgTime = Statistics.TotalTime/Statistics.NumWords;
AvgWPsPerWord = Statistics.NumWPs/Statistics.NumWords;

%Strokes Level Info
AvgStrokesPerWP = Statistics.NumStrokes/Statistics.NumWPs;

% Segmentation Points Level Info
SP_TP = Statistics.SPTruePositive;
SP_FP = Statistics.SPFalsePositive;
SP_FN = Statistics.SPFalseNegative;

SP_TotalNumber = SP_TP+SP_FN; 
SP_Precision = SP_TP/(SP_TP+SP_FP);
SP_Recall  = SP_TP/(SP_TP+SP_FN);

TotalNumLetters = 0;
for i=1:length(Statistics.WPsLengthDistribution)
    TotalNumLetters = TotalNumLetters + i*Statistics.WPsLengthDistribution(i);
end

disp(' ');
disp('Strokes Level Info');
disp('--------------------');
disp (['Avg strokes per WP = ',num2str(AvgStrokesPerWP)]);

disp(' ');
disp ('WP Level Info');
disp('-----------------');
disp (['WPSR = ',num2str(WPSR)]);
disp (['WPRR = ',num2str(WPRR)]);
%disp (['WPOS = ',num2str(WPOS)]);
%disp (['WPUS = ',num2str(WPUS)]);
disp (['WPAvgTime = ',num2str(WPAvgTime)]);

disp(' ');
disp('Words Level Info');
disp('--------------------');
disp (['Estimated Words SR = ',num2str(((WPSR/100)^AvgWPsPerWord)*100)]);
disp (['Avg WPs per Word = ',num2str(AvgWPsPerWord)]);
disp (['Words AvgTime = ',num2str(WordsAvgTime)]);

disp(' ');
disp('City Names Level Info');
disp('-----------------------');
disp (['Names SR = ',num2str(NamesSR)]);
disp (['Names AvgTime = ',num2str(NamesAvgTime)]);

disp(' ');
disp('SP Level Info');
disp('----------------');
disp (['SP TP = ',num2str(SP_TP)]);
disp (['SP FP = ',num2str(SP_FP)]);
disp (['SP FN = ',num2str(SP_FN)]);
disp (['SP Precision = ',num2str(SP_Precision)]);
disp (['SP Recall = ',num2str(SP_Recall)]);
disp (['Total Leters Num= ',num2str(TotalNumLetters)]);
disp (['Total Segmentation Points = ',num2str(SP_TotalNumber)]);
end

function Statistics = InitializeStatistics()
Statistics.NumNames = 0;
Statistics.NumWords = 0;
Statistics.NumWPs = 0;
Statistics.NumStrokes = 0;
Statistics.WPsLengthDistribution = zeros (1,10);
Statistics.WPsCorrectSegmentation = 0;
%Statistics.WPsOverSegmentation = 0;
%Statistics.WPsUnderSegmentation = 0;
Statistics.WPsCorrectRecognition = 0;
Statistics.NamesCorrectSegmentation = 0;
Statistics.SPTruePositive = 0;
Statistics.SPFalsePositive = 0;
Statistics.SPFalseNegative = 0;
Statistics.TotalTime = 0;
end

function numWords = GetNumWordsInName (Name)
Name = strtrim(Name);
spaces = strfind(Name, ' ');
numWords = length(spaces) + 1;
end