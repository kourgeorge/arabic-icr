function [ WPStructArray ] = XML2WPStructArray( XMLFileName )
%XML2WPStructArray Summary of this function goes here
%   Detailed explanation goes here

index = 1;
xmlToMatlabStruct = parseXML(XMLFileName); % getting the xml from choosen item
for i=1:length(xmlToMatlabStruct.Children)
    if  strcmp(xmlToMatlabStruct.Children(i).Name,'WordPart')
        WP = getWordPart(xmlToMatlabStruct.Children(i));
        if (~isempty(WP.Label))
            WPs(index) = WP;
            index = index+1;
        end
    end
end

WPStructArray = WPs;


end

function WPStruct = getWordPart (WordPartNode)
label = '';
sequence = [];
for j=1:length(WordPartNode.Children)
    if  strcmp(WordPartNode.Children(j).Name,'Letter')
        LetterNode = WordPartNode.Children(j);
        label = [label,LetterNode.Attributes(1).Value];
        CurrentLetterSequence = GetSequenceFromString(LetterNode.Children(1).Data);
        sequence = [sequence;CurrentLetterSequence(1:end,:)];
    end
    
end
WPStruct.Label = label;
WPStruct.Sequence = sequence;
end

function Sequence = GetSequenceFromString (Data)
x=str2num(Data); % parse the string of data into array of x,y numbers
len = size(x,2); % get the length of the description of data for each PENDOWN
len = len/2; % divide the length on 2, because we have description of X cordinate and Y cordinate

for i =1:len
    x1(i)=x((i*2)-1); % make a new array of x cordinates
    y1(i)=x((i*2)); % make a new array of y cordiantes
end

Sequence = [x1;-y1]';
end
