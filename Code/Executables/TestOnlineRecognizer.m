function TestOnlineRecognizer()
%TESTONLINERECOGNIZER Summary of this function goes here
%   Detailed explanation goes here


global LettersDataStructure;
TestSetFolder = 'C:\OCRData\WPsLabeled';
%TestSetFolder = 'C:\OCRData\GeneratedWords';

LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
OutputImages = true;
if (OutputImages==true)
    fig = figure();
    cl = clock;
    ax = axes();
end
Comments = input('Enter Experiment comments\n','s');
OutputFolder = ['C:\OCRData\TestOutput (',Comments,')'];
if(~exist(OutputFolder,'dir'))
    mkdir(OutputFolder);
end
clc;
diary([OutputFolder,'\Results.txt']);
diary on;
correctRec = 0;
correctSeg = 0;
count = 0;
overSeg = 0;
underSeg = 0;

start_total = cputime;
TestSetWordsFolderList = dir(TestSetFolder);
for i = 3:length(TestSetWordsFolderList)
    current_object = TestSetWordsFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 && FileName(LastCharacter)=='m')
        disp(' ');
        sequence = dlmread([TestSetFolder,'\',FileName]);
        disp(['Word  ',num2str(count),': ',FileName,])
        t = cputime;
        RecState = OnlineRecognizer( sequence ,false, false);
        RecState = RecState(1);
        e = cputime-t;
        disp(['Time Elapsed: ',num2str(e)])
        [LetterNumDiff, CorrectRecognition] = IsWordRecognizedCorrectly(RecState,strtok(FileName, ' .('));
        numSegmentationPoints = length(RecState.SegmentationPoints);
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
            hold off;
            plot (ax, RecState.Sequence(:,1),RecState.Sequence(:,2),'LineWidth',3);
            hold on;
            
            for k=2:length(RecState.CandidatePointsArray)
                point = RecState.CandidatePointsArray(k);

                plot(ax,RecState.Sequence(point-1:point,1),RecState.Sequence(point-1:point,2),'c.-','LineWidth',5);
            end
            
            for k=1:numSegmentationPoints
                if (k==1)
                    startIndex = 1;
                else
                    BLCCPP = RecState.SegmentationPoints{k-1}.Point;
                    startIndex = BLCCPP;
                end
                LCCP =  RecState.SegmentationPoints{k};
                endIndex = LCCP.Point;
                dlmwrite([WordFolder,'\',num2str(k),'.m'], RecState.Sequence(startIndex:endIndex,:));
                plot(ax,RecState.Sequence(endIndex-1:endIndex,1),RecState.Sequence(endIndex-1:endIndex,2),'r.-','LineWidth',5);
                PrevDir = pwd;
                cd(WordFolder);
                cd (PrevDir);
            end
            PrevDir = pwd;
            cd(WordFolder);
            saveas(ax,'image','jpg');
            cd (PrevDir);
            fid = fopen([WordFolder,'\result.txt'], 'wt');
            fprintf(fid, '%s', error_str);
            fclose(fid);
            dlmwrite([WordFolder,'\CandidatesMinTable.txt'], RecState.MinScoreTable,'delimiter', '\t', 'precision', 4, 'newline','pc');
        end
    end
end
Comments
TestSetFolder
RecognitionRate = (correctRec/count)*100
SegmentationRate = (correctSeg/count)*100
OverSegmentationRate = (overSeg/(count-correctSeg))*100
UnderSegmentationRate = (underSeg/(count-correctSeg))*100
AvgTime=(cputime-start_total)/count
count

diary off;
movefile (OutputFolder,[OutputFolder,' [R=',int2str(round(RecognitionRate)), ' S=', int2str(round(SegmentationRate)),']'], 'f');

end
