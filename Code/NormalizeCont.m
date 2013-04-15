function [NormContour] = NormalizeCont(Contour)
% The The dimentions of the Contour should be [Dx2]. Means the sequence
% should be a column vector, where each row 2 a point on the contour
MeanXY = mean(Contour);
CenteredContour = Contour - repmat(MeanXY,size(Contour,1),1);
MaxX = max(CenteredContour(:,1));
MaxY = max(CenteredContour(:,2));
MinX = min(CenteredContour(:,1));
MinY = min(CenteredContour(:,2));

norm = max((MaxX-MinX),(MaxY-MinY));
NormContour(:,1) = CenteredContour(:,1)/norm;
NormContour(:,2) = CenteredContour(:,2)/norm;

end