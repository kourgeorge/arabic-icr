function [ output_args ] = BuildLSHFromFeatureMatrix( input_args )
%BuildLSHFromFeatureMatrix For research only, to save  the dimensionality
%reduction phase.
%   Detailed explanation goes here
% 
FeatureName='Angular';
FeatureType=1;
% FeatureName='ShapeContext';
% FeatureType=2;

LSHFilePath = 'C:\OCRData\LSH';
TargetLSHFilePath = [LSHFilePath,'\',FeatureName,'.mat'];
S = load(TargetLSHFilePath);
WPmap = S.WPmap;
Size= S.Size;
ResampleSize = S.ResampleSize;
ProjectionWaveletMatrix = S.ProjectionWaveletMatrix;
COEFF=S.COEFF;
NumOfPCs = S.NumOfPCs;

ProjectionWaveletMatrix= ProjectionWaveletMatrix';

Size = size(ProjectionWaveletMatrix,2);
dim=size(ProjectionWaveletMatrix,1);
NumOfTables = 10;

%Determine LSH parameters (Key Length and tables number)

%<1000 samples:
if (FeatureType==1)
    KeyLength = 20;
end
if (FeatureType==2)
    KeyLength = 15;
end
%>1000 samples:
if (Size>1000)
    if (FeatureType==1)
        KeyLength = 15;
        NumOfTables = 20;
    end
    
    if (FeatureType==2)
        KeyLength = 15;
        NumOfTables = 20;
    end
end

LSHstruct = lsh('lsh',NumOfTables,KeyLength,dim,ProjectionWaveletMatrix);
ProjectionWaveletMatrix= ProjectionWaveletMatrix';
save(TargetLSHFilePath, 'LSHstruct','Size','WPmap', 'ResampleSize', 'ProjectionWaveletMatrix', 'COEFF', 'NumOfPCs');

lshstats(LSHstruct)
end

