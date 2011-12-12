function LSHstruct = BuildLSHFromFolder( WaveletFolder , TargetLSHFolder, FeatureType, ResampleSize )
%CREATELSHFROMFOLDER Summary of this function goes here
%   Detailed explanation goes here
%   Feature types:
%   1 - Angular
%   2 - Shape COntext

if(~exist(TargetLSHFolder,'dir'))
    mkdir(TargetLSHFolder);
end

if (FeatureType==1)
    ActualWaveletFolder = [WaveletFolder,'\','Angular'];
    TargetLSHFilePath = [TargetLSHFolder,'\','Angular.mat'];
end
if (FeatureType==2)
    ActualWaveletFolder = [WaveletFolder,'\','ShapeContext'];
    TargetLSHFilePath = [TargetLSHFolder,'\','ShapeContext.mat'];
end
WaveletMatrix=[];
WPmap={};
sampledirlist = dir(ActualWaveletFolder);
for i = 3:length(sampledirlist)
    current_object = sampledirlist(i);
    FolderName = current_object.name;
    WaveletSampleFolder = [ActualWaveletFolder,'\',FolderName];
    %concatenate the matrices
    [tempWaveletMatrix,tempWPmap] = ReadWaveletsFromFolder(WaveletSampleFolder);
    WaveletMatrix = [WaveletMatrix;tempWaveletMatrix];
    WPmap = [WPmap;tempWPmap];
end

Labeling = CreateLabelingOfCellArray(WPmap);
[ProjectionWaveletMatrix, COEFF, NumOfPCs] = DimensionalityReduction(WaveletMatrix,Labeling);

ProjectionWaveletMatrix= ProjectionWaveletMatrix';

Size = size(ProjectionWaveletMatrix,2);
dim=size(ProjectionWaveletMatrix,1);
NumOfTables = 10;

%Determine LSH parameters (Key Length and tables number)
if (FeatureType==1)
    KeyLength = 20;
end
if (FeatureType==2)
    KeyLength = 15;
end

LSHstruct = lsh('lsh',NumOfTables,KeyLength,dim,ProjectionWaveletMatrix);
ProjectionWaveletMatrix = ProjectionWaveletMatrix';
save(TargetLSHFilePath, 'LSHstruct','Size','WPmap', 'ResampleSize', 'ProjectionWaveletMatrix', 'COEFF', 'NumOfPCs');

end
