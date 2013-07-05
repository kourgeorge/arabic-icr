function [ WPsResults , Name] = RecognizeCityName(xmlFile, LoadDataStructure, OutputFolder )
%RecognizeCityName Summary of this function goes here
%   RecognizeWordStrokes( 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\ParsedADABWords\1231874635809.xml' , true, 'C:\OCRData\StrokeOutput\')

global LettersDataStructure;
if (LoadDataStructure ==true)
    LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
end


WPStructArray = XML2WPStructArray( xmlFile );

NormalizedWPStructArray = NormalizeWPStructArray(WPStructArray);

%FilteredSequenceArray = FilterIllegalSequences (NormalizedWPStructArray);

WPsResults = [];

if (isempty(NormalizedWPStructArray))
    return;
end

xmlToMatlabStruct = parseXML(xmlFile);
Name = xmlToMatlabStruct.Attributes(2).Value;

for i=1:length(NormalizedWPStructArray)
    
    WPSequence = NormalizedWPStructArray(i).Sequence;
    WPLabel = NormalizedWPStructArray(i).Label;
    tic
    [MainStrokesResults,~,ax] = OnlineRecognizer( WPSequence, false, true );
    time = toc;
    adaptedStr = AdaptString(WPLabel);
    
    [SegmentationDiff, correctRecognition] = IsWordRecognizedCorrectly(MainStrokesResults,adaptedStr);
    
    if (nargin>2)
        if (~strcmp(OutputFolder(end),'\'))
            OutputFolder = [OutputFolder,'\'];
        end
        if(~exist(OutputFolder,'dir'))
            mkdir(OutputFolder);
        end
        if (correctRecognition==true)
            ImagesFolder = [OutputFolder,'CorrectlyRecognizedWPsImages\'];
            detailsOutputFolder = [OutputFolder,'CorrectlyRecognizedWPs\',WPLabel,'_',num2str(i),'_',xmlFile(end-16:end-4)];
        elseif (SegmentationDiff ==0)
            ImagesFolder = [OutputFolder,'CorrectlySegmentedWPsImages\'];
            detailsOutputFolder = [OutputFolder,'CorrectlySegmentedWPs\',WPLabel,'_',num2str(i),'_',xmlFile(end-16:end-4)];
        else
            ImagesFolder = [OutputFolder,'BadlySegmentedWPsImages\'];
            detailsOutputFolder = [OutputFolder,'BadlySegmentedWPs\',WPLabel,'_',num2str(i),'_',xmlFile(end-16:end-4)];
        end
        
        mkdir(detailsOutputFolder);
        dlmwrite([detailsOutputFolder,'\sequence.m'], WPSequence);
        
        WPResultString = GetCandidatesFromRecState( MainStrokesResults );
        
        fid = fopen([detailsOutputFolder,'\result.txt'], 'wt');
        fprintf(fid, '%s', WPResultString);
        fclose(fid);
        
        saveas(ax,[detailsOutputFolder,'\image'],'jpg');
        
        if (~exist(ImagesFolder,'dir'))
            mkdir(ImagesFolder);
        end
        
        saveas(ax,[ImagesFolder,xmlFile(end-16:end-4),'_',WPLabel],'jpg');
    end
    WPsResults(i).Word = adaptedStr;
    WPsResults(i).Recognition = correctRecognition;
    WPsResults(i).SegmentationDiff = SegmentationDiff;
    WPsResults(i).NumStrokes = length(MainStrokesResults);
    WPsResults(i).time = time;
    
    close (ax);
end
end
% 
% function FilteredSequenceArray = FilterIllegalSequences (WPStructArray)
% %The end of the previous letter has to be the same as the beggining of the cyrrent letter
% %avoid Word Parts with penUp.
% index = 1;
% for j=1:length(WPStructArray)
%     condition1 = any(ismember(WPStructArray(j).Sequence(:,1),Inf));
%     condition2 = j>2 && any(WPStructArray(j).Sequence(1,:)~= WPStructArray(j-1).Sequence(end,:));
%     if (~condition1)
%         FilteredSequenceArray(index) = WPStructArray(j);
%         index = index + 1;
%     end
% end
% if (index ==1)
%     FilteredSequenceArray = [];
% end
% end

function Res = AdaptString(str)
Res = strrep(str, '_', '');
Res = strrep(Res, 'Y', 'B');
Res = strrep(Res, 'N', 'B');
Res = strrep(Res, '6', '8');
Res = strrep(Res, 'K', 'L');
end
