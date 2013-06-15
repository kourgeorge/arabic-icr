function [ Diff ] = ShapeContextDTWCalcDist( WP1Contour, WP2Contour )
%ShapeContextDTWCalcDist: Takes 2 WordParts Contours and return the
%distance between them using ShapeContext Feature and And DTW as the
%metric.
%   Detailed explanation goes here
WPT1FeaureVector= CreateFeatureVectorFromContour(WP1Contour,2);
WPT2FeaureVector= CreateFeatureVectorFromContour(WP2Contour,2);
[p,q,D,Diff,WarpingPath] = DTWContXY(WPT1FeaureVector,WPT2FeaureVector);

end