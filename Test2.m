
% PCA - 2D
%-----------

% [COEFF,SCORE] = princomp(WaveletMatrix);
% NumOfPCs = 2;
% Res = SCORE(:,1:NumOfPCs);
% x = Res(:,1);
% y = Res(:,2);
% C=zeros(60,3);
% for i=1:20    
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     C(i,:) = [r g b];
%     C(i+20,:) = [r g b];
%     C(i+40,:) = [r g b];  
% end
% 
% figure('Name','PCA - 2D');
% scatter(x,y,25,C,'filled');


% PCA - 3D
%----------
% 
% NumOfPCs = 3;
% Res = SCORE(:,1:NumOfPCs);
% x = Res(:,1);
% y = Res(:,2);
% z = Res(:,3);
% C=zeros(60,3);
% for i=1:20    
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     C(i,:) = [r g b];
%     C(i+20,:) = [r g b];
%     C(i+40,:) = [r g b];  
% end
% 
% figure('Name','PCA - 3D');
% scatter3(x,y,z,25,C,'filled');

% % LDA -3d
% LabeledArray = CreateLabelingOfCellArray(WPmap);
% %Res = LDA(WaveletMatrix,LabeledArray,3);
% Res = LDA2(WaveletMatrix,LabeledArray);
% x = Res(:,1);
% y = Res(:,2);
% z = Res(:,3);
% C=zeros(60,3);
% for i=1:20    
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     C(i,:) = [r g b];
%     C(i+20,:) = [r g b];
%     C(i+40,:) = [r g b];  
% end
% figure('Name','LDA - 3D');
% scatter3(x,y,z,25,C,'filled');

% LDA - 2d
% LabeledArray = CreateLabelingOfCellArray(WPmap);
% [COEFF, SCORE] = princomp(WaveletMatrix);
% NumOfPCs = 50;
% WaveletMatrix = SCORE(:,1:NumOfPCs);
% 
% [W,mapping] = LDA(WaveletMatrix,LabeledArray,2);
% 
% x = W(:,1);
% y = W(:,2);
% %C=zeros(60,3);
% C=zeros(40,3);
% for i=1:20    
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     C(i,:) = [r g b];
%     C(i+20,:) = [r g b];
%     %C(i+40,:) = [r g b];  
% end
% figure('Name','LDA - 2D');
% scatter(x,y,25,C,'filled');


%PCA+LDA
Labeling = CreateLabelingOfCellArray(WPmap);
[ProjectionWaveletMatrix, COEFF, NumOfPCs] = DimensionalityReduction(WaveletMatrix,Labeling);

W = ProjectionWaveletMatrix(:,1:3);
x = W(:,1);
y = W(:,2);
z = W(:,3);
% C=zeros(80,3);
% for i=1:20    
%     r=rand(1);
%     g=rand(1);
%     b=rand(1);
%     C(i,:) = [r g b];
%     C(i+20,:) = [r g b];
%     C(i+40,:) = [r g b];
%     C(i+60,:) = [r g b];  
% end
% figure('Name','PCA + LDA - 3D');
% h = scatter3(x,y,z,25,C,'filled');

% new try 

