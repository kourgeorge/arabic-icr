function [ NumOfWordParts ,NumOfCorrectRecognition ,NumOfCorrectlySegmentedStrokes ] = RecognizeStrokeFromFile(xmlFile, LoadDataStructure, ax, OutputFolder )
%RECOGNIZESTROKEFROMFILE Summary of this function goes here
%   RecognizeStrokeFromFile( 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\ParsedADABWords\1232275347507.xml' , true)

global LettersDataStructure;
if (LoadDataStructure ==true)
    LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
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
    [LetterNumDiff, CorrectRecognition] = correctRecognition (MainStrokesResults,adaptedStr);
    
    
    if (CorrectRecognition == true || LetterNumDiff ==0 )
        NumOfCorrectlySegmentedStrokes = NumOfCorrectlySegmentedStrokes + 1;
    end
    
    if (CorrectRecognition==true)
        NumOfCorrectRecognition = NumOfCorrectRecognition + 1;
    else
        filename = [OutputFolder,FilteredSequenceArray(i).Label,'_',xmlFile(end-16:end-4)];
        dlmwrite([filename,'.m'], FilteredSequenceArray(i).Sequence);
        error_str = GetCandidatesFromRecState( MainStrokesResults );
        disp (error_str)
        fid = fopen([filename,'_result.txt'], 'wt');
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
        saveas(ax,[filename,'_image'],'jpg');
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
    if (~(j>2 && any(WPStructArray(j).Sequence(1,:)~= WPStructArray(j-1).Sequence(end,:)) || any(ismember(WPStructArray(j).Sequence(:,1),Inf))))
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
end


function [LetterNumDiff, CorrectRecognition] = correctRecognition(RecState,Word)
CorrectRecognition=true;
LetterNumDiff=0;
numSegmentationPoints = length(RecState.SegmentationPoints);
if (numSegmentationPoints~=size(Word,2))
    LetterNumDiff = numSegmentationPoints - size(Word,2);
    CorrectRecognition = false;
    return;
end
end