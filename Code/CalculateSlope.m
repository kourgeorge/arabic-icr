function [ Slope ] = CalculateSlope(Sequence,CurrPoint,PointEnvLength)
%CALCULATESLOPE Summary of this function goes here
%   Detailed explanation goes here

start_env= Sequence(CurrPoint-PointEnvLength,:);
end_env= Sequence(CurrPoint,:);
Slope = abs((end_env(2)-start_env(2))/-(end_env(1)-start_env(1))); %Arabic is written right to left
