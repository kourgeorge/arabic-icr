function [ WPTFeaureVector ] = CreateFeatureVectorFromContour(WPContour,FeatureType)
%CREATEFEATUREVECTORFROMSEQ Summary of this function goes here
%   Detailed explanation goes here


WPSequenceCell = {WPContour};

WPTFeaureVector = MakeFatureVectorsForTest(WPSequenceCell,FeatureType,inf);
WPTFeaureVector = WPTFeaureVector{1,1};
end

