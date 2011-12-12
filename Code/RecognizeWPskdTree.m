function ClosestWPsCellArray = RecognizeWPskdTree(  WPTContours, kdTreeFilePath, FeatureType, closest )
%RECOGNIZEWPSKDTREE Summary of this function goes here
%   Detailed explanation goes here


S = load(kdTreeFilePath);
kdTree = S.KdTree;
WPmap = S.WPmap;
Size= S.Size;
ResampleSize = S.ResampleSize;
WaveletMatrix = S.ProjectionWaveletMatrix;
COEFF=S.COEFF;
NumOfPCs = S.NumOfPCs;
CentroidLabels = S.CentroidLabels;

WaveletMatrix = WaveletMatrix';

for j=1:length(WPTContours)
    WPTContour =  WPTContours{j};
    
    WPWavelet = CreateWaveletFromContour( WPTContour, ResampleSize , FeatureType);

    WPWavelet_Projection = COEFF * WPWavelet;
    
    [index_vals,vector_vals,final_nodes] = kd_knn(kdTree,WPWavelet_Projection',closest,0);
    
%     ClosestWPs= [];
%     for i=1:closest
%         ClosestWPs = [ClosestWPs ; WPmap(index_vals(i))];
%     end

    ClosestWPs= [];
    for i=1:closest
        ClosestWPs = [ClosestWPs ; CentroidLabels(index_vals(i))];
    end
    
    ClosestWPsCellArray(j) = {ClosestWPs};
    
end
end

