function [ Diff ] = ShapeContextEMDCalcDist( WP1Contour, WP2Contour )
%ShapeContextEMDCalcDist: Takes 2 WordParts Contours and return the
%distance between them using ShapeContext Feature and And Approx EMD as the
%metric.
%   Detailed explanation goes here
WPT1FeaureVector= CreateFeatureVectorFromContour(WP1Contour,2);
WPT2FeaureVector= CreateFeatureVectorFromContour(WP2Contour,2);
[f,Diff] = EmdContXY(WPT1FeaureVector,WPT2FeaureVector);

end