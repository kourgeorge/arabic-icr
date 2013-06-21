function WordSequence= CellArray2Sequence( Word )
%STRUCT2SEQUENCE Summary of this function goes here
%   Detailed explanation goes here

WordSequence = [];
for i=1:size(Word,2)
    temp = Word{i};
    WordSequence  = [WordSequence;Inf,Inf;temp];
end
WordSequence = WordSequence(2:end,:);

end

