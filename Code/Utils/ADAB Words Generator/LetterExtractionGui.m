function varargout = LetterExtractionGui(varargin)
% LETTEREXTRACTIONGUI MATLAB code for LetterExtractionGui.fig
%      LETTEREXTRACTIONGUI, by itself, creates a new LETTEREXTRACTIONGUI or raises the existing
%      singleton*.
%
%      H = LETTEREXTRACTIONGUI returns the handle to a new LETTEREXTRACTIONGUI or the handle to
%      the existing singleton*.
%
%      LETTEREXTRACTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LETTEREXTRACTIONGUI.M with the given input arguments.
%
%      LETTEREXTRACTIONGUI('Property','Value',...) creates a new LETTEREXTRACTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LetterExtractionGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LetterExtractionGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LetterExtractionGui

% Last Modified by GUIDE v2.5 28-May-2013 09:17:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LetterExtractionGui_OpeningFcn, ...
    'gui_OutputFcn',  @LetterExtractionGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LetterExtractionGui is made visible.
function LetterExtractionGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LetterExtractionGui (see VARARGIN)

% Choose default command line output for LetterExtractionGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LetterExtractionGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LetterExtractionGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ADABEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ADABEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ADABEdit as text
%        str2double(get(hObject,'String')) returns contents of ADABEdit as a double


% --- Executes during object creation, after setting all properties.
function ADABEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADABEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseButton.
function BrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start_path = (get(hObject,'String'));
dialog_title = 'DataBase ADAB files';

directory_name = uigetdir(start_path,dialog_title);
if ~(directory_name==0)
    set(handles.ADABEdit,'String',directory_name);
end


% --- Executes on button press in ADABfilesButton.
function ADABfilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to ADABfilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ImagePath = [get(handles.ADABEdit,'String'),'\','images'];
XmlsPath = [get(handles.ADABEdit,'String'),'\','inkml'];
if (exist(ImagePath,'dir')==0)
    msgbox('Not valid DataBase','Error') ;
    return;
end
if (exist(XmlsPath,'dir')==0)
    msgbox('Not valid DataBase','Error') ;
    return;
end
set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','Red');
drawnow();
if isfield(handles,'images')
    clear handles.images;
end
if isfield(handles,'xmls')
    clear handles.xmls;
end

files = dir(fullfile(ImagePath,'*.tif'));  % get all the pictuers files
files2 = dir(fullfile(XmlsPath,'*.inkml')); % get all the xmls files
len = length(files);  % get the length of the pictuers file which is equal to the size of xml file
for i = 1 : len
    
    handles.images{i} = files(i).name; % save the pictuers name into handles
    handles.xmls{i}= files2(i).name;     % save the xmls  names into handles
    files(i).name= strrep(files(i).name,'.tif','');
end

set(handles.listbox1,'string',{files.name}); % set the names on the text box

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','Green');
drawnow();

guidata(hObject, handles);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global NumOfStrokes;
global WordData;
global EnglishWord;
global arabAscii;
global xmlToParsedStruct;
global Word;
newline = sprintf('\n');
index = get(handles.listbox1,'value');
name=get(handles.listbox1,'string');
ImagePath = [get(handles.ADABEdit,'String'),'\','images','\',char(name(index)),'.tif'];
strrep(ImagePath, newline, 's');
XmlsPath = [get(handles.ADABEdit,'String'),'\','inkml','\',char(name(index)),'.inkml'];
UPXpath = [get(handles.ADABEdit,'String'),'\','upx\'];
imshow(ImagePath,'Parent',handles.axes1);
[temping,EnglishWord] = parseUPX(name(index),UPXpath);
arabAscii = ArabicAscii(name(index),UPXpath);
set( handles.Englishtxt, 'String', EnglishWord );
set( handles.arabictxt, 'String', arabAscii );
xmlToMatlabStruct = theStruct(XmlsPath); % getting the xml from choosen item
xmlToParsedStruct=xmlToMatlabStruct.Children; % parse the data from the structure into childrens
len=size(xmlToParsedStruct,2); % getting the length of chidlrens

NumOfStrokes=1; % index for each new data
WordData=[];
for i=6:2:len-1
    WordData{NumOfStrokes} = {xmlToParsedStruct(1,i).Children.Data}; % saving the datas of cordinates into structre s
    NumOfStrokes=NumOfStrokes+1;
end;
[Word] = ConvertWordSequence(WordData);
PlotWord(Word,handles.axes2);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DeleteAdditonalButton.
function DeleteAdditonalButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteAdditonalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Word;
rec = round(getrect(handles.axes2));
Word = RemoveAdditonalStrokes(rec,Word);
PlotWord(Word,handles.axes2);



% --- Executes on button press in ClearDatabutton.
function ClearDatabutton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearDatabutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NumOfStrokes;
global WordData;
global arabAscii;
global EnglishWord;
clear NumOfStrokes;
clear WordData;
clear arabAscii;
clear EnglishWord;
set( handles.Englishtxt, 'String', '' );
cla(handles.axes1);
cla(handles.axes2);
cla(handles.axes3);

if isfield(handles,'seq')
    handles.seq = [];
    h = findobj(handles.uipanel5,'Style','popupmenu');
    delete(h);
end
if isfield(handles,'let')
    handles.let=[];
    h=findobj(handles.uipanel5,'Style','text');
    delete(h);
end

guidata(hObject, handles);
% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open('readme.doc');

function PlotWord(Word,ax)
axes(ax);
cla(ax);
cstring='rgbcmk'; % color string
for i=1:size(Word,2)
    w = Word{i};
    plot(ax,w(:,1),w(:,2),cstring(mod(i,6)+1)); % ploting each word-part
    hold on;
end
hold off;


function [Word] = ConvertWordSequence(StrokesArray)
numStrokes = 1;
for j=1: size(StrokesArray,2)
    x=str2num(StrokesArray{j}{:}); % parse the string of data into array of x,y numbers
    len = size(x,2); % get the length of the description of data for each PENDOWN
    len = len/2; % divide the length on 2, because we have description of X cordinate and Y cordinate
    
    for i =1:len
        x1(i)=x((i*2)-1); % make a new array of x cordinates
        y1(i)=x((i*2)); % make a new array of y cordiantes
    end
    
    dist = finddistLneg(x1,y1);
    if(dist>10000)
        Word(numStrokes) = {[x1;-y1]'};
        numStrokes = numStrokes + 1;
    end

    clear x1; % clear the x and y cordinates
    clear y1;
end


function [len] =  finddistLneg(x,y)
diffx = max(x)-min(x);
diffy = max(y)-min(y);
len = diffx * diffy^4;


% --- Executes on button press in SaveWord_pushbutton.
function SaveWord_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveWord_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Word;
word = [];
for i=1:size(Word,2)
    temp = Word(i);
    word  = [word;Inf,Inf;temp{:}];
end
outputFolder = get(handles.targetFolder,'String');
Englishtxt = get(handles.Englishtxt,'String');
dlmwrite([outputFolder,'\',Englishtxt,'.m'],word(2:end,:));



function targetFolder_Callback(hObject, eventdata, handles)
% hObject    handle to targetFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetFolder as text
%        str2double(get(hObject,'String')) returns contents of targetFolder as a double


% --- Executes during object creation, after setting all properties.
function targetFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
