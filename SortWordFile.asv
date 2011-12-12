function [ output_args ] = SortWordFile( inputFilepath,outputFilePath )
%SORTWORDFILE Summary of this function goes here
%   SortWordFile('C:\OCRData\TestLegs50.txt','C:\OCRData\TestLegs50sorted.txt' )

fid = fopen(inputFilepath);
Wd= fgetl(fid);
cell={};
while (Wd ~= -1)
    cell = [cell;Wd];
    Wd= fgetl(fid);
end
fclose(fid);

UniqueCellArray = unique(cell);
edit(outputFilePath);
fid = fopen(outputFilePath,'wt');
len = length(UniqueCellArray);
for i=1:len-1
    word = UniqueCellArray{i};
    fprintf(fid,'%s\n',word);
end

word = UniqueCellArray{len};
fprintf(fid,'%s',word);

fclose(fid);