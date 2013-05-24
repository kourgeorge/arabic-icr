function [ FeaturesArray, WaveletsArray , LettersArray , NumericLabeling] = ExpandLettersStructForSVM( PositionLettersDS )
%TESTSVM Summary of this function goes here
%   Detailed explanation goes here

FeaturesArray = [];
WaveletsArray = [];
LettersArray = [];
NumericLabeling = [];

for i = 1:size(PositionLettersDS,1)
    Letter = PositionLettersDS{i,1};
    letterSamplesWavelets = cell2mat(PositionLettersDS{i,3})';
    WaveletsArray = [WaveletsArray; letterSamplesWavelets];
    FeaturesArray = [FeaturesArray; PositionLettersDS{i,2}'];
    LettersArray = [LettersArray; repmat(Letter,size(letterSamplesWavelets,1),1)];  
    NumericLabeling = [NumericLabeling; repmat(double(Letter),size(letterSamplesWavelets,1),1)];

end





