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
        
        %Here the preprocessing is done
        LetterInAllPositions= ReadLetterData(LetterFolder,ResampleSize);
        
        %Ini - Not all letters has Ini Form
        if (~isempty(LetterInAllPositions.Ini))
            SequenceFeature = repmat({0}, 1, size(LetterInAllPositions.Ini,2));
            LetterSequences = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Ini,SequenceFeature,'UniformOutput', false);
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Ini,2));
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Ini,Feature,'UniformOutput', false);
            LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
            IniStruct = [IniStruct;FolderName , {LetterFeatures}, {LetterWavelets}, {LetterSequences}];
        end
        
        %Mid - Not all letters has Mid Form
        if (~isempty(LetterInAllPositions.Mid))
            SequenceFeature = repmat({0}, 1, size(LetterInAllPositions.Mid,2));
            LetterSequences = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Mid,SequenceFeature,'UniformOutput', false);
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Mid,2));
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Mid,Feature,'UniformOutput', false);
            LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
            MidStruct = [MidStruct;FolderName , {LetterFeatures}, {LetterWavelets}, {LetterSequences}];
        end
        
        %Fin
        if (~isempty(LetterInAllPositions.Fin))
            SequenceFeature = repmat({0}, 1, size(LetterInAllPositions.Fin,2));
            LetterSequences = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Fin,SequenceFeature,'UniformOutput', false);
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Fin,2));
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Fin,Feature,'UniformOutput', false);
            LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
            FinStruct = [FinStruct;FolderName , {LetterFeatures}, {LetterWavelets}, {LetterSequences}];
        end
        
        
        %Iso
        if (~isempty(LetterInAllPositions.Iso))
            SequenceFeature = repmat({0}, 1, size(LetterInAllPositions.Iso,2));
            LetterSequences = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Iso,SequenceFeature,'UniformOutput', false);
            Feature = repmat({FeatureType}, 1, size(LetterInAllPositions.Iso,2));            
            LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterInAllPositions.Iso,Feature,'UniformOutput', false);
            LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
            IsoStruct = [IsoStruct;FolderName , {LetterFeatures}, {LetterWavelets}, {LetterSequences}];
        end
    end
    
end
DistanceType = 'cityblock';
[FeaturesSpaceVectors,WaveletSpaceVectors,LettersGroups, NumericGroups, SequencesArray] = ExpandLettersStructForSVM( IniStruct );
%IniSVMStruct = MultiSVMTrain(IniLettersSamples,IniLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction2( WaveletSpaceVectors, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix,'-q');
LettersDS.Ini.COEFF = COEFF;
LettersDS.Ini.SVMStruct = SVMStruct;
LettersDS.Ini.KdTree = createns(ReducedFeaturesMatrix,'NSMethod','kdtree','Distance',DistanceType);
LettersDS.Ini.LettersMap = LettersGroups;
LettersDS.Ini.Struct = IniStruct;
LettersDS.Ini.FeaturesSpaceVectors = FeaturesSpaceVectors;
LettersDS.Ini.SequencesArray = SequencesArray;


csvwrite('C:\IniVectors.csv',[ReducedFeaturesMatrix';NumericGroups']');

[FeaturesSpaceVectors,WaveletSpaceVectors,LettersGroups, NumericGroups,SequencesArray] = ExpandLettersStructForSVM( MidStruct );
%MidSVMStruct = MultiSVMTrain(MidLettersSamples,MidLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction2( WaveletSpaceVectors, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix,'-q');
LettersDS.Mid.COEFF = COEFF;
LettersDS.Mid.SVMStruct = SVMStruct;
LettersDS.Mid.KdTree = createns(ReducedFeaturesMatrix,'NSMethod','kdtree','Distance',DistanceType);
LettersDS.Mid.LettersMap = LettersGroups;
LettersDS.Mid.Struct = MidStruct;
LettersDS.Mid.FeaturesSpaceVectors = FeaturesSpaceVectors;
LettersDS.Mid.SequencesArray = SequencesArray;

csvwrite('C:\MidVectors.csv',[ReducedFeaturesMatrix';NumericGroups']');


[FeaturesSpaceVectors,WaveletSpaceVectors,LettersGroups, NumericGroups,SequencesArray]  = ExpandLettersStructForSVM( FinStruct );
%FinSVMStruct = MultiSVMTrain(FinLettersSamples,FinLettersGroups);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction2( WaveletSpaceVectors, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix,'-q');
LettersDS.Fin.COEFF = COEFF;
LettersDS.Fin.SVMStruct = SVMStruct;
LettersDS.Fin.KdTree = createns(ReducedFeaturesMatrix,'NSMethod','kdtree','Distance',DistanceType);
LettersDS.Fin.LettersMap = LettersGroups;
LettersDS.Fin.Struct = FinStruct;
LettersDS.Fin.FeaturesSpaceVectors = FeaturesSpaceVectors;
LettersDS.Fin.SequencesArray = SequencesArray;

csvwrite('C:\FinVectors.csv',[ReducedFeaturesMatrix';NumericGroups']');

[FeaturesSpaceVectors,WaveletSpaceVectors,LettersGroups, NumericGroups,SequencesArray] = ExpandLettersStructForSVM( IsoStruct );
%IsoSVMStruct = MultiSVMTrain(Iso,IsoLettersSamples);
[ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction2( WaveletSpaceVectors, LettersGroups, 0.98);
SVMStruct = svmtrain1 ([], NumericGroups, ReducedFeaturesMatrix,'-q');
LettersDS.Iso.COEFF = COEFF;
LettersDS.Iso.SVMStruct = SVMStruct;
LettersDS.Iso.KdTree = createns(ReducedFeaturesMatrix,'NSMethod','kdtree','Distance',DistanceType);
LettersDS.Iso.LettersMap = LettersGroups;
LettersDS.Iso.Struct = IsoStruct;
LettersDS.Iso.FeaturesSpaceVectors = FeaturesSpaceVectors;
LettersDS.Iso.SequencesArray = SequencesArray;

csvwrite('C:\IsoVectors.csv',[ReducedFeaturesMatrix';NumericGroups']');

TargetFilePath = [TargetFolder,'\', 'LettersDS'];
save(TargetFilePath, 'LettersDS', 'FeatureType','ResampleSize');
end