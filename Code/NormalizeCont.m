function [Contour] = NormalizeCont(Contour)
% The The dimentions of the Contour should be [Dx2]. Means the sequence
% should be a column vector, where each row 2 a point on the contour
MeanXY = mean(Contour);
Contour = Contour - repmat(MeanXY,size(Contour,1),1);
MaxX = max(Contour(:,1));
MaxY = max(Contour(:,2));
MinX = min(Contour(:,1));
MinY = min(Contour(:,2));

Contour(:,1) = Contour(:,1)/(MaxX-MinX);
Contour(:,2) = Contour(:,2)/(MaxY-MinY);

end