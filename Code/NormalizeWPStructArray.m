function [ NormalizedWPStructArray ] = NormalizeWPStructArray( WPStructArray )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sequence = [];
for i=1:length(WPStructArray)
    sequence = [sequence;WPStructArray(i).Sequence];
end

temp = sequence(:,1);
sequencetemp(:,1) = temp(temp~=Inf('single'));
temp=  sequence(:,2);
sequencetemp(:,2) = temp(temp~=-Inf('single'));

MeanXY = mean(sequencetemp);
CenteredSequence = sequencetemp - repmat(MeanXY,size(sequencetemp,1),1);


for i=1:length(WPStructArray)
    WPStructArray(i).Sequence = WPStructArray(i).Sequence-repmat(MeanXY,size(WPStructArray(i).Sequence,1),1);
end

MaxX = max(CenteredSequence(:,1));
MinX = min(CenteredSequence(:,1));

MaxY = max(CenteredSequence(:,2));
MinY = min(CenteredSequence(:,2));

norm = max((MaxX-MinX),(MaxY-MinY));

for i=1:length(WPStructArray)
    WPStructArray(i).Sequence = WPStructArray(i).Sequence/norm;
end

NormalizedWPStructArray = WPStructArray;
end
