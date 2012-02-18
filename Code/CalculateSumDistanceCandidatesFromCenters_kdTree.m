function [ Dist ] = CalculateSumDistanceCandidatesFromCenters_kdTree( Sequence, kdTreeFilePath, FeatureType ,Candidates )
%CALCULATESUMDISTANCECANDIDATESFROMCENTERS_KDTREE Summary of this function goes here
%   Detailed explanation goes here

S = load(kdTreeFilePath);
kdTree = S.KdTree;
WPmap = S.WPmap;
Size= S.Size;
ResampleSize = S.ResampleSize;
WaveletMatrix = S.ProjectionWaveletMatrix;
COEFF=S.COEFF;
CentersMatrix= S.CentersMatrix;
CentroidLabels=S.CentroidLabels;

WPWavelet = CreateWaveletFromContour( Sequence, ResampleSize , FeatureType);

WPWavelet_Projection = COEFF * WPWavelet;

[m,n]=size(Candidates);

Dist=0;
for i=1:m
    ind = find(ismember(CentroidLabels, Candidates(i))==1);
    Dist=Dist+ComputeDist(WPWavelet_Projection,CentersMatrix(ind,:));
end
end

