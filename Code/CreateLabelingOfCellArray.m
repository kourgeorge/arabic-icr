function LabelingArray = CreateLabelingOfCellArray( CellArray )
%CREATELABELINGOFCELLARRAY given a cell array of strings, this function
%create a mapping of these strings to integers.
%   Example: CellArray=['aa' 'bb' 'cc' 'aa'] => LabelingArray = [1 2 3 1]

len = length(CellArray);
UniqueCellArray = unique(CellArray);
LabelingArray=zeros(len,1);
for i=1:len
    %find the index of the string i in the unique array.
    ind = find(ismember(UniqueCellArray, CellArray(i))==1);
    LabelingArray(i)=ind;
end

