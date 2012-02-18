function  Length  = SequenceLength( Sequence )
%SEQLENGTH Summary of this function goes here
%   Detailed explanation goes here

[len,n] = size(Sequence);
Length = 0;
if (len < 2)
    return;
end
for i=2:len
    Length = Length+norm(Sequence(i,:)-Sequence(i-1,:),2);
end
end

