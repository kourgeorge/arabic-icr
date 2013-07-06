function [CorrectRecognition] = IsWPRecognizedCorrectly(RecState,WordPart)
%ISWPRECOGNIZEDCORRECTLY Summary of this function goes here
%   Detailed explanation goes here

CorrectRecognition=true;
SegmentationDiff=0;
SegmentationPoints = [RecState.SegmentationPoints];
numSegmentationPoints = length(SegmentationPoints);
if (numSegmentationPoints~=size(WordPart,2))
    SegmentationDiff =  numSegmentationPoints - size(WordPart,2);    
    CorrectRecognition = false;
    return;
end
for i=1:numSegmentationPoints
    SP =  SegmentationPoints{i};
    CurrCan = SP.Candidates(:,1);
    wasRecognized = false;
    for j=1:size(CurrCan,1)
        if (ValidateRecognizedLetter(CurrCan{j},WordPart,i))
            wasRecognized = true;
        end
    end
    if (wasRecognized==false)
        CorrectRecognition = false;
        return;
    end
end
end

function res = ValidateRecognizedLetter(candidate,WordPart,i)

if (strcmp(candidate, WordPart(i)))
    res = true;
    return;
end
if (strcmp (candidate, ['_',WordPart(i)]))
    res = true;
    return;
end
if (strcmp (candidate, ['_',WordPart(i),'_']))
    res = true;
    return;
end
if (strcmp (candidate, [WordPart(i),'_']))
    res = true;
    return;
end
res = false;
end
