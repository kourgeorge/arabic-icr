function [CorrectWPRecognition] = IsWPRecognizedCorrectly(WPResults,WordPart)
%ISWPRECOGNIZEDCORRECTLY Summary of this function goes here
%   Detailed explanation goes here

CorrectWPRecognition=true;

numSegmentationPoints = length(WPResults);
if (numSegmentationPoints~=size(WordPart,2))
    CorrectWPRecognition = false;
    return;
end
for i=1:numSegmentationPoints
    SP =  WPResults(i);
    CurrCan = SP.Candidates(:,1);
    letterRecognized = false;
    for j=1:size(CurrCan,1)
        if (ValidateRecognizedLetter(CurrCan{j},WordPart,i))
            letterRecognized = true;
        end
    end
    if (letterRecognized==false)
        CorrectWPRecognition = false;
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
