function varargout = Online(varargin)
% ONLINE M-file for Online.fig
%      ONLINE, by itself, creates a new ONLINE or raises the existing
%      singleton*.
%
%      H = ONLINE returns the handle to a new ONLINE or the handle to
%      the existing singleton*.
%
%      ONLINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONLINE.M with the given input arguments.
%
%      ONLINE('Property','Value',...) creates a new ONLINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Online_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Online_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Online

% Last Modified by GUIDE v2.5 02-Sep-2012 21:05:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Online_OpeningFcn, ...
                   'gui_OutputFcn',  @Online_OutputFcn, ...
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

% --- Executes just before Online is made visible.
function Online_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Online (see VARARGIN)


% Choose default command line output for Online
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Online.
if strcmp(get(hObject,'Visible'),'off')
%    plot(rand(5));
end

% UIWAIT makes Online wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Online_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global points;

% Get the root folder of the letters samples
SampleLettersFolder= get(handles.LettersSamplesFolderPath,'String'); 

% Get the current letter from the popup menu
letter = getItemFromPopUpMenu(handles.Letter);
letter = char(letter);

% Get the current letter position from the popup menu
pos = getItemFromPopUpMenu(handles.LetterPosition);
pos = char(pos);

%Get the current font class
FontClass = get(handles.FontClassEdit,'String');

% Save the file in the right directory
letterFolder = [SampleLettersFolder,'\',letter];
letterPosFolder = [letterFolder,'\',pos];
 
res = exist(letterPosFolder,'dir');
if (res==0)
   mkdir(letterPosFolder);
end
% Save as .m file
dlmwrite([letterPosFolder,'\',FontClass,'.m'], points)

%Save .jpg file

% A workaround to save the axes of the letter and not all the online figure
% create a new figure
tempfig = figure('visible','off');
% copy axes into the new figure
newax = copyobj(handles.LetterAxes,tempfig);
% change the figure size
set(newax, 'units', 'normalized', 'position', [0.13 0.11 0.775 0.815]);

PrevDir = pwd;
cd(letterPosFolder);
saveas(tempfig,FontClass,'jpg');
cd (PrevDir);


% [FileName,PathName] = uiputfile('*.*');
% if ~(PathName==0)
% 
%     % Save the sample XML document.
%     docNode=CreateXML(Letter, pos, points);
%     xmlFileName = [PathName,'\',FileName,'.xml'];
%     xmlwrite(xmlFileName,docNode);
%     edit(xmlFileName);
%     
% end
    
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in Letter.
function Letter_Callback(hObject, eventdata, handles)
% hObject    handle to Letter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Letter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Letter


% --- Executes during object creation, after setting all properties.
function Letter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Letter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end     

% --- Executes on selection change in LetterPosition.
function LetterPosition_Callback(hObject, eventdata, handles)
% hObject    handle to LetterPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LetterPosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LetterPosition

% --- Executes during object creation, after setting all properties.
function LetterPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LetterPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in draw.
function draw_Callback(hObject, eventdata, handles)
% hObject    handle to draw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global points;
points = TestingMouse();

%plot(handles.LetterAxes, points(:,1),points(:,2),'LineWidth',3);
scatter(handles.LetterAxes, points(:,1),points(:,2),'filled','o');
set(handles.LetterAxes,'Ylim',[0 1]);
set(handles.LetterAxes,'Xlim',[0 1]);

return;


function LettersSamplesFolderPath_Callback(hObject, eventdata, handles)
% hObject    handle to LettersSamplesFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LettersSamplesFolderPath as text
%        str2double(get(hObject,'String')) returns contents of LettersSamplesFolderPath as a double


% --- Executes during object creation, after setting all properties.
function LettersSamplesFolderPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LettersSamplesFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseFolder.
function BrowseFolder_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

start_path = (get(SamplePath,'String'));
dialog_title = 'Letters Examples Folder';

directory_name = uigetdir(start_path,dialog_title);
if ~(directory_name==0)
    set(handles.LettersSamplesFolderPath,'String',directory_name);   
end



function FontClassEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FontClassEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FontClassEdit as text
%        str2double(get(hObject,'String')) returns contents of FontClassEdit as a double



% --- Executes during object creation, after setting all properties.
function FontClassEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FontClassEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WPFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WPFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WPFileEdit as text
%        str2double(get(hObject,'String')) returns contents of WPFileEdit as a double


% --- Executes during object creation, after setting all properties.
function WPFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WPFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WPSeqFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WPSeqFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WPSeqFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of WPSeqFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function WPSeqFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WPSeqFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GenerateWPButton.
function GenerateWPButton_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateWPButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WPFile = get(handles.WPFileEdit,'String');
WPSeqFolder = get(handles.WPSeqFolderEdit, 'String'); 
SampleLettersFolder = get(handles.LettersSamplesFolderPath,'String');
FontClass = get(handles.FontClassEdit,'String');

set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();

if (get(handles.ImagesCB,'Value') == get(handles.ImagesCB,'Max'))
    NumOfWds = GenerateWordsFromFile( WPSeqFolder, WPFile,SampleLettersFolder, FontClass,'Yes');
else
    NumOfWds = GenerateWordsFromFile( WPSeqFolder, WPFile,SampleLettersFolder, FontClass,'No');
end

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');
drawnow();

% --- Executes on button press in WordPartsButton.
function WordPartsButton_Callback(hObject, eventdata, handles)
% hObject    handle to WordPartsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*.txt');
if ~(PathName==0)
    set (handles.WPFileEdit,'String',[PathName,FileName]);
end

% --- Executes on button press in WordPartSeqButton.
function WordPartSeqButton_Callback(hObject, eventdata, handles)
% hObject    handle to WordPartSeqButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start_path = get(handles.WPSeqFolderEdit,'String');
dialog_title = 'Target Folder';

directory_name = uigetdir(start_path,dialog_title);
if ~(directory_name==0)
    set(handles.WPSeqFolderEdit,'String',directory_name);
end


function FeaturesFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FeaturesFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FeaturesFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of FeaturesFolderEdit as a double
global WPFeaturesFolder;
WPFeaturesFolder = (get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function FeaturesFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FeaturesFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global WPFeaturesFolder;
WPFeaturesFolder = (get(hObject,'String'));

% --- Executes on button press in FeaturesFolderButton.
function FeaturesFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to FeaturesFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WPFeaturesFolder;

start_path = (get(hObject,'String'));
dialog_title = 'Target Folder';

directory_name = uigetdir(start_path,dialog_title);
if ~(directory_name==0)
    set(handles.FeaturesFolderEdit,'String',directory_name);
    WPFeaturesFolder = (get(hObject,'String'));
end

% --- Executes on button press in GenerateFeaturesButton.
function GenerateFeaturesButton_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateFeaturesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global WPFeaturesFolder;
global AngularFeature;
global MSC;

WPSeqFolder = get(handles.WPSeqFolderEdit,'String');
set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();

if (AngularFeature==1)
    CreateFVFromSamplesFolder(WPSeqFolder, WPFeaturesFolder,1);
end

if (MSC==1)
     CreateFVFromSamplesFolder(WPSeqFolder, WPFeaturesFolder,2);
end

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');

% --- Executes on button press in AngularFeature.
function AngularFeature_Callback(hObject, eventdata, handles)
% hObject    handle to AngularFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AngularFeature
global AngularFeature;
AngularFeature = (get(hObject,'Value') == get(hObject,'Max'));

% --- Executes on button press in MSCFeature.
function MSCFeature_Callback(hObject, eventdata, handles)
% hObject    handle to MSCFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MSCFeature
global MSC;
MSC = (get(hObject,'Value') == get(hObject,'Max'));


% --- Executes on button press in ImagesCB.
function ImagesCB_Callback(hObject, eventdata, handles)
% hObject    handle to ImagesCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImagesCB


% --- Executes on button press in GenerateWaveletButton.
function GenerateWaveletButton_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateWaveletButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


WPContourSamplesFolder = get(handles.WPSeqFolderEdit,'String');
WaveletFolder = get(handles.WaveletFolderEdit,'String');
ShapeContext= (get(handles.W_ShapeContextFeature,'Value') == get(handles.W_ShapeContextFeature,'Max')); 
AngularFeature = (get(handles.W_AngularFeature,'Value') == get(handles.W_AngularFeature,'Max'));
ResampleSize = str2num(get(handles.VectorSize,'String'));

set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();

res = exist(WaveletFolder,'dir');
if (res==0)
    mkdir(WaveletFolder);
end

if (AngularFeature==1)
    CreateWaveletsFromSamplesFolder(WPContourSamplesFolder,WaveletFolder,ResampleSize,1);
end

if (ShapeContext==1)
    CreateWaveletsFromSamplesFolder(WPContourSamplesFolder,WaveletFolder,ResampleSize,2);
end

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');



function WaveletFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WaveletFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WaveletFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of WaveletFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function WaveletFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaveletFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WaveletFolderButton.
function WaveletFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to WaveletFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in W_AngularFeature.
function W_AngularFeature_Callback(hObject, eventdata, handles)
% hObject    handle to W_AngularFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of W_AngularFeature


% --- Executes on button press in W_ShapeContextFeature.
function W_ShapeContextFeature_Callback(hObject, eventdata, handles)
% hObject    handle to W_ShapeContextFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of W_ShapeContextFeature



function VectorSize_Callback(hObject, eventdata, handles)
% hObject    handle to VectorSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VectorSize as text
%        str2double(get(hObject,'String')) returns contents of VectorSize as a double


% --- Executes during object creation, after setting all properties.
function VectorSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VectorSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BuildKdTree.
function BuildKdTree_Callback(hObject, eventdata, handles)
% hObject    handle to BuildKdTree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

WaveletFolder = get(handles.WaveletFolderEdit,'String');
TargetkdTreeFolder = get(handles.kdTreeFileEdit,'String');

ShapeContext= (get(handles.W_ShapeContextFeature,'Value') == get(handles.W_ShapeContextFeature,'Max')); 
AngularFeature = (get(handles.W_AngularFeature,'Value') == get(handles.W_AngularFeature,'Max'));
ResampleSize = str2num(get(handles.VectorSize,'String'));


set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();



if (AngularFeature==1)
    BuildkdTreeFromFolder( WaveletFolder , TargetkdTreeFolder , 1, ResampleSize);
end

if (ShapeContext==1)
    BuildkdTreeFromFolder( WaveletFolder,TargetkdTreeFolder , 2, ResampleSize);
end

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');

function kdTreeFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to kdTreeFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of kdTreeFileEdit as text
%        str2double(get(hObject,'String')) returns contents of kdTreeFileEdit as a double


% --- Executes during object creation, after setting all properties.
function kdTreeFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kdTreeFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in kdTreeButton.
function kdTreeButton_Callback(hObject, eventdata, handles)
% hObject    handle to kdTreeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

start_path = get(handles.kdTreeFileEdit, 'String');


directory_name = uigetdir(start_path);
if ~(directory_name==0)
    set(handles.kdTreeFileEdit,'String',directory_name);
end


% --- Executes on button press in BuildLSH.
function BuildLSH_Callback(hObject, eventdata, handles)
% hObject    handle to BuildLSH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WaveletFolder = get(handles.WaveletFolderEdit,'String');
TargetLSHFolder = get(handles.LSHFileEdit,'String');

ShapeContext= (get(handles.W_ShapeContextFeature,'Value') == get(handles.W_ShapeContextFeature,'Max')); 
AngularFeature = (get(handles.W_AngularFeature,'Value') == get(handles.W_AngularFeature,'Max'));
ResampleSize = str2num(get(handles.VectorSize,'String'));


set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();



if (AngularFeature==1)
    BuildLSHFromFolder( WaveletFolder, TargetLSHFolder, 1, ResampleSize);
end

if (ShapeContext==1)
    BuildLSHFromFolder( WaveletFolder, TargetLSHFolder, 2, ResampleSize);
end

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');


function LSHFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LSHFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSHFileEdit as text
%        str2double(get(hObject,'String')) returns contents of LSHFileEdit as a double


% --- Executes during object creation, after setting all properties.
function LSHFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSHFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LSHButton.
function LSHButton_Callback(hObject, eventdata, handles)
% hObject    handle to LSHButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start_path = get(handles.LSHFileEdit, 'String');

directory_name = uigetdir(start_path);
if ~(directory_name==0)
    set(handles.LSHFileEdit,'String',directory_name);
end



function SVMStructFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SVMStructFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SVMStructFileEdit as text
%        str2double(get(hObject,'String')) returns contents of SVMStructFileEdit as a double


% --- Executes during object creation, after setting all properties.
function SVMStructFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SVMStructFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GenerateSVMStruct.
function GenerateSVMStruct_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateSVMStruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();

SVMPath = get(handles.SVMStructFileEdit, 'String');
CharacterFolder = get(handles.WPSeqFolderEdit, 'String');
GenerateSP_SVMStructFromFolder( CharacterFolder,SVMPath );

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');



function LettersFeatureEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LettersFeatureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LettersFeatureEdit as text
%        str2double(get(hObject,'String')) returns contents of LettersFeatureEdit as a double


% --- Executes during object creation, after setting all properties.
function LettersFeatureEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LettersFeatureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in L_AngularFeature.
function L_AngularFeature_Callback(hObject, eventdata, handles)
% hObject    handle to L_AngularFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of L_AngularFeature


% --- Executes on button press in L_ShapeContextFeature.
function L_ShapeContextFeature_Callback(hObject, eventdata, handles)
% hObject    handle to L_ShapeContextFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of L_ShapeContextFeature


% --- Executes on button press in GenerateLettersFeatures.
function GenerateLettersFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateLettersFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LettersSamplesFolderFolder = get(handles.LettersSamplesEdit,'String');
TargetLettersFolder = get(handles.LettersFeatureEdit,'String');

ShapeContext= (get(handles.L_ShapeContextFeature,'Value') == get(handles.L_ShapeContextFeature,'Max')); 
AngularFeature = (get(handles.L_AngularFeature,'Value') == get(handles.L_AngularFeature,'Max'));
SequenceFeature = (get(handles.L_Sequence,'Value') == get(handles.L_Sequence,'Max'));
ResampleSize = str2num(get(handles.LetterResampleEdit,'String'));


set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();


if (SequenceFeature==1)
    BuildLettersDictionary( LettersSamplesFolderFolder , TargetLettersFolder, 0, ResampleSize);
end

if (AngularFeature==1)
    BuildLettersDictionary( LettersSamplesFolderFolder , TargetLettersFolder, 1, ResampleSize);
end

if (ShapeContext==1)
    BuildLettersDictionary( LettersSamplesFolderFolder , TargetLettersFolder, 2, ResampleSize);
end

set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');

% --- Executes on key press with focus on GenerateLettersFeatures and none of its controls.
function GenerateLettersFeatures_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to GenerateLettersFeatures (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function LettersSamplesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LettersSamplesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LettersSamplesEdit as text
%        str2double(get(hObject,'String')) returns contents of LettersSamplesEdit as a double


% --- Executes during object creation, after setting all properties.
function LettersSamplesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LettersSamplesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in L_Sequence.
function L_Sequence_Callback(hObject, eventdata, handles)
% hObject    handle to L_Sequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of L_Sequence



function LetterResampleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LetterResampleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LetterResampleEdit as text
%        str2double(get(hObject,'String')) returns contents of LetterResampleEdit as a double


% --- Executes during object creation, after setting all properties.
function LetterResampleEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LetterResampleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
