function [ WPsResults , Name] = RecognizeCityName(xmlFile, LoadDataStructure, OutputFolder )
%RecognizeCityName Summary of this function goes here
%   RecognizeCityName( 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\ParsedADABWords\1232530266938.xml' , true, 'C:\OCRData\StrokeOutput\')

global LettersDataStructure;
if (LoadDataStructure ==true)
    LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
end


WPStructArray = XML2WPStructArray( xmlFile );

NormalizedWPStructArray = NormalizeWPStructArray(WPStructArray);

WPsResults = [];

if (isempty(NormalizedWPStructArray))
    return;
end

xmlToMatlabStruct = parseXML(xmlFile);
Name = xmlToMatlabStruct.Attributes(2).Value;

%Iterate Over all WordParts
for i=1:length(NormalizedWPStructArray)
    
    WPSequence = NormalizedWPStructArray(i).Sequence;
    WPLabel = NormalizedWPStructArray(i).Label;
    tic
    [MainStrokesResults,~,ax] = OnlineRecognizer( WPSequence, false, true );
    time = toc;
    adaptedStr = AdaptString(WPLabel);
    
    correctWPRecognition = IsWPRecognizedCorrectly(MainStrokesResults,adaptedStr);
    if (correctWPRecognition == true)
        correctSegmentation = true;
        TP_SP =  length(adaptedStr);
        FP_SP = 0 ;
        FN_SP = 0;
    else
    	[correctSegmentation, TP_SP, FP_SP, FN_SP] = IsWPSegmentedCorrectly(MainStrokesResults,NormalizedWPStructArray(i));
    end
    
    if (nargin>2)
        if (~strcmp(OutputFolder(end),'\'))
            OutputFolder = [OutputFolder,'\'];
        end
        if(~exist(OutputFolder,'dir'))
            mkdir(OutputFolder);
        end
        if (correctWPRecognition==true)
            ImagesFolder = [OutputFolder,'CorrectlyRecognizedWPsImages\'];
            detailsOutputFolder = [OutputFolder,'CorrectlyRecognizedWPs\',WPLabel,'_',num2str(i),'_',xmlFile(end-16:end-4)];
        elseif (correctSegmentation == true)
            ImagesFolder = [OutputFolder,'CorrectlySegmentedWPsImages\'];
            detailsOutputFolder = [OutputFolder,'CorrectlySegmentedWPs\',WPLabel,'_',num2str(i),'_',xmlFile(end-16:end-4)];
        else
            ImagesFolder = [OutputFolder,'BadlySegmentedWPsImages\'];
            detailsOutputFolder = [OutputFolder,'BadlySegmentedWPs\',WPLabel,'_',num2str(i),'_',xmlFile(end-16:end-4)];
        end
        
        mkdir(detailsOutputFolder);
        dlmwrite([detailsOutputFolder,'\sequence.m'], WPSequence);
        
%         WPResultString = GetCandidatesFromRecState( MainStrokesResults );
%         
%         fid = fopen([detailsOutputFolder,'\result.txt'], 'wt');
%         fprintf(fid, '%s', WPResultString);
%         fclose(fid);
        
        saveas(ax,[detailsOutputFolder,'\image'],'jpg');
        
        if (~exist(ImagesFolder,'dir'))
            mkdir(ImagesFolder);
        end
        
        saveas(ax,[ImagesFolder,xmlFile(end-16:end-4),'_',WPLabel],'jpg');
    end
    WPsResults(i).WPLabel = adaptedStr;
    WPsResults(i).CorrectRecognition = correctWPRecognition;
    WPsResults(i).CorrectSegmentation = correctSegmentation;
    WPsResults(i).TP_SP = TP_SP; 
    WPsResults(i).FP_SP = FP_SP;
    WPsResults(i).FN_SP = FN_SP;
    WPsResults(i).NumStrokes = length(MainStrokesResults);
    WPsResults(i).time = time;
    
    close (ax);
end
end


function Res = AdaptString(str)
Res = strrep(str, '_', '');
Res = strrep(Res, 'Y', 'B');
Res = strrep(Res, 'N', 'B');
Res = strrep(Res, '6', '8');
Res = strrep(Res, 'K', 'L');
end
