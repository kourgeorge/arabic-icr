function  BuildLettersDictionary( LettersSamplesFolder , TargetFolder, FeatureType, ResampleSize)
%BuildLettersDictionary Takes as a parameter the Letter samples folder and
%creates a database struct which contains all the samples. It may also build an
%SVM Struct. The output database has 4 members (Ini, Mid, Fin, Iso). each
%member holds a table which contains all the samples in the sprcific
%position. Finally, the function saves the the structure to the
%TargetFolder.

%   Usage: BuildLettersDictionary( 'C:\OCRData\LettersSamples' , 'C:\OCRData\TargetFolder', 1, 20)

%   Feature types:
%   1 - Angular
%   2 - Shape COntext

% The folder of the samples is structured as below:
% LettersSamples
% --- Letter1
% --- --- Fin
% --- --- --- sample1
% The output data structure should be structured as below:
% Ini
% --- Letter1
% --- --- Sample1
% --- --- Sample2
% --- Letter2
% --- --- Sample1
% --- --- Sample2
% Mid
% --- Letter1
% --- --- Sample1
% --- --- Sample2
% --- Letter2
% --- --- Sample1
% --- --- Sample2


if(~exist(TargetFolder,'dir'))
    mkdir(TargetFolder);
end

IniStruct = []; MidStruct=[]; FinStruct = []; IsoStruct=[];
LettersSamplesFolderList = dir(LettersSamplesFolder);
for i = 3:length(LettersSamplesFolderList)
    current_object = LettersSamplesFolderList(i);
    FolderName = current_object.name;
    IsDir = current_object.isdir;
    if (IsDir==1 && FolderName~='_')
        LetterFolder = [LettersSamplesFolder,'\',FolderName];
        LetterInAllPositions= ReadLetterData(LetterFolder,ResampleSize);
        
        %Ini - Not all letters has Ini Form
        if (~isempty(LetterInAllPositions.Ini))
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Ini,2));
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Ini,Feature,'UniformOutput', false);
            LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
            IniStruct = [IniStruct;FolderName , {LetterFeatures}, {LetterWavelets}];
        end
        
        %Mid - Not all letters has Mid Form
        if (~isempty(LetterInAllPositions.Mid))
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Mid,2));
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Mid,Feature,'UniformOutput', false);
            LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
            MidStruct = [MidStruct;FolderName , {LetterFeatures}, {LetterWavelets}];
        end
        
        %Fin
        Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Fin,2));
        LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Fin,Feature,'UniformOutput', false);
        LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
        FinStruct = [FinStruct;FolderName , {LetterFeatures}, {LetterWavelets}];
        
        %Iso
        Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Iso,2));
        LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Iso,Feature,'UniformOutput', false);
        LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
        IsoStruct = [IsoStruct;FolderName , {LetterFeatures}, {LetterWavelets}];
    end
    
end
[LettersSamples,LettersGroups, NumericGroups] = ExpandLettersStructForSVM( IniStruct );
%IniSVMStruct = MultiSVMTrain(IniLettersSamples,IniLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( LettersSamples, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix);
LettersDS.Ini.COEFF = COEFF;
LettersDS.Ini.SVMStruct = SVMStruct;
LettersDS.Ini.KdTree = kd_buildtree(ReducedFeaturesMatrix,0);
LettersDS.Ini.LettersMap = LettersGroups;
LettersDS.Ini.Struct = IniStruct;

[LettersSamples,LettersGroups, NumericGroups] = ExpandLettersStructForSVM( MidStruct );
%MidSVMStruct = MultiSVMTrain(MidLettersSamples,MidLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( LettersSamples, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix);
LettersDS.Mid.COEFF = COEFF;
LettersDS.Mid.SVMStruct = SVMStruct;
LettersDS.Mid.KdTree = kd_buildtree(ReducedFeaturesMatrix,0);
LettersDS.Mid.LettersMap = LettersGroups;
LettersDS.Mid.Struct = MidStruct;

[LettersSamples,LettersGroups, NumericGroups]  = ExpandLettersStructForSVM( FinStruct );
%FinSVMStruct = MultiSVMTrain(FinLettersSamples,FinLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( LettersSamples, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix);
LettersDS.Fin.COEFF = COEFF;
LettersDS.Fin.SVMStruct = SVMStruct;
LettersDS.Fin.KdTree = kd_buildtree(ReducedFeaturesMatrix,0);
LettersDS.Fin.LettersMap = LettersGroups;
LettersDS.Fin.Struct = FinStruct;


[LettersSamples,LettersGroups, NumericGroups] = ExpandLettersStructForSVM( IsoStruct );
%IsoSVMStruct = MultiSVMTrain(IsoLettersSamples,IsoLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( LettersSamples, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix);
LettersDS.Iso.COEFF = COEFF;
LettersDS.Iso.SVMStruct = SVMStruct;
LettersDS.Iso.KdTree = kd_buildtree(ReducedFeaturesMatrix,0);
LettersDS.Iso.LettersMap = LettersGroups;
LettersDS.Iso.Struct = IsoStruct;

TargetFilePath = [TargetFolder,'\', 'LettersDS'];
save(TargetFilePath, 'LettersDS', 'FeatureType','ResampleSize');
end
