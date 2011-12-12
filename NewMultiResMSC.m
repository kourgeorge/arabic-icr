function [ResAngsOfCont]   = NewMultiResMSC( cont ,NumOfRes )
%NEWMULTIRESMSC Calulate the MSC feature in different resolutions/Altitudes
%   Detailed explanation goes here

%Normalize and the Average the contour.
cont = NormalizeCont(cont);
normalizedCont = AverageCont(cont);

%Calculate the width and height of the normalized contour.
W = max(normalizedCont(:,1)) - min(normalizedCont(:,1));
H = max(normalizedCont(:,2)) - min(normalizedCont(:,2));

%MSC_Ring Parameters
Radius = max(W,H)/2;
NumOfViewPoint = 20;
Altitude = 2;

ResAngsOfCont = [];
% Calculate the MSC in different Altitudes/Resolutions.
for i=1:NumOfRes
    AngsRing = MSC_Ring(normalizedCont, Altitude^(i-2), NumOfViewPoint/i, Radius/i);
    AngsRing = AngsRing';
    ResAngsOfCont = [ResAngsOfCont ; AngsRing] ;
end

end

