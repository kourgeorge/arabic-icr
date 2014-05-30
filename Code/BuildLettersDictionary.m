function  BuildLettersDictionary( LettersSamplesFolder , TargetFolder, FeatureType, ResampleSize)
%BuildLettersDictionary Takes as a parameter the Letter samples folder and
%creates a database struct which contains all the samples. It may also build an
%SVM Struct. The output database has 4 members (Ini, Mid, Fin, Iso). each
%member holds a table which contains all the samples in the sprcific
%position. Finally, the function saves the the structure to the
%TargetFolder.

%   Usage: BuildLettersDictionary( 'C:\OCRData\LettersSamples' , 'C:\OCRData\TargetFolder', 1, 20)

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
            LetterPositionInfo = createLetterPositionInfo(FolderName, LetterInAllPositions.Ini, FeatureType);
            IniStruct = [IniStruct;LetterPositionInfo];
        end
        
        %Mid - Not all letters has Mid Form
        if (~isempty(LetterInAllPositions.Mid))
            LetterPositionInfo = createLetterPositionInfo(FolderName, LetterInAllPositions.Mid, FeatureType);
            MidStruct = [MidStruct;LetterPositionInfo];
        end
        
        %Fin
        if (~isempty(LetterInAllPositions.Fin))
            LetterPositionInfo = createLetterPositionInfo(FolderName, LetterInAllPositions.Fin, FeatureType);
            FinStruct = [FinStruct;LetterPositionInfo];
        end
        
        
        %Iso
        if (~isempty(LetterInAllPositions.Iso))
            LetterPositionInfo = createLetterPositionInfo(FolderName, LetterInAllPositions.Iso, FeatureType);
            IsoStruct = [IsoStruct;LetterPositionInfo];
        end
    end
    
end

LettersDS.Ini = createLetterPositionDB(IniStruct);
LettersDS.Mid = createLetterPositionDB(MidStruct);
LettersDS.Fin = createLetterPositionDB(FinStruct);
LettersDS.Iso = createLetterPositionDB(IsoStruct);


TargetFilePath = [TargetFolder,'\', 'LettersDS'];
save(TargetFilePath, 'LettersDS', 'FeatureType','ResampleSize');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InfoRow = createLetterPositionInfo(LetterName, LetterPositionData, FeatureType)
SequenceFeature = repmat({0}, 1, size(LetterPositionData,2));
LetterSequences = cellfun(@CreateFeatureVectorFromContour,LetterPositionData,SequenceFeature,'UniformOutput', false);
Feature = repmat({FeatureType}, 1, size(LetterPositionData,2));
LetterFeatures = cellfun(@CreateFeatureVectorFromContour,LetterPositionData,Feature,'UniformOutput', false);
LetterWavelets = cellfun(@CreateWaveletFromFV, LetterFeatures ,'UniformOutput', false);
InfoRow = [LetterName, {LetterFeatures}, {LetterWavelets}, {LetterSequences}];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LetterPositionDB = createLetterPositionDB(Struct)

DistanceType = 'cityblock';
DataPreservationRate = 0.98;

[FeaturesSpaceVectors,WaveletSpaceVectors,LettersGroups, ~ , SequencesArray] = ExpandLettersStructForSVM( Struct );
[ReducedFeaturesMatrix, COEFF, ~] = DimensionalityReduction2( WaveletSpaceVectors, LettersGroups, DataPreservationRate);
LetterPositionDB.COEFF = COEFF;
LetterPositionDB.KdTree = createns(ReducedFeaturesMatrix,'NSMethod','kdtree','Distance',DistanceType);
LetterPositionDB.LettersMap = LettersGroups;
LetterPositionDB.Struct = Struct;
LetterPositionDB.FeaturesSpaceVectors = FeaturesSpaceVectors;
LetterPositionDB.SequencesArray = SequencesArray;

end