function [ Contour ] = NormalizeContLetter(Contour,Letter,Pos)
%NORMALIZECONTLETTER this function takes a contour and letter name and it position as an input
% and acording to arabic logics of words the function normalized it between
% -1 and 1 .
temp = Contour(:,1);
Contourtemp(:,1) = temp(temp~=Inf('single'));
temp=  Contour(:,2);
Contourtemp(:,2) = temp(temp~=Inf('single'));
MeanXY = mean(Contourtemp);
Contour = Contour - repmat(MeanXY,size(Contour,1),1);
MaxX = max(Contourtemp(:,1));
MaxY = max(Contourtemp(:,2));
MinX = min(Contourtemp(:,1));
MinY = min(Contourtemp(:,2));

dX = MaxX-MinX;
dY = MaxY-MinY;
norm = max(dX,dY);
normalizaFactor =  GetNormFromLetter(Letter,Pos);
Contour(:,1) = Contour(:,1) / ( norm * normalizaFactor) ;
Contour(:,2) = Contour(:,2) / ( norm * normalizaFactor ) ;


function [NormRange] = GetNormFromLetter(Letter,Pos)

if (strcmp(Pos,'Mid') || strcmp(Pos,'Ini'))
    switch(Letter)
        case 'H'
            NormRange =2;
            return;
        case 'K'
            NormRange =1;
            return;
        case 'L'
            NormRange =1;
            return;
        case 'S'
            NormRange =4;
            return;
        case '7'
            NormRange =2;
            return;
        case 'B'
            NormRange =2;
            return;
        case '3'
            NormRange =4;
            return;
        case 'M'
            NormRange = 4;
        otherwise
            NormRange =3;
            return;
    end
elseif (strcmp(Pos,'Fin'))
    switch(Letter)
        case '6'
            NormRange =3;
            return;
        case '8'
            NormRange =1;
            return;
        case 'D'
            NormRange =2;
            return;
        case 'H'
            NormRange =1;
            return;
        case 'R'
            NormRange =2;
            return;
        otherwise
            NormRange =1;
            return;
            
    end
else
    NormRange =1;
end

