function [ flattenedArray ] = FlattenFeatureVectors( FeatureVectors )
%FLATTENFEATUREVECTORS Summary of this function goes here
%   flattened = FlattenFeatureVectors( FeaturesSpaceVectors );


flattenVectorLength = size(FeatureVectors{1},1)*size(FeatureVectors{1},2);
flattenedArray = zeros(size(FeatureVectors,1),flattenVectorLength);
for i=1:size(FeatureVectors,1)
    sample = FeatureVectors{i};
    flattenedArray(i,:) = reshape(sample,1,[]);
    
end

