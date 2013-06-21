function Sequence = String2Sequence (Data)
%STRING2SEQUENCE Summary of this function goes here
%   Detailed explanation goes here

x=str2num(Data); % parse the string of data into array of x,y numbers
len = size(x,2); % get the length of the description of data for each PENDOWN
len = len/2; % divide the length on 2, because we have description of X cordinate and Y cordinate

for i =1:len
    x1(i)=x((i*2)-1); % make a new array of x cordinates
    y1(i)=x((i*2)); % make a new array of y cordiantes
end

Sequence = [x1;-y1]';
end

