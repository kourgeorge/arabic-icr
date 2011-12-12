function [ SimplifiedContour ] = SimplifyContour( Contour)
%CONTOURSIMPLIFICATION returns a simplified contour of the givem one using Recursive Douglas-Peucker Polyline Simplification.
%   Detailed explanation goes here

MinX = min(Contour(:,1));
MaxX = max(Contour(:,1));
MinY = min(Contour(:,2));
MaxY = max(Contour(:,2));

Dx = MaxX - MinX;
Dy = MaxY - MinY;

minD = min(Dx,Dy);

epsilon = minD/75;

[ps,ix] = dpsimplify(Contour,epsilon);

SimplifiedContour = ps;

end

