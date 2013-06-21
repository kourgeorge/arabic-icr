function [LetterNumDiff, CorrectRecognition] = IsWordRecognizedCorrectly(RecState,Word)
%ISWORDRECOGNIZEDCORRECTLY Summary of this function goes here
%   Detailed explanation goes here

CorrectRecognition=true;
LetterNumDiff=0;
numSegmentationPoints = length(RecState.SegmentationPoints);
if (numSegmentationPoints~=size(Word,2))
    LetterNumDiff = numSegmentationPoints - size(Word,2);
    CorrectRecognition = false;
    return;
end
for i=1:numSegmentationPoints
    LCCP =  RecState.SegmentationPoints{i};
    CurrCan = LCCP.Candidates(:,1);
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
