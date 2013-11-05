function  SegmentationVisualValidation( SegmentedWordsFolder )
%SEGMENTATIONVISUALVALIDATION This function creates images of the city
%names extracted from the XML for visual validation that the segmentation
%was done correctly.
%   SegmentationVisualValidation( 'C:\Users\kour\Second Degree\Hand Writing recognition\Arabic ICR\Data\TestSet' )


delete([SegmentedWordsFolder,'\*.jpg']);
LetFolder = dir(fullfile(SegmentedWordsFolder,'*.xml'));
lenOfFolder = length(LetFolder);


for i=1 : lenOfFolder
    filename = [SegmentedWordsFolder,'\',LetFolder(i).name];
    xmlToMatlabStruct = parseXML(filename); % getting the xml from choosen item
    Name = xmlToMatlabStruct.Attributes(2).Value;
    xmlToParsedStruct=xmlToMatlabStruct.Children; % parse the data from the structure into childrens
    lenOfAllWordParts=size(xmlToParsedStruct,2); % getting the length of chidlrens
    color=1;
    for j = 1 : 1 : floor(lenOfAllWordParts/2)
        lenOfCurrentWordPart = size(xmlToParsedStruct(1,j*2).Children,2);
        for k = 1 : 1 : floor(lenOfCurrentWordPart/2)
            LetterChar = xmlToParsedStruct(1,j*2).Children(1,k*2).Attributes(1).Value;
            LetterData = xmlToParsedStruct(1,j*2).Children(1,k*2).Children(1).Data;
            
            [x,y] = GetXyCoridnates(LetterData);
            if (isempty(x) || isempty(y))
                continue;
            end
            y=-y;
            color = 1-color;
            cstring = 'rc';
            ax = plot(x,y,cstring(color+1));
            %ax = plot(x,y,'Color',rand(1,3) );
            hold on;
        end
    end
    hold off;
    title(Name);
    saveas(ax,filename(:,1:end-4),'jpg');
end



function [x,y] = GetXyCoridnates(DataStruct)
intDataStruct=str2num(DataStruct); % parse the string of data into array of x,y numbers
len = size(intDataStruct,2); % get the length of the description of data for each PENDOWN
len = len/2 + 1; % divide the length on 2, because we have description of X cordinate and Y cordinate
x=[];y=[];
for i =1:len-1
    x(i)=intDataStruct((i*2)-1); % make a new array of x cordinates
    y(i)=intDataStruct((i*2)); % make a new array of y cordiantes
end
