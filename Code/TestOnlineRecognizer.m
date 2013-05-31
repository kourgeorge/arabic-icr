function TestOnlineRecognizer()
%TESTONLINERECOGNIZER Summary of this function goes here
%   Detailed explanation goes here


global LettersDataStructure;
TestSetFolder = 'C:\OCRData\WPsLabeled';
%TestSetFolder = 'C:\OCRData\GeneratedWords';

LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');

OutputImages = true;
if (OutputImages==true)
    Comments = input('Enter Experiment comments\n','s');
    fig = figure();
    cl = clock;
    ax = axes();
    OutputFolder = ['C:\OCRData\TestOutput (',Comments,')'];
    if(~exist(OutputFolder,'dir'))
        mkdir(OutputFolder);
    end
end
clc;
diary([OutputFolder,'\Results.txt']);
diary on;
correctRec = 0;
correctSeg = 0;
count = 0;
overSeg = 0;
underSeg = 0;
Comments
TestSetFolder
start_total = cputime;
TestSetWordsFolderList = dir(TestSetFolder);
for i = 3:length(TestSetWordsFolderList)
    current_object = TestSetWordsFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 && FileName(LastCharacter)=='m')
        sequence = dlmread([TestSetFolder,'\',FileName]);
        disp(' ')
        disp(['Word  ',num2str(count),': ',FileName,])
        t = cputime;
        RecState = SimulateOnlineRecognizer( sequence ,false);
        e = cputime-t;
        disp(['Time Elapsed: ',num2str(e)])
        [LetterNumDiff, CorrectRecognition] = correctRecognition(RecState,strtok(FileName, ' .('));
        
        %Collect Statistics
        count=count+1;
        if (CorrectRecognition==true)
            correctRec = correctRec+1;
        else
            disp ('===>error Recognition')
            error_str = GetCandidatesFromRecState( RecState );
            disp (error_str)
        end
        if (LetterNumDiff==0)
            correctSeg = correctSeg+1;
        else
            disp ('===>error Segmentation')
            if (LetterNumDiff>0)
                overSeg = overSeg+1;
            else
                underSeg = underSeg+1;
            end
        end
        
        %Output letters images to folder
        if (CorrectRecognition == false && OutputImages==true)
            if (LetterNumDiff~=0)
                WordFolder =[OutputFolder,'\Segmentation\',FileName];
            else
                WordFolder =[OutputFolder,'\',FileName];
            end
            
            mkdir(WordFolder);
            for k=1:RecState.LCCPI
                if (k==1)
                    startIndex = 1;
                else
                    BLCCPP = RecState.CriticalCPs(k-1).Point;
                    startIndex = BLCCPP;
                end
                LCCP =  RecState.CriticalCPs(k);
                endIndex = LCCP.Point;
                dlmwrite([WordFolder,'\',num2str(k),'.m'], RecState.Sequence(startIndex:endIndex,:));
                plot (ax, RecState.Sequence(startIndex:endIndex,1),RecState.Sequence(startIndex:endIndex,2),'LineWidth',3);
                hold on;
                scatter (ax, RecState.Sequence(startIndex:endIndex,1),RecState.Sequence(startIndex:endIndex,2),'LineWidth',3);
                hold off;
                PrevDir = pwd;
                cd(WordFolder);
                saveas(ax,num2str(k),'jpg');
                cd (PrevDir);
            end
            fid = fopen([WordFolder,'\result.txt'], 'wt');
            fprintf(fid, '%s', error_str);
            fclose(fid);
        end
    end
end

RecognitionRate = (correctRec/count)*100
SegmentationRate = (correctSeg/count)*100
OverSegmentationRate = (overSeg/(count-correctSeg))*100
UnderSegmentationRate = (underSeg/(count-correctSeg))*100
AvgTime=(cputime-start_total)/count
count

diary off;
movefile (OutputFolder,[OutputFolder,' [R=',int2str(round(RecognitionRate)), ' S=', int2str(round(SegmentationRate)),']'], 'f');

end


function [LetterNumDiff, CorrectRecognition] = correctRecognition(RecState,Word)
CorrectRecognition=true;
LetterNumDiff=0;

if (RecState.LCCPI~=size(Word,2))
    LetterNumDiff = RecState.LCCPI - size(Word,2);
    CorrectRecognition = false;
    return;
end
for i=1:RecState.LCCPI
    LCCP =  RecState.CriticalCPs(i);
    CurrCan = LCCP.Candidates(:,1);
    wasRecognized = false;
    for j=1:size(CurrCan,1)
        if (ValidateRecognizedLetter(CurrCan{j},Word,i))
            wasRecognized = true;
        end
    end
    if (wasRecognized==false)
        CorrectRecognition = false;
        return;
    end
end
end

function res = ValidateRecognizedLetter(candidate,Word,i)

if (strcmp(candidate, Word(i)))
    res = true;
    return;
end
if (strcmp (candidate, ['_',Word(i)]))
    res = true;
    return;
end
if (strcmp (candidate, ['_',Word(i),'_']))
    res = true;
    return;
end
if (strcmp (candidate, [Word(i),'_']))
    res = true;
    return;
end
res = false;
end

