function [NormContour] = NormalizeCont(Contour)
% The The dimentions of the Contour should be [Dx2]. Means the sequence
% should be a column vector, where each row 2 a point on the contour

temp = Contour(:,1);
Contourtemp(:,1) = temp(temp~=Inf('single'));
temp=  Contour(:,2);
Contourtemp(:,2) = temp(temp~=Inf('single'));

MeanXY = mean(Contourtemp);
CenteredContour = Contour - repmat(MeanXY,size(Contour,1),1);

temp = CenteredContour(:,1);
MaxX = max(temp(temp~=Inf('single')));
MinX = min(temp(temp~=Inf('single')));

temp = CenteredContour(:,2);
MaxY = max(temp(temp~=Inf('single')));
MinY = min(temp(temp~=Inf('single')));

norm = max((MaxX-MinX),(MaxY-MinY));
NormContour(:,1) = CenteredContour(:,1)/norm;
NormContour(:,2) = CenteredContour(:,2)/norm;

end