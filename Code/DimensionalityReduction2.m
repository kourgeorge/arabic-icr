function [ReducedFeaturesMatrix, mapping, NumOfPCs] = DimensionalityReduction2( FeaturesMatrix, Labeling, varargin)
%DIMENSIONALITYREDUCTION Reduces the dimensionality of N-by-P FeaturesMatrix matrix dimensionality.
%   Rows of FeaturesMatrix correspond to observations, columns to variables.
%   varargin{1} is the PCADataPreservingRate, the default is 0.98.
%   varargin{2} is the target number of dimentions, the default is the
%   output dimentsions of the oca given the PCADataPreservingRate minus 1.

% DimensionalityReduction Using PCA
[PCACOEFF,SCORE,LATENT] = princomp(FeaturesMatrix);

% build a vector with the data preservation rate.
data_preserving_vector = cumsum(LATENT)./sum(LATENT);

%find the first element that it's value > DataPreservingRate
PCA_NumOfPCs = find(data_preserving_vector>0.99,1);

PCACOEFF = PCACOEFF(:,1:PCA_NumOfPCs);
tempReducedFeaturesMatrix = FeaturesMatrix * PCACOEFF;

A.data = tempReducedFeaturesMatrix;

Labeling = double(Labeling);
%%%%%%%%%%%%%%Fix LDA labeling%%%%%%%%%%%%%%%%%%%
[UniqueLabels,IA,IC] = unique (Labeling);
for i=1:size(IA,1)
    ClassNumber = IA(i);
    indexes_of_class = find(IC==ClassNumber);
    if (size(indexes_of_class,1)<20)
        continue;
    end
    vectors = tempReducedFeaturesMatrix(indexes_of_class,:);
    NumOfInnerClusters = 4; %clusters estimations alg.
    [label, energy, index] = kmedoidsL1(vectors',NumOfInnerClusters,5);

    Labeling(indexes_of_class) = Labeling(indexes_of_class)+1000+label'; 

end
A.labels =  Labeling;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dims = intrinsic_dim(tempReducedFeaturesMatrix, 'MLE');
NumOfPCs = ceil(dims);

[AA,mapping] = compute_mapping(A, 'LDA',NumOfPCs);
ReducedFeaturesMatrix = AA.data;
mapping.PCACOEFF = PCACOEFF;

end

