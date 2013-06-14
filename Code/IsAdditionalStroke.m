function [ Result ] = IsAdditionalStroke( Stroke , RecState)
%ISADDIONALSTROKE Summary of this function goes here
%   Detailed explanation goes here

S = 3.e-05;
Result = false;
if (isempty(RecState.SegmentationPoints) || (length(RecState.SegmentationPoints)==1 && IsProbablyAddtionalStroke (RecState.SegmentationPoints{1}.Candidates)))
    Result = true;
end
end

function [len] =  finddistLneg(Word)
x = Word(:,1);
y = Word(:,2);
diffx = max(x)-min(x);
diffy = max(y)-min(y);
len = diffx * diffy^4;

end

function Res = IsProbablyAddtionalStroke(Candidates)
Res = false;
for i=1:length(Candidates)
    if (strcmp(Candidates {i,1}, '^'))
        Res = true;
        return;
    end
end
end