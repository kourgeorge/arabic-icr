function Dist = CalculateSumDistanceFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType )
%CALCULATEDISTANCE Summary of this function goes here
%   Detailed explanation goes here

S = load(kdTreeFilePath);
kdTree = S.KdTree;
WPmap = S.WPmap;
Size= S.Size;
ResampleSize = S.ResampleSize;
WaveletMatrix = S.ProjectionWaveletMatrix;
COEFF=S.COEFF;
CentersMatrix= S.CentersMatrix;

WPWavelet = CreateWaveletFromContour( Sequence, ResampleSize , FeatureType);

WPWavelet_Projection = COEFF * WPWavelet;

[m,n]=size(CentersMatrix);
Dist=0;
for i=1:m
    Dist=Dist+ComputeDist(WPWavelet_Projection,CentersMatrix(i,:));
end

end

