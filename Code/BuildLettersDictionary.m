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
    if (FolderName~='_')
        LetterFolder = [LettersSamplesFolder,'\',FolderName];
        LetterInAllPositions= ReadLetterData(LetterFolder,ResampleSize);
        %Not all letters has Ini and Mid Forms
        
        %Ini
        if (~isempty(LetterInAllPositions.Ini))
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Ini,2));
            NormalizedLetters = cellfun(@NormalizeCont,LetterInAllPositions.Ini,'UniformOutput', false);
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,NormalizedLetters,Feature,'UniformOutput', false);
            IniStruct = [IniStruct;FolderName , {LetterFeatures}];
        end
        
        %Mid
        if (~isempty(LetterInAllPositions.Mid))
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Mid,2));
            NormalizedLetters = cellfun(@NormalizeCont,LetterInAllPositions.Mid,'UniformOutput', false);
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,NormalizedLetters,Feature,'UniformOutput', false);
            MidStruct = [MidStruct;FolderName , {LetterFeatures}];
        end
        
        %Fin
        Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Fin,2));
        NormalizedLetters = cellfun(@NormalizeCont,LetterInAllPositions.Fin,'UniformOutput', false);
        LetterFeatures = cellfun(@CreateFeatureVectorFromContour,NormalizedLetters,Feature,'UniformOutput', false);
        FinStruct = [FinStruct;FolderName , {LetterFeatures}];
        
        %Iso
        Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Iso,2));
        NormalizedLetters = cellfun(@NormalizeCont,LetterInAllPositions.Iso,'UniformOutput', false);
        LetterFeatures = cellfun(@CreateFeatureVectorFromContour,NormalizedLetters,Feature,'UniformOutput', false);
        IsoStruct = [IsoStruct;FolderName , {LetterFeatures}];
    end
    
end
[IniLettersSamples,IniLettersGroups] = ExpandLettersStructForSVM( IniStruct );
IniSVMStruct = MultiSVMTrain(IniLettersSamples,IniLettersGroups);
LettersDS.Ini = IniSVMStruct;

[MidLettersSamples,MidLettersGroups] = ExpandLettersStructForSVM( MidStruct );
MidSVMStruct = MultiSVMTrain(MidLettersSamples,MidLettersGroups);
LettersDS.Mid = MidSVMStruct;

[FinLettersSamples,FinLettersGroups] = ExpandLettersStructForSVM( FinStruct );
FinSVMStruct = MultiSVMTrain(FinLettersSamples,FinLettersGroups);
LettersDS.Fin = FinSVMStruct;


[IsoLettersSamples,IsoLettersGroups, IsoNumericGroups] = ExpandLettersStructForSVM( IsoStruct );
IsoSVMStruct = MultiSVMTrain(IsoLettersSamples,IsoLettersGroups);
%model = svmtrain1 ([], IsoNumericGroups, IsoLettersSamples)
%[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( IsoLettersSamples, IsoLettersGroups, 0.98);
%%model2 =  svmtrain(ReducedFeaturesMatrix(1:10,:),IsoLettersGroups(1:10,:),'Kernel_Function','rbf', 'boxconstraint',Inf,'showplot',true);
%model2 = svmtrain1 ([], IsoNumericGroups, ReducedFeaturesMatrix,'-t 2 -v 5')

LettersDS.Iso = IsoSVMStruct;

TargetFilePath = [TargetFolder,'\', 'LettersDS'];
save(TargetFilePath, 'LettersDS', 'FeatureType','ResampleSize');
end
