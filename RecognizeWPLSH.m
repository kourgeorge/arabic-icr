function ClosestWPs = RecognizeWPLSH( WPTContour, LSHFilePath, FeatureType, closest )
%RECOGNIZEWPLSH Return the k-NN of the given contour (WPTContour) in the
%given LSH structure (LSHFilePath). 
%The LSH file contains the LSH hashing of the embedded vectors of the
%Lexicon with FT FeatureType.
%   Detailed explanation goes here

S = load(LSHFilePath);
LSHstruct = S.LSHstruct;
WPmap = S.WPmap;
Size= S.Size;
ResampleSize = S.ResampleSize;
WaveletMatrix = S.ProjectionWaveletMatrix;
COEFF=S.COEFF;
NumOfPCs = S.NumOfPCs;

WaveletMatrix = WaveletMatrix';

WPWavelet = CreateWaveletFromContour( WPTContour, ResampleSize , FeatureType);

% WP Projection
%Principal_COEFF = COEFF(:,1:NumOfPCs);
%WPWavelet_Projection = WPWavelet' * Principal_COEFF;

% new WP Projection
WPWavelet_Projection = COEFF * WPWavelet;

%reduce the mean
%WPWavelet_Projection = WPWavelet_Projection - mean(WPWavelet_Projection);

[iNN,cand] = lshlookup(WPWavelet_Projection,WaveletMatrix,LSHstruct,'k',closest);

ClosestWPs= [];
for i=1:size(iNN,2)
    ClosestWPs = [ClosestWPs ; WPmap(iNN(i))];
end

end

