function [NormContour] = NormalizeCont(Contour)
% The The dimentions of the Contour should be [Dx2]. Means the sequence
% should be a column vector, where each row 2 a point on the contour

temp = Contour(:,1);
Contourtemp(:,1) = temp(temp~=Inf('single'));
temp=  Contour(:,2);
Contourtemp(:,2) = temp(temp~=-Inf('single'));

MeanXY = mean(Contourtemp);
CenteredContour = Contourtemp - repmat(MeanXY,size(Contourtemp,1),1);

MaxX = max(CenteredContour(:,1));
MinX = min(CenteredContour(:,1));

MaxY = max(CenteredContour(:,2));
MinY = min(CenteredContour(:,2));

norm = max((MaxX-MinX),(MaxY-MinY));
NormContour(:,1) = CenteredContour(:,1)/norm;
NormContour(:,2) = CenteredContour(:,2)/norm;

end