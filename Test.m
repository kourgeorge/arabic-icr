function [ output_args ] = Test( input_args )
%TEST Show the PCA and The LDA in 2D and 3D of the Wavelets found in the
%wavelet directory using angular feature.



clc;
close all;

FeatureName = 'Angular';
FeatureName = 'ShapeContext';

ActualWaveletFolder = ['C:\OCRData\Wavelet\',FeatureName];
WaveletMatrix=[];
WPmap={};
sampledirlist = dir(ActualWaveletFolder);
for i = 3:length(sampledirlist)
    current_object = sampledirlist(i);
    FolderName = current_object.name;
    WaveletSampleFolder = [ActualWaveletFolder,'\',FolderName];
    %concatenate the matrices
    [tempWaveletMatrix,tempWPmap] = ReadWaveletsFromFolder(WaveletSampleFolder);
    WaveletMatrix = [WaveletMatrix;tempWaveletMatrix];
    WPmap = [WPmap;tempWPmap];
end

%PCA+LDA
Labeling = CreateLabelingOfCellArray(WPmap);
[ProjectionWaveletMatrix, COEFF, NumOfPCs] = DimensionalityReduction(WaveletMatrix,Labeling,0.999,3);

% W = ProjectionWaveletMatrix(:,1:3);
W = ProjectionWaveletMatrix;

x = W(:,1);
y = W(:,2);
z = W(:,3);

% The number of font classes is the number of folders, sample1, sample2,
% etc...
NumOfFontClasses = length(sampledirlist)-2;
%The number of words, is the number of WPmap which contains all the words
%divided by the number of classes
NumOfWords = length(WPmap)/NumOfFontClasses;
figure('Name','PCA + LDA - 3D');
for i=1:NumOfWords    
    r=rand(1);
    g=rand(1);
    b=rand(1);
    for k=0:NumOfFontClasses-1
        j=i+k*NumOfWords;
        scatter3(x(j),y(j),z(j),25,[r g b],'filled'); hold on;
    end    
end
%legend(WPmap(1:20,:));





