function [ Diff ] = AngularEMDCalcDist( WP1Contour, WP2Contour )
%ANGULAR _DTW Summary of this function goes here
%   Detailed explanation goes here
WPT1FeaureVector= CreateFeatureVectorFromContour(WP1Contour,1);
WPT2FeaureVector= CreateFeatureVectorFromContour(WP2Contour,1);
[f,Diff] = EmdContXY(WPT1FeaureVector,WPT2FeaureVector);

end