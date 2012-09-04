function [ WPTFeaureVector ] = CreateFeatureVectorFromContour(WPContour,FeatureType)
%CREATEFEATUREVECTORFROMSEQ Summary of this function goes here
%   Detailed explanation goes here

if (isempty(WPContour))
    WPTFeaureVector=[];
    return;
end
WPSequenceCell = {WPContour};

WPTFeaureVector = MakeFatureVectorsForTest(WPSequenceCell,FeatureType,inf);
WPTFeaureVector = WPTFeaureVector{1,1};
end

