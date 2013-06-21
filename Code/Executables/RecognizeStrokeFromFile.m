function [ NumOfWordParts ,NumOfCorrectRecognition ,NumOfCorrectlySegmentedStrokes ] = RecognizeStrokeFromFile(xmlFile, LoadDataStructure, OutputFolder, ax )
%RECOGNIZESTROKEFROMFILE Summary of this function goes here

%   RecognizeStrokeFromFile( 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\ParsedADABWords\1232017002109.xml' , true, 'C:\OCRData\StrokeOutput\')

global LettersDataStructure;
if (LoadDataStructure ==true)
    LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
end

if (~strcmp(OutputFolder(end),'\'))
    OutputFolder = [OutputFolder,'\'];
end
if(~exist(OutputFolder,'dir'))
    mkdir(OutputFolder);
end

if (nargin<4)
    ax = axes();
end

WPStructArray = XML2WPStructArray( xmlFile );

NormalizedWPStructArray = NormalizeWPStructArray(WPStructArray);

FilteredSequenceArray = FilterIllegalSequences (NormalizedWPStructArray);

NumOfWordParts = 0;
NumOfCorrectRecognition = 0;
NumOfCorrectlySegmentedStrokes = 0;

if (isempty(FilteredSequenceArray))
    return;
end

for i=1:length(FilteredSequenceArray)
    [MainStrokesResults,AdditionalStrokesResults] = SimulateOnlineRecognizer( FilteredSequenceArray(i).Sequence, false, false );
    MainStrokesResults = [MainStrokesResults;AdditionalStrokesResults];
    
    adaptedStr = AdaptString(FilteredSequenceArray(i).Label);
    [LetterNumDiff, CorrectRecognition] = IsWordRecognizedCorrectly(MainStrokesResults,adaptedStr);
    
    
    if (CorrectRecognition == true || LetterNumDiff ==0 )
        NumOfCorrectlySegmentedStrokes = NumOfCorrectlySegmentedStrokes + 1;
    end
    
    if (CorrectRecognition==true)
        NumOfCorrectRecognition = NumOfCorrectRecognition + 1;
    else
        folderName = [OutputFolder,FilteredSequenceArray(i).Label,'_',xmlFile(end-16:end-4)];
        mkdir(folderName);
        dlmwrite([folderName,'\sequence.m'], FilteredSequenceArray(i).Sequence);
        error_str = GetCandidatesFromRecState( MainStrokesResults );
        disp (error_str)
        fid = fopen([folderName,'\result.txt'], 'wt');
        fprintf(fid, '%s', error_str);
        fclose(fid);
        hold off;
        plot (ax,MainStrokesResults.Sequence(:,1),MainStrokesResults.Sequence(:,2),'LineWidth',3);
        hold on;
        for k=1:length(MainStrokesResults.SegmentationPoints)
            LCCP =  MainStrokesResults.SegmentationPoints{k};
            endIndex = LCCP.Point;
            plot(ax,MainStrokesResults.Sequence(endIndex-1:endIndex,1),MainStrokesResults.Sequence(endIndex-1:endIndex,2),'r.-','LineWidth',5);
            
        end
        sequence =MainStrokesResults.Sequence;
        maxX = max(sequence(:,1)); minX = min(sequence(:,1)); maxY = max(sequence(:,2)); minY = min(sequence(:,2));
        windowSize = max(maxX-minX,maxY-minY);
        ylim([minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
        xlim([minX-0.1*windowSize minX+windowSize+0.1*windowSize]);
        axis(ax,[minX-0.1*windowSize minX+windowSize+0.1*windowSize minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
        saveas(ax,[folderName,'\image'],'jpg');
    end
end

NumOfWordParts = length(FilteredSequenceArray);
RecognitionRate = NumOfCorrectRecognition/NumOfWordParts

end
function FilteredSequenceArray = FilterIllegalSequences (WPStructArray)
%The end of the previous letter has to be the same as the beggining of the cyrrent letter
%avoid Word Parts with penUp.
index = 1;
for j=1:length(WPStructArray)
    condition1 = any(ismember(WPStructArray(j).Sequence(:,1),Inf));
    condition2 = j>2 && any(WPStructArray(j).Sequence(1,:)~= WPStructArray(j-1).Sequence(end,:));
    if (~condition1)
        FilteredSequenceArray(index) = WPStructArray(j);
        index = index + 1;
    end
end
if (index ==1)
    FilteredSequenceArray = [];
end
end
function Res = AdaptString(str)
Res = strrep(str, '_', '');
Res = strrep(Res, 'Y', 'B');
Res = strrep(Res, 'N', 'B');
Res = strrep(Res, '6', '8');
end
