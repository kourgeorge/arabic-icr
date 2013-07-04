function [SegmentationDirection, CorrectRecognition] = IsWordRecognizedCorrectly(RecState,Word)
%ISWORDRECOGNIZEDCORRECTLY Summary of this function goes here
%   Detailed explanation goes here

CorrectRecognition=true;
SegmentationDirection=0;
SegmentationPoints = [RecState.SegmentationPoints];
numSegmentationPoints = length(SegmentationPoints);
if (numSegmentationPoints~=size(Word,2))
     if (numSegmentationPoints - size(Word,2) > 0) SegmentationDirection = 1; end
     if (numSegmentationPoints - size(Word,2) < 0) SegmentationDirection = -1; end    
    CorrectRecognition = false;
    return;
end
for i=1:numSegmentationPoints
    SP =  SegmentationPoints{i};
    CurrCan = SP.Candidates(:,1);
    wasRecognized = false;
    for j=1:size(CurrCan,1)
        if (ValidateRecognizedLetter(CurrCan{j},Word,i))
            wasRecognized = true;
        end
    end
    if (wasRecognized==false)
        CorrectRecognition = false;
        return;
    end
end
end

function res = ValidateRecognizedLetter(candidate,Word,i)

if (strcmp(candidate, Word(i)))
    res = true;
    return;
end
if (strcmp (candidate, ['_',Word(i)]))
    res = true;
    return;
end
if (strcmp (candidate, ['_',Word(i),'_']))
    res = true;
    return;
end
if (strcmp (candidate, [Word(i),'_']))
    res = true;
    return;
end
res = false;
end
