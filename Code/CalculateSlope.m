function [ Slope ] = CalculateSlope(Sequence,Point1,Point2)
%CALCULATESLOPE Summary of this function goes here
%   Detailed explanation goes here

start_env= Sequence(Point1,:);
end_env= Sequence(Point2,:);    
Slope = abs((end_env(2)-start_env(2))/-(end_env(1)-start_env(1))); %Arabic is written right to left
if (Slope>1000)
    Slope = 1000;
end
   