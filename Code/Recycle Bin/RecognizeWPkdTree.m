function ClosestWPs = RecognizeWPkdTree( WPTContour, kdTreeFilePath, FeatureType, closest )
%RECOGNIZEWPKDTREE Return the k-NN of the given contour (WPTContour) in the
%given kdTree structure (kdTreeFilePath). 
%The kdTree file contains the kdTree structure of the embedded vectors of the
%Lexicon with FT FeatureType.
%   Detailed explanation goes here

S = load(kdTreeFilePath);
kdTree = S.KdTree;
WPmap = S.WPmap;
Size= S.Size;
ResampleSize = S.ResampleSize;
WaveletMatrix = S.ProjectionWaveletMatrix;
COEFF=S.COEFF;
NumOfPCs = S.NumOfPCs;

WPWavelet = CreateWaveletFromContour( WPTContour, ResampleSize , FeatureType);

WPWavelet_Projection = COEFF * WPWavelet;

[index_vals,vector_vals,final_nodes] = kd_knn(kdTree,WPWavelet_Projection',closest,0);

ClosestWPs= [];
for i=1:length(index_vals)
    ClosestWPs = [ClosestWPs ; WPmap(index_vals(i))];
end


