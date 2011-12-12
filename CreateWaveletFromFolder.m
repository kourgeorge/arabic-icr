function [ Num ] = CreateWaveletFromFolder(ContoursFolder, TargetFolder, ContourResampleSize, FeatureType)
%CREATEFVFROMFOLDER Summary of this function goes here

%Make sure the target folders exist or create them
res = exist(TargetFolder,'dir');
if (res==0)
    mkdir(TargetFolder);
end

h = waitbar(0,('Generating Wavelet. Please Wait...'));

dirlist = dir(ContoursFolder);
Num=0;
DirListLength = length(dirlist);
for i = 1:DirListLength
    current_object = dirlist(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 & FileName(LastCharacter)=='m')
        WPTContour = dlmread([ContoursFolder,'\',FileName]);
        WPTWavelet= CreateWaveletFromContour( WPTContour, ContourResampleSize , FeatureType);
        dlmwrite([TargetFolder,'\',FileName], WPTWavelet);
        Num=Num+1;
    end
    prog = i/DirListLength;
    waitbar(prog,h);
end

close (h);

