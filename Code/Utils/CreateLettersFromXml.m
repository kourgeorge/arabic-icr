function [] = CreateLettersFromXml(LettersXMLsourcefolder,LettersSamplesfolder,IncludeImages)
%usage example:
%CreateLettersFromXml('C:\Users\kour\Desktop\alldata\SequencesFolder','C:\Users\kour\Desktop\letters',1)

LetFolder = dir(fullfile(LettersXMLsourcefolder,'*.xml'));
lenOfFolder = length(LetFolder);
if (strcmp(IncludeImages,'Yes'))
    fig = figure();
    ax = gca;
    
    
end
for i=1 : lenOfFolder
    xmlToMatlabStruct = parseXML([LettersXMLsourcefolder,'\',LetFolder(i).name]); % getting the xml from choosen item
    xmlToParsedStruct=xmlToMatlabStruct.Children; % parse the data from the structure into childrens
    lenOfAllWordParts=size(xmlToParsedStruct,2); % getting the length of chidlrens
    PrevDir=pwd;
    for j = 1 : 1 : floor(lenOfAllWordParts/2)
        lenOfCurrentWordPart = size(xmlToParsedStruct(1,j*2).Children,2);
        for k = 1 : 1 : floor(lenOfCurrentWordPart/2)
            LetterChar = xmlToParsedStruct(1,j*2).Children(1,k*2).Attributes(1).Value;
            LetterData = xmlToParsedStruct(1,j*2).Children(1,k*2).Children(1).Data;
            
            [x,y] = GetXyCoridnates(LetterData);
            if (isempty(x) || isempty(y))
                continue;
            end
            if ~exist([LettersSamplesfolder,'\',LetterChar], 'dir')
                mkdir([LettersSamplesfolder,'\',LetterChar]);
            end
            cd([LettersSamplesfolder,'\',LetterChar]);
            if(k==1 && k==  floor(lenOfCurrentWordPart/2))
                if ~exist('Iso', 'dir')
                    mkdir('Iso');
                    
                end
                Pos='Iso';
                cd('Iso');
            elseif(k==1)
                if ~exist('Ini', 'dir')
                    mkdir('Ini');
                    
                end
                Pos='Ini';
                cd('Ini');
            elseif(k==floor(lenOfCurrentWordPart/2))
                if ~exist('Fin', 'dir')
                    mkdir('Fin');
                    
                end
                Pos = 'Fin';
                cd('Fin');
            else
                if ~exist('Mid', 'dir')
                    mkdir('Mid');
                end
                Pos = 'Mid';
                cd('Mid');
            end
            tmppwd = pwd;
            cd (PrevDir);
            Contor = [x(:),y(:)];
            %Contor=NormalizeCont(Contor,LetterChar,Pos);
            clear x;
            clear y;
            x = Contor(:,1);
            y = Contor(:,2);
            cd (tmppwd);
            numOfSmaple=size(dir([pwd,'\*.m']),1)+1 ;
            dlmwrite([pwd,'\','sample',num2str(numOfSmaple),'.m'],[x(:),-y(:)]);
            if (strcmp(IncludeImages,'Yes'))
                plot(ax,x(:),-y(:),'LineWidth',3);
                saveas(ax,['sample',num2str(numOfSmaple)],'jpg');
                cla(ax);
            end
            cd (PrevDir);
            clear x;
            clear y;
        end
    end
end



function [ax] = plotToax(ax,x,y,Contor)
plottingTemp = find(x == Inf('single'));
currentInd = 1;
for Fi=1 : size(plottingTemp,1)
    hold off;
    ploitngX = x(currentInd:plottingTemp(Fi)-1);
    ploitngY =  y(currentInd:plottingTemp(Fi)-1);
    plot (ax,ploitngX ,-ploitngY ,'LineWidth',3);
    currentInd = plottingTemp(Fi) + 1;
    hold on;
end
ploitngX = x(currentInd:size(Contor,1));
ploitngY =  y(currentInd:size(Contor,1));
plot (ax,ploitngX ,-ploitngY ,'LineWidth',3);




function [x,y] = GetXyCoridnates(DataStruct)
intDataStruct=str2num(DataStruct); % parse the string of data into array of x,y numbers
len = size(intDataStruct,2); % get the length of the description of data for each PENDOWN
len = len/2; % divide the length on 2, because we have description of X cordinate and Y cordinate
x=[];y=[];
for i =1:len-1
    x(i)=intDataStruct((i*2)-1); % make a new array of x cordinates
    y(i)=intDataStruct((i*2)); % make a new array of y cordiantes
end
