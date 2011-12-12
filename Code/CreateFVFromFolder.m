function [ Num ] = CreateFVFromFolder(WPSeqFolder, OutputFVFolder,FeatureType )
%CREATEFVFROMFOLDER Summary of this function goes here
%   Feature types:
%   1 - Angular
%   2 - Shape COntext


%Make sure the target folders exist or create them
res = exist(OutputFVFolder,'dir');
if (res==0)
    mkdir(OutputFVFolder)
end
if (FeatureType==1)
    TargetFolder = [OutputFVFolder,'\','Angular'];
    h = waitbar(0,('Generating Angular Feature Vector. Please Wait...'));
else
    TargetFolder = [OutputFVFolder,'\','ShapeContext'];
    h = waitbar(0,('Generating Angular Feature Vector. Please Wait...'));
end
res = exist(TargetFolder,'dir');
if (res==0)
    mkdir(TargetFolder)
end

dirlist = dir(WPSeqFolder);
Num=0;
DirListLength = length(dirlist);
for i = 1:DirListLength
    current_object = dirlist(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 & FileName(LastCharacter)=='m')
        WPSequence = dlmread([WPSeqFolder,'\',FileName]);
        WPTFeaureVector = CreateFeatureVectorFromContour(WPSequence,FeatureType);
        dlmwrite([TargetFolder,'\',FileName], WPTFeaureVector);
        Num=Num+1;
    end    
    prog = i/DirListLength;
    waitbar(prog,h);
end

close (h);

