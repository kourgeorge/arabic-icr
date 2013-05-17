function [NumOfWdsGenerated ] = GenerateWordsFromFile(TargetFolderPath, WordsFile, LetterSamplesFolder, FontClass, IncludeImages)
%This function gets the file path that contains all the word parts
%and generate a directory that include the word parts contour.

TargetFolderPath = [TargetFolderPath,'\',FontClass]

if (exist(TargetFolderPath,'dir')==0)
    mkdir(TargetFolderPath);
end

%get the first word part
fid = fopen(WordsFile);
Wd= fgets(fid);

%Fix length size (the words that is retrieved with gets includes the
%"newline", thats why it need to be fixed
Dims = size(Wd);
Len = Dims(1,2);
Wd = Wd(:,1:Len-2);

NumOfWdsGenerated=0;

if (strcmp(IncludeImages,'Yes'))
    fig = figure();
    ax = axes();
end
while (Wd ~= -1)
    WPContour = GenerateWord( LetterSamplesFolder, Wd , FontClass);
    
    %get the minimum and maximum value to ajust the image
    MinX = min(WPContour(:,1));
    MaxX = max(WPContour(:,1));
    MinY = min(WPContour(:,2));
    MaxY = max(WPContour(:,2));
    
    xlim([MinX-0.1 MaxX+0.1]);
    ylim([MinY-0.1 MaxY+0.1]);
    
    % Need to do this because the saveas, always saves on the current
    % directory.
    if (strcmp(IncludeImages,'Yes'))
        plot (ax, WPContour(:,1),WPContour(:,2),'LineWidth',3);
        PrevDir = pwd;
        cd(TargetFolderPath);
        saveas(ax,Wd,'jpg');
        cd (PrevDir);
    end
    
    dlmwrite([TargetFolderPath,'\',Wd,'.m'], WPContour);
    Wd= fgets(fid);
    NumOfWdsGenerated=NumOfWdsGenerated+1;
    %Fix length size
    Dims = size(Wd);
    Len = Dims(1,2);
    Wd = Wd(:,1:Len-2);
end
end
