function [ AbsoluteSimplification, ProportionalSimplification] = SimplifyContour( Contour, epsilon)
%CONTOURSIMPLIFICATION returns a simplified contour of the givem one using Recursive Douglas-Peucker Polyline Simplification.
%   Detailed explanation goes here

if (length(Contour)<3)
    AbsoluteSimplification = Contour;
    ProportionalSimplification = Contour;
    return;
end
if (nargin <2)
    epsilon = 1/75; %default absolute epsilon 
end
[ps,~] = dpsimplify(Contour,epsilon);
AbsoluteSimplification = ps;

if (nargout==2)
    MinX = min(Contour(:,1));
    MaxX = max(Contour(:,1));
    MinY = min(Contour(:,2));
    MaxY = max(Contour(:,2));
    
    Dx = MaxX - MinX;
    Dy = MaxY - MinY;
    
    epsilon = sqrt(Dx^2+Dy^2)/200;
    
    [ps,~] = dpsimplify(Contour,epsilon);
    
    ProportionalSimplification = ps;
end

