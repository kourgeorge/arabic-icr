function ResampledSequence = ResampleSequence( Sequence, Nt )
%RESAMPLESEQUENCE Summary of this function goes here
%   CharacterSequence = dlmread(['C:\OCRData\GeneratedWordsIso\sample1\B.m']);
%   SimplifiedContour = SimplifyContour( CharacterSequence)
%   resampleSequence( SimplifiedContour )

% here is a simple polygon, a triangle. Note that
% I've wrapped the ends, so that the last point is
% also the first point. This is necessary.

%Sequence = [Sequence; Sequence(1,:)]
px = Sequence(:,1)';
py = Sequence(:,2)';

% t is the cumulative arclength along the edges of the polygon.
t = cumsum(sqrt([0,diff(px(:)').^2] + [0,diff(py(:)').^2]));

% The total distance around the polygon is t(end)
tmax = t(end);

% create a piecewise linear spline for each of px and py,
% as a function of the cumulative chordwise arclength.
splx = mkpp(t,[diff(px(:))./diff(t'),px(1:(end-1))']);
sply = mkpp(t,[diff(py(:))./diff(t'),py(1:(end-1))']);

% now interpolate the polygon splines, splx and sply.
% Nt is the number of points to generate around the
% polygon. The first and last points should be replicates
% at least to within floating point trash.)
tint = linspace(0,tmax,Nt);

qx = ppval(splx,tint);
qy = ppval(sply,tint);

ResampledSequence = [qx;qy]';

% plot the polygon itself, as well as the generated points.
%
% scatter(Sequence(:,1),Sequence(:,2));
% hold on;
% scatter(ResampledSequence(:,1),ResampledSequence(:,2));

end

