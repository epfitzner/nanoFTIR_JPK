function varargout = evalSpectra(varargin)
% EVALSPECTRA MATLAB code for evalSpectra.fig
%      EVALSPECTRA, by itself, creates a new EVALSPECTRA or raises the existing
%      singleton*.
%
%      H = EVALSPECTRA returns the handle to a new EVALSPECTRA or the handle to
%      the existing singleton*.
%
%      EVALSPECTRA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVALSPECTRA.M with the given input arguments.
%
%      EVALSPECTRA('Property','Value',...) creates a new EVALSPECTRA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evalSpectra_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evalSpectra_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evalSpectra

% Last Modified by GUIDE v2.5 11-May-2016 20:50:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @evalSpectra_OpeningFcn, ...
                   'gui_OutputFcn',  @evalSpectra_OutputFcn, ...
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


% --- Executes just before evalSpectra is made visible.
function evalSpectra_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to evalSpectra (see VARARGIN)

% Choose default command line output for evalSpectra
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes evalSpectra wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = evalSpectra_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonSelectParentFolder.
function pushbuttonSelectParentFolder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectParentFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global counter;

%Reset counter for 'hold' (copies all ploted spectra to variable 'spectra')
counter = 1;
evalin('caller',['clear ','spectra']) 

%get parent directory and returns a vector with only subfolders
directory = uigetdir;
d = dir(directory);
isub = [d(:).isdir]; %# returns logical vector
folders = {d(isub).name}';

%discard the folders '.' and '..'
folders(ismember(folders,{'.','..'})) = [];
%discard all folders, which not contain 'fourier' ('fourier' is a keyword for a folder containing a spectrum)
folders(cellfun('isempty',strfind(folders,'fourier'))) = [];

%copy the found folder names to the Workspace
assignin('base','folders',folders);

handles.dir = directory;
handles.folders = folders;

set(handles.listbox1,'string',folders);

listbox1_Callback(hObject,eventdata,handles);

guidata(hObject, handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


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


% --- Executes on button press in pushbuttonSelectReference.
function pushbuttonSelectReference_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
index = get(handles.listbox1,'value');
dir = strcat(handles.dir,'/',handles.folders(index));
handles.refDir = dir;
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSelectSample.
function pushbuttonSelectSample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global counter;

%Set the focus back to the listbox
uicontrol(handles.listbox1);

handles.output = hObject;
index = get(handles.listbox1,'value');
dir = strcat(handles.dir,'/',handles.folders(index));
handles.sampleDir = dir;
guidata(hObject, handles);

n = str2num(get(handles.editOrder,'String'));
zerofilling = str2num(get(handles.editZerofillingFactor,'String'));
singelSided = get(handles.checkboxSingleSided,'value');
length = str2num(get(handles.editIFPoints,'String'));
wnMin = str2num(get(handles.editWnLowLimit,'String'));
wnMax = str2num(get(handles.editWnHighLimit,'String'));

[sample, ref, wn] = loadSpectra(char(handles.sampleDir),char(handles.refDir), n,zerofilling, singelSided, length);


if get(handles.checkboxHold,'value')
    handles.spectra{counter,1} = char(handles.sampleDir);
    handles.spectra{counter,2} = sample./ref;
    handles.spectra{counter,3} = sample;
    handles.spectra{counter,4} = ref;

    counter = counter + 1;

    assignin('base','spectra',handles.spectra);
else
    plotSpectra(sample,ref,wn,wnMin, wnMax,char(handles.sampleDir),char(handles.refDir),get(handles.checkboxPrint,'value'));
end

guidata(hObject, handles);

function editOrder_Callback(hObject, eventdata, handles)
% hObject    handle to editOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOrder as text
%        str2double(get(hObject,'String')) returns contents of editOrder as a double


% --- Executes during object creation, after setting all properties.
function editOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWnLowLimit_Callback(hObject, eventdata, handles)
% hObject    handle to editWnLowLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWnLowLimit as text
%        str2double(get(hObject,'String')) returns contents of editWnLowLimit as a double


% --- Executes during object creation, after setting all properties.
function editWnLowLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWnLowLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWnHighLimit_Callback(hObject, eventdata, handles)
% hObject    handle to editWnHighLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWnHighLimit as text
%        str2double(get(hObject,'String')) returns contents of editWnHighLimit as a double


% --- Executes during object creation, after setting all properties.
function editWnHighLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWnHighLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editIFPoints_Callback(hObject, eventdata, handles)
% hObject    handle to editIFPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIFPoints as text
%        str2double(get(hObject,'String')) returns contents of editIFPoints as a double


% --- Executes during object creation, after setting all properties.
function editIFPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIFPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editZerofillingFactor_Callback(hObject, eventdata, handles)
% hObject    handle to editZerofillingFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editZerofillingFactor as text
%        str2double(get(hObject,'String')) returns contents of editZerofillingFactor as a double


% --- Executes during object creation, after setting all properties.
function editZerofillingFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editZerofillingFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxHold.
function checkboxHold_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxHold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxHold


% --- Executes on button press in checkboxPrint.
function checkboxPrint_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPrint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPrint


% --- Executes on button press in checkboxSingleSidedase.
function checkboxSingleSided_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSingleSided (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSingleSided
