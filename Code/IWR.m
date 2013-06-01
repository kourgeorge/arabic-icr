function varargout = IWR(varargin)
% IWR M-file for IWR.fig
%      IWR, by itself, creates a new IWR or raises the existing
%      singleton*.
%
%      H = IWR returns the handle to a new IWR or the handle to
%      the existing singleton*.
%
%      IWR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IWR.M with the given input arguments.
%
%      IWR('Property','Value',...) creates a new IWR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IWR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IWR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IWR

% Last Modified by GUIDE v2.5 03-Sep-2012 18:35:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IWR_OpeningFcn, ...
                   'gui_OutputFcn',  @IWR_OutputFcn, ...
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


% --- Executes just before IWR is made visible.
function IWR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IWR (see VARARGIN)

% Choose default command line output for IWR
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IWR wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IWR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ClosestEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ClosestEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ClosestEdit as text
%        str2double(get(hObject,'String')) returns contents of ClosestEdit as a double


% --- Executes during object creation, after setting all properties.
function ClosestEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ClosestEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ClosestWPListBox.
function ClosestWPListBox_Callback(hObject, eventdata, handles)
% hObject    handle to ClosestWPListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ClosestWPListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ClosestWPListBox


% --- Executes during object creation, after setting all properties.
function ClosestWPListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ClosestWPListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RecognizeWP.
function RecognizeWP_Callback(hObject, eventdata, handles)
% hObject    handle to RecognizeWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global InputContour;

WPFeaturesFolder = get(handles.DataFolderEdit,'String');
WPFeaturesFolder = [WPFeaturesFolder,'\','Features'];

set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();

Closest = str2num(get(handles.ClosestEdit,'String'));

if (get(handles.AngularRB2,'Value') == get(handles.AngularRB2,'Max') && get(handles.DTWRB2,'Value') == get(handles.DTWRB2,'Max'))
    Candidates = RecognizeWP(InputContour, WPFeaturesFolder, 'Angular', 'DTW' ,Closest );
end

if (get(handles.ShapeContextRB2,'Value') == get(handles.ShapeContextRB2,'Max') && get(handles.DTWRB2,'Value') == get(handles.DTWRB2,'Max'))
    Candidates = RecognizeWP(InputContour, WPFeaturesFolder, 'ShapeContext', 'DTW' ,Closest );
end

if (get(handles.AngularRB2,'Value') == get(handles.AngularRB2,'Max') && get(handles.EMDRB2,'Value') == get(handles.EMDRB2,'Max'))
    Candidates = RecognizeWP(InputContour, WPFeaturesFolder, 'Angular', 'App_EMD' ,Closest );
end

if (get(handles.ShapeContextRB2,'Value') == get(handles.ShapeContextRB2,'Max') && get(handles.EMDRB2,'Value') == get(handles.EMDRB2,'Max'))
    Candidates = RecognizeWP(InputContour, WPFeaturesFolder, 'ShapeContext', 'App_EMD' ,Closest );
end

if (get(handles.ContourRB2,'Value') == get(handles.ContourRB2,'Max') && get(handles.DTWRB2,'Value') == get(handles.DTWRB2,'Max'))
    Candidates = RecognizeWP(InputContour, WPSeqFolder , 'Contour', 'DTW' ,Closest );
end

if (get(handles.ContourRB2,'Value') == get(handles.ContourRB2,'Max') && get(handles.EMDRB2,'Value') == get(handles.EMDRB2,'Max'))
    Candidates = RecognizeWP(InputContour, WPSeqFolder , 'Contour', 'App_EMD' ,Closest );
end


Results = [];
for i=1:length(Candidates)
    Candidate = Candidates(i,:);
    letter = Candidate(1);
    value = Candidate(2);
    Elem = strcat(letter, '.........', num2str(value{1}));
    Results = [Results;Elem];
end
set(handles.ClosestWPListBox,'String',Results);
set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');

% --- Executes on button press in DrawWordPart.
function DrawWordPart_Callback(hObject, eventdata, handles)
% hObject    handle to DrawWordPart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global InputContour;

InputContour = TestingMouse();

%Simplify the contour.
[~,InputContour] = SimplifyContour(InputContour);

plot(handles.InputWPAxes,InputContour(:,1),InputContour(:,2),'LineWidth',3);

return;


function DataFolderEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DataFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DataFolderEdit as text
%        str2double(get(hObject,'String')) returns contents of DataFolderEdit as a double


% --- Executes during object creation, after setting all properties.
function DataFolderEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataFolderEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DataFolderButton.
function DataFolderButton_Callback(hObject, eventdata, handles)
% hObject    handle to DataFolderButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WPFeaturesFolder = get(handles.DataFolderEdit,'String');

start_path = WPFeaturesFolder;
dialog_title = 'Target Folder';

directory_name = uigetdir(start_path,dialog_title);
if ~(directory_name==0)
    set(handles.DataFolderEdit,'String',directory_name);
end


% --- Executes on button press in RecognizeWP_Wavelets.
function RecognizeWP_Wavelets_Callback(hObject, eventdata, handles)
% hObject    handle to RecognizeWP_Wavelets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global InputContour;

DataFolder = get(handles.DataFolderEdit,'String');
Closest = str2num(get(handles.ClosestEdit,'String'));
Angular = get(handles.AngularRB2,'Value') == get(handles.AngularRB2,'Max');
ShapeContext = get(handles.ShapeContextRB2,'Value') == get(handles.ShapeContextRB2,'Max');
KDTree = get(handles.kdTreeRB,'Value') == get(handles.kdTreeRB,'Max');
LSH = get(handles.LSHRB,'Value') == get(handles.LSHRB,'Max');
set(handles.Status,'String', 'Busy');
set(handles.Status,'ForegroundColor','red');
drawnow();

Results = [];


if (Angular==1 && KDTree==1)
ClosestWPs = RecognizeWPkdTree( InputContour, [DataFolder,'\kdtree\Angular.mat'], 1, Closest );
end

if (ShapeContext==1 && KDTree==1)
ClosestWPs = RecognizeWPkdTree( InputContour, [DataFolder,'\kdtree\ShapeContext.mat'], 2, Closest );
end

if (Angular==1 && LSH==1)
ClosestWPs = RecognizeWPLSH( InputContour, [DataFolder,'\LSH\Angular.mat'], 1, Closest );
end

if (ShapeContext==1 && LSH==1)
ClosestWPs = RecognizeWPLSH( InputContour, [DataFolder,'\LSH\ShapeContext.mat'], 2, Closest );
end


set(handles.ClosestWPListBox,'String',ClosestWPs);
set(handles.Status,'String', 'Ready');
set(handles.Status,'ForegroundColor','green');


% --- Executes on button press in ProgressRecognitionButton.
function ProgressRecognitionButton_Callback(hObject, eventdata, handles)
% hObject    handle to ProgressRecognitionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DataFolder = get(handles.DataFolderEdit,'String');
Closest = str2num(get(handles.ClosestEdit,'String'));
clc;
ProgressiveRecognizerPen (DataFolder,Closest);



function LettersDSEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LettersDSEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LettersDSEdit as text
%        str2double(get(hObject,'String')) returns contents of LettersDSEdit as a double


% --- Executes during object creation, after setting all properties.
function LettersDSEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LettersDSEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
