function [ Slope ] = CalculateSlope(Sequence,Point1,Point2)
%CALCULATESLOPE Summary of this function goes here
%   Detailed explanation goes here

start_env= Sequence(Point1,:);
end_env= Sequence(Point2,:);    
Slope = abs((end_env(2)-start_env(2))/-(end_env(1)-start_env(1))); %Arabic is written right to left
if (end_env(1)>start_env(1))
    Slope = -1/Slope;
end

if (Slope>100)
    Slope = 100;
end
if (Slope<-100)
    Slope = -100;
end   