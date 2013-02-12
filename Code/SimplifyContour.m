function [ ProportionalSimplification, AbsoluteSimplification] = SimplifyContour( Contour)
%CONTOURSIMPLIFICATION returns a simplified contour of the givem one using Recursive Douglas-Peucker Polyline Simplification.
%   Detailed explanation goes here

MinX = min(Contour(:,1));
MaxX = max(Contour(:,1));
MinY = min(Contour(:,2));
MaxY = max(Contour(:,2));

Dx = MaxX - MinX;
Dy = MaxY - MinY;

epsilon = sqrt(Dx^2+Dy^2)/200;

[ps,~] = dpsimplify(Contour,epsilon);

ProportionalSimplification = ps;

if (nargout==2)
    epsilon = 1/200; %epsilon is absolute
    [ps,~] = dpsimplify(Contour,epsilon);
    AbsoluteSimplification = ps;
end

