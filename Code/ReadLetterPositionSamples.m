function  Samples = ReadLetterPositionSamples( LetterPositionFolder, ResampleSize)


if (~exist(LetterPositionFolder,'dir'))
    Samples = [];
    return;
end
LetterPositionFolderList = dir (fullfile(LetterPositionFolder,'*.m'));
numSamples = length(LetterPositionFolderList);
Samples = cell(1,numSamples);
for i = 1:numSamples
    current_object = LetterPositionFolderList(i);
    FileName = current_object.name;
    sequence = dlmread([LetterPositionFolder,'\',FileName]);
    
    %Sequence Pre-Processing = Normalization->Simplification->Resampling
    NormalizedSequence = NormalizeContLetter(sequence,LetterPositionFolder(end-4),LetterPositionFolder(end-2:end));
    SimplifiedSequence = SimplifyContour(NormalizedSequence);
    ResampledSequence = ResampleContour(SimplifiedSequence,ResampleSize);
    %%%
    
    Samples(i) = {ResampledSequence};
end
end
