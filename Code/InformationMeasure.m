function [ InfoMeas ] = InformationMeasure( Sequence, epsilon, maxSlope )
%INFORMATIONMEASURE This function calculates the entropy of a 2-d signal
%   Detailed explanation goes here

InfoMeas = 0;
% If the seuqnce contains only a single point
if (size(Sequence,1)<2)
    return;
end

[absSimplifiedSequence] = SimplifyContour(Sequence, epsilon);

% if (size(absSimplifiedSequence,1)<3)
%     return
% end
for i=2:(length(absSimplifiedSequence)-1)
   v1 = absSimplifiedSequence(i-1,:)-absSimplifiedSequence(i,:);
   v2 = absSimplifiedSequence(i+1,:)-absSimplifiedSequence(i,:);
   theta = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
   InfoMeas = InfoMeas + (pi-theta)/(pi/6);
end

Slope = CalculateSlope(Sequence,1,length(Sequence));
InfoMeas = InfoMeas + abs(Slope/maxSlope);

end

