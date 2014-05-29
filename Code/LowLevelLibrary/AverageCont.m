function [ conts ] = AverageCont( cont )
%AVERAGECONT Summary of this function goes here
%   Detailed explanation goes here

conts(:,1)=conv(cont(:,1),[0.1; 0.1;0.4; 0.1; 0.1]);
conts(:,2)=conv(cont(:,2),[0.1 ;0.1;0.4; 0.1; 0.1]);
conts = conts(3:end-2,:);

end

