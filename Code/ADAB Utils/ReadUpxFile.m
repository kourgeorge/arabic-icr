function [ SimplifiedWords ] = ReadUpxFile( UpxFilePath )
%READUPXFILE Summary of this function goes here
%   [ SimplifiedWord ] =
%   [ SimplifiedWord ] = ReadUpxFile('C:\OCRData\adab_database_v1.0\Data\set_1\upx\1232278024170.upx') %2 parts
%   [ SimplifiedWord ] = ReadUpxFile('C:\OCRData\adab_database_v1.0\Data\set_1\upx\1232015419464.upx') %1 part

theStruct = ReadXML(UpxFilePath);
alternateCild = theStruct.Children(6).Children(2).Children(2).Children(2);
word = dec2hex(0+alternateCild.Attributes.Value);
wordsCellArray = Split2Words (word);
SimplifiedWords = [];
for i=1:size(wordsCellArray,1)
    Word = wordsCellArray(i);
    Word = Word{1};
    [ num_removed_letters , SimplifiedWord] = SimplifyWord2( Word );
    SimplifiedWords = [SimplifiedWords;{SimplifiedWord}];
end
end

function wordsCellArray = Split2Words (Word)
cellArray = cell(size(Word,1),1);
for i=1:size(Word,1)
    cel = Word(i,:);
    cellArray(i) = {cel};
end
k = find(ismember(Word,{'020'})==1); %we assume that there is max 2 words in each name
wordsCellArray = [{Word(1:k-1,:)};{Word(k+1:size(Word,1),:)}];

end