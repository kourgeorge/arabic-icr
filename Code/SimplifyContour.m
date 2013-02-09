function [ SimplifiedContourMIN, SimplifiedContourMAX] = SimplifyContour( Contour)
%CONTOURSIMPLIFICATION returns a simplified contour of the givem one using Recursive Douglas-Peucker Polyline Simplification.
%   Detailed explanation goes here

MinX = min(Contour(:,1));
MaxX = max(Contour(:,1));
MinY = min(Contour(:,2));
MaxY = max(Contour(:,2));

Dx = MaxX - MinX;
Dy = MaxY - MinY;

minD = min(Dx,Dy);

epsilon = sqrt(Dx^2+Dy^2)/200;

[ps,ix] = dpsimplify(Contour,epsilon);

SimplifiedContourMIN = ps;

if (nargout==2)
    epsilon = 1/200; %epsilon is absolute
    [ps,~] = dpsimplify(Contour,epsilon);
    SimplifiedContourMAX = ps;
end

