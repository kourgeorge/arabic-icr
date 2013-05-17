function ExtractWordPartsFromFile( setPath, wordFileName, outputFolderPath)
%EXTRACTWORDPARTSFROMFILE Summary of this function goes here
%   Detailed explanation goes here

%wordFileName = '1231874627010';
%setPath = 'C:\Users\kour\OCRData Old\Archieve\adab_database_v1.0\Data\set_1\';
inkmlPath = [setPath,'\inkml\',wordFileName,'.inkml'];
xmlToMatlabStruct = theStruct(inkmlPath); % getting the xml from choosen item
xmlToParsedStruct=xmlToMatlabStruct.Children; % parse the data from the structure into childrens
len=size(xmlToParsedStruct,2); % getting the length of chidlrens
NumOfStrokes=1; % index for each new data
WordData=[];
for i=6:2:len-1
    x=size(str2num( xmlToParsedStruct(1,i).Children.Data)); % parse the string of data into array of x,y numbers
    WordData(NumOfStrokes).Data = xmlToParsedStruct(1,i).Children.Data; % saving the datas of cordinates into structre s
    NumOfStrokes=NumOfStrokes+1;
end;
strokesToBeRemoved=plotWords(WordData,setPath,wordFileName,outputFolderPath);
WordData(strokesToBeRemoved)=[];

end

function [strokesToRemove] = plotWords(Struct,setPath, wordFileName,outputFolderPath)
strokesToRemove=[];
for j=1:size(Struct,2)
    x=str2num(Struct(j).Data); % parse the string of data into array of x,y numbers
    len = size(x); % get the length of the description of data for each PENDOWN
    len = len(2)/2; % divide the length on 2, because we have description of X cordinate and Y cordinate
    
    for i =1:len
        x1(i)=x((i*2)-1); % make a new array of x cordinates
        y1(i)=x((i*2)); % make a new array of y cordiantes
    end
    dist = finddistLneg(x1,y1);
    if(dist>70000)
        %plot(ax,x1,-y1,cstring(mod(j,6)+1)); % ploting each word-part
        stroke = [x1;-y1]';
        [~,Word] = parseUPX(wordFileName,setPath);
        outputFileName = [outputFolderPath,'\',Word,'_',num2str(j)];
        dlmwrite([outputFileName,'.m'],stroke);
        ax = plot (stroke(:,1),stroke(:,2),'LineWidth',3);
        maxX = max(stroke(:,1)); minX = min(stroke(:,1)); maxY = max(stroke(:,2)); minY = min(stroke(:,2));
        windowSize = max(maxX-minX,maxY-minY);
        ylim([minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
        xlim([minX-0.1*windowSize minX+windowSize+0.1*windowSize]);
        saveas(ax,outputFileName,'jpg');
    else
        strokesToRemove=[strokesToRemove j];
    end
    clear x1; % clear the x and y cordinates
    clear y1;
end


end

function [len] =  finddistLneg(x,y)
diffx = max(x)-min(x);
diffy = max(y)-min(y);
len = diffx * diffy^4;
end
