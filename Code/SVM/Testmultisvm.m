% Load Letters
% Load Classes
a = dlmread('C:\OCRData\GeneratedWordsIso\sample3\B.m');
ResCont = ResampleContour(a,15);
%model = svmtrain([], Letters, LettersCandidates, '-t 3 -v 5');
clc;
k11 = multisvm ( LettersCandidates, Letters', ResCont(:)')
% 
% [ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( LettersCandidates, Letters, 0.98,3)
% NumOfLetters = size (unique (Letters),1);
% NumOfSamplesPerLetter = (size (LettersCandidates,1))/NumOfLetters;
% 
% x = ReducedFeaturesMatrix(:,1);
% y = ReducedFeaturesMatrix(:,2);
% z = ReducedFeaturesMatrix(:,3);
% figure('Name','PCA + LDA - 3D');
% for i=1:NumOfLetters   
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     for k=1:NumOfSamplesPerLetter
%         j= (i-1)*NumOfSamplesPerLetter+k;
%         scatter3(x(j),y(j),z(j),25,[r g b],'filled'); hold on;
%     end    
% end
% 
% 
% [ReducedFeaturesMatrix, COEFF, NumOfPCs] = DimensionalityReduction( LettersCandidates, Letters, 0.98,2);
% NumOfLetters = size (unique (Letters),1);
% NumOfSamplesPerLetter = (size (LettersCandidates,1))/NumOfLetters;
% 
% x = ReducedFeaturesMatrix(:,1);
% y = ReducedFeaturesMatrix(:,2);
% figure('Name','PCA + LDA - 2D');
% for i=1:NumOfLetters   
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     for k=1:NumOfSamplesPerLetter
%         j= (i-1)*NumOfSamplesPerLetter+k;
%         scatter(x(j),y(j),25,[r g b],'filled'); hold on;
%     end    
% end