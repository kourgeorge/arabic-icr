function [ InfoMeas ] = InformationMeasure( Sequence, epsilon )
%INFORMATIONMEASURE This function calculates the entropy of a 2-d signal
%   Detailed explanation goes here

InfoMeas = 0;
if (size(Sequence,1)<3)
    return
end

[abs] = SimplifyContour(Sequence, epsilon);

if (size(abs,1)<3)
    return
end
for i=2:(length(abs)-1)
   v1 = abs(i-1,:)-abs(i,:);
   v2 = abs(i+1,:)-abs(i,:);
   theta = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
   InfoMeas = InfoMeas + (pi-theta)/(pi/6);
end
    
end

