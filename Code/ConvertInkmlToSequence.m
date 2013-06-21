function [ Word ] = ConvertInkmlToSequence( DataSetPath, filename )
%CONVERTINKMLTOSEQUENCE Summary of this function goes here
%   Detailed explanation goes here
% [ WordSequence ] = ConvertInkmlToSequence( 'C:\Users\kour\OCRData Old\Archieve\adab_database_v1.0\Data\set_1', '1231874526312' )


inkmlPath = [DataSetPath,'\inkml\',filename,'.inkml'];
xmlToMatlabStruct = parseXML(inkmlPath); % getting the xml from choosen item
xmlToParsedStruct=xmlToMatlabStruct.Children; % parse the data from the structure into childrens
len=size(xmlToParsedStruct,2); % getting the length of chidlrens
NumOfStrokes=1; % index for each new data
WordData=[];
for i=6:2:len-1
    x=size(str2num( xmlToParsedStruct(1,i).Children.Data)); % parse the string of data into array of x,y numbers
    WordData{NumOfStrokes} = {xmlToParsedStruct(1,i).Children.Data}; % saving the datas of cordinates into structre s
    NumOfStrokes=NumOfStrokes+1;
end;
StrokesArray = WordData;

numStrokes = 1;
for j=1: size(StrokesArray,2)
    x=str2num(StrokesArray{j}{:}); % parse the string of data into array of x,y numbers
    len = size(x,2); % get the length of the description of data for each PENDOWN
    len = len/2; % divide the length on 2, because we have description of X cordinate and Y cordinate
    
    for i =1:len
        x1(i)=x((i*2)-1); % make a new array of x cordinates
        y1(i)=x((i*2)); % make a new array of y cordiantes
    end
    
    Word(numStrokes) = {[x1;-y1]'};
    numStrokes = numStrokes + 1;
    
    
    clear x1; % clear the x and y cordinates
    clear y1;
end

