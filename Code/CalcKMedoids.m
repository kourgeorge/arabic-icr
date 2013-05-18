function  [LetterFeaturesMedoids, LetterWaveletsMedoids] = CalcKMedoids(LetterFeatures, LetterWavelets, k)

LetterWaveletsMatrix = cell2mat(LetterWavelets)';
if (size(LetterWaveletsMatrix,1)>2*k)
    [~, ~, index]= kmedoidsL1(LetterWaveletsMatrix',k);
    
    LetterWaveletsMedoids = cell(1,k);
    LetterFeaturesMedoids = cell(1,k);
    
    for i=1:k
        LetterWaveletsMedoids(i) = LetterWavelets(index(i));
        LetterFeaturesMedoids(i) = LetterFeatures(index(i));
    end
else
    LetterFeaturesMedoids = LetterFeatures;
    LetterWaveletsMedoids = LetterWavelets;
end
