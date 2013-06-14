function [ MainStrokes, AdditionalStrokes ] = ExtractAdditionalStroke( StrokesResults, WordSqeuence )
%EXTRACTADDITIONALSTROKE Summary of this function goes here
%   Detailed explanation goes here

ai = 1;
mi = 1;
S = finddistLneg(WordSqeuence);
for i=1:size(StrokesResults,2)
    if (finddistLneg(StrokesResults(i).Sequence)<0.005*S)
        AdditionalStrokes(ai) = StrokesResults(i);
        ai=ai+1;
    else
        MainStrokes(mi) =  StrokesResults(i);
        mi=mi+1;
    end
end

function [len] =  finddistLneg(Word)
temp = Word(:,1);
x = temp(temp~=Inf('single'));
temp=  Word(:,2);
y = temp(temp~=Inf('single'));
diffx = max(x)-min(x);
diffy = max(y)-min(y);
len = diffx * diffy^4;
