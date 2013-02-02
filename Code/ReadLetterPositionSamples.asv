function  Samples = ReadLetterPositionSamples( LetterPositionFolder, ResampleSize)


if (~exist(LetterPositionFolder,'dir'))
    Samples = [];
    return;
end
LetterPositionFolderList = dir(LetterPositionFolder);
j=0;
for i = 3:length(LetterPositionFolderList)
    current_object = LetterPositionFolderList(i);
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (current_object.isdir ==0 &&  FileName(LastCharacter)=='m')
        j=j+1;
        FileName = current_object.name;
        sequence = dlmread([LetterPositionFolder,'\',FileName]);
        
        %Sequence Pre-Processing = Normalization->Simplification->Resampling
        NormalizedSequence = NormalizeCont(sequence);
        SimplifiedSequence = SimplifyContour(NormalizedSequence);
        ResampledSequence = ResampleContour(SimplifiedSequence,ResampleSize);
        %%%
        
        Samples(j) = {ResampledSequence};
    end
end
end
