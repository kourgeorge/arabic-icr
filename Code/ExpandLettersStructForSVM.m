function [ FeaturesArray, LettersArray , NumericLabeling] = ExpandLettersStructForSVM( PositionLettersDS )
%TESTSVM Summary of this function goes here
%   Detailed explanation goes here

FeaturesArray = [];
LettersArray = [];
NumericLabeling = [];

for i = 1:size(PositionLettersDS,1)
    Letter = PositionLettersDS{i,1};
    %PositionLettersDS{i,2}; for feature vectores and
    %PositionLettersDS{i,3}; for wavelets
    LetterCandidates = PositionLettersDS{i,3};
    LetterSamples = [];
    for j=1: size(LetterCandidates,2)
        a = LetterCandidates(j);
        a = a{:};
        a = a(:);
        LetterSamples =[LetterSamples; a'];
    end
        
    FeaturesArray = [FeaturesArray; LetterSamples];
    
    LettersArray = [LettersArray; repmat(Letter,size(LetterSamples,1),1)];
    
    NumericLabeling = [NumericLabeling; repmat(double(Letter),size(LetterSamples,1),1)];

end





