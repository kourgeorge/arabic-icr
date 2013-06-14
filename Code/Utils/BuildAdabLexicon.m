function BuildAdabLexicon( ADABSetUPXPath, OutputFilePath)
%BUILDADABLEXICON Summary of this function goes here
%   BuildAdabLexicon( 'C:\Users\kour\OCRData Old\Archieve\adab_database_v1.0\Data\set_1', 'C:\OCRData\ADAB Lexicon.txt')

Lexicon = {};
UpxFileList = dir([ADABSetUPXPath,'\upx']);
for i=3:size(UpxFileList,1)
    current_object = UpxFileList(i);
    FileName = current_object.name;
    FileName = strtok(FileName, '.');
    [arabascii,theWord] = parseUPX(FileName,ADABSetUPXPath,true);
    theWord = strtrim(theWord);
    Lexicon = [Lexicon;{theWord}];
end

UniqueLexicon = unique(Lexicon);
fid = fopen(OutputFilePath, 'wt');
for i=1:length(UniqueLexicon)
    fprintf(fid, '%s\n', UniqueLexicon{i});
end
fclose(fid);