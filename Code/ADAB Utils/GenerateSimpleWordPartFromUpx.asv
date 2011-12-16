function [ WordParts ] = GenerateSimpleWordPartFromUpx( UpxFilePath )
%GENERATESIMPLEWORDFROMADAB Summary of this function goes here
%   [ WordParts ] = GenerateSimpleWordPartFromUpx('C:\OCRData\adab_database_v1.0\Data\set_1\upx\1232278024170.upx')

%get the simplified word/words from the upx file.
SimplifiedWords = ReadUpxFile( UpxFilePath );

%get the inkml
InkmlFilePath = regexprep(UpxFilePath, 'upx', 'inkml');
Strokes = ReadInkmlFile( InkmlFilePath );
for i=1:size (SimplifiedWords,2)
    word = SimplifiedWords(i);
    word = word{1};
    WordParts = ExtractWordParts2( word )
end



end

