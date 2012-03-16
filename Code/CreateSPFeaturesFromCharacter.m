function [ Features , Grouping ] = CreateSPFeaturesFromCharacter( CharacterSequence, PointEnvLength ,K)
%CREATESPFROMLETTER Summary of this function goes here
%   LetterSequence = dlmread(['C:\OCRData\GeneratedWordsMed\sample2\_3_.m']);

len = length(CharacterSequence);
Features = [];
Grouping = [];
for i=1:len-K
    if (rem(i,K)==0)
        Slope = CalculateSlope(CharacterSequence,i,PointEnvLength);
        Features = [Features ; Slope];
        Grouping = [Grouping ; 0];
    end
end

Slope = CalculateSlope(CharacterSequence,len,PointEnvLength);
Features = [Features ; Slope];
Grouping = [Grouping ; 1];
