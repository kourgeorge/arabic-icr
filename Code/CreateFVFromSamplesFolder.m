function [ Num ] = CreateFVFromSamplesFolder (SamplesFolder, FVTargetFolder, FeatureType)
%CREATEFVFROMSAMPLESFOLDER Summary of this function goes here
%   Detailed explanation goes here

%Make sure the target folders exist or create them
res = exist(FVTargetFolder,'dir');
if (res==0)
    mkdir(FVTargetFolder);
end

if (FeatureType==1)
    TargetFolder=[FVTargetFolder,'\','Angular'];
end

if (FeatureType==2)
    TargetFolder=[FVTargetFolder,'\','ShapeContext'];
end

res = exist(TargetFolder,'dir');
if (res==0)
    mkdir(TargetFolder);
end

Num=0;
dirlist = dir(SamplesFolder);
DirListLength = length(dirlist);
for i = 1:DirListLength
    current_object = dirlist(i);
    Name = current_object.name;
    if (current_object.isdir && ~strcmp(Name,'.')  &&  ~strcmp(Name,'..'))
        temp = CreateFVFromFolder([SamplesFolder,'\',Name], [TargetFolder,'\',Name], FeatureType);
        Num = Num + temp;
    end
end

end

