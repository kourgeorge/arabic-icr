function [ WPTFeaureVector ] = CreateFeatureVectorFromContour(WPContour,FeatureType)
%CREATEFEATUREVECTORFROMSEQ Summary of this function goes here
%   Detailed explanation goes here

if (isempty(WPContour))
    WPTFeaureVector=[];
    return;
end
WPTFeaureVector = MakeFatureVector(WPContour,FeatureType);
end

