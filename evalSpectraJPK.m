function varargout = evalSpectraJPK(varargin)
% EVALSPECTRAJPK MATLAB code for evalSpectraJPK.fig
%      EVALSPECTRAJPK, by itself, creates a new EVALSPECTRAJPK or raises the existing
%      singleton*.
%
%      H = EVALSPECTRAJPK returns the handle to a new EVALSPECTRAJPK or the handle to
%      the existing singleton*.
%
%      EVALSPECTRAJPK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVALSPECTRAJPK.M with the given input arguments.
%
%      EVALSPECTRAJPK('Property','Value',...) creates a new EVALSPECTRAJPK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evalSpectraJPK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evalSpectraJPK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evalSpectraJPK

% Last Modified by GUIDE v2.5 03-Feb-2017 20:21:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @evalSpectraJPK_OpeningFcn, ...
                   'gui_OutputFcn',  @evalSpectraJPK_OutputFcn, ...
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


% --- Executes just before evalSpectraJPK is made visible.
function evalSpectraJPK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to evalSpectraJPK (see VARARGIN)

% Choose default command line output for evalSpectraJPK
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Put your home directory here: '/Volumes/Transcend/Uni/Data'
global home;
home = '/Volumes/Transcend/Uni/Data';

% UIWAIT makes evalSpectraJPK wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = evalSpectraJPK_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoadReference.
function pushbuttonLoadReference_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Global variable home is defined in evalSpectraJPK_OpeningFcn. This holds
%the default home directory to start in the uigetfile dialog.

global home

[filename,path]  = uigetfile([home '/*.*']);

%Stop if dialog was cancled.
if filename==0
    return
end

%Load complex forward and backward interferograms.
[IFfw, IFbw] = loadJPKspectra([path filename]);

%Get number of points for FFT from the text edit editNumPointsFFT
n = str2double(get(handles.editNumPointsFFT,'string'));

%Do alignment of interferograms, apodization, cutting, zerofilling and FFT.
checkAlignment = get(handles.checkboxCheckAlignment,'value');

%Get Mode: either just take sample side or reference side or both
mode = get(handles.popupmenuMode,'value');

%Get Phasecorrection
phaseCorrection = get(handles.checkboxPhaseCorrection,'value');

%Get zerofilling-factor
zerofilling = str2double(get(handles.editZeroFilling,'string'));

[fwRef,~] = JPKFFT(IFfw,n,zerofilling,0.4,checkAlignment,mode,phaseCorrection);
[bwRef,wn] = JPKFFT(IFbw,n,zerofilling,0.4,checkAlignment,mode,phaseCorrection);

%Save interferograms, spectra and wavenumber arrays in handles and
%workspace variables.
handles.IFfwRef = IFfw;
handles.IFbwRef = IFbw;
handles.fwRef = fwRef;
handles.bwRef = bwRef;
handles.wn = wn;
assignin('base','IFfwRef',IFfw);
assignin('base','IFbwRef',IFbw);
assignin('base','fwRef',fwRef);
assignin('base','bwRef',bwRef);
assignin('base','wn',wn);

guidata(hObject, handles);

% --- Executes on button press in pushbuttonPlotAmplitude.
function pushbuttonPlotAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlotAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure

wn = handles.wn;

if get(handles.checkboxReferencePlot,'value')
    if get(handles.checkboxComplexConj,'value')
        fwSpect = abs(mean((handles.fwSample+fliplr(conj(handles.fwSample)))./2)./mean((handles.fwRef+fliplr(conj(handles.fwRef)))./2));
        bwSpect = abs(mean((handles.bwSample+fliplr(conj(handles.bwSample)))./2)./mean((handles.bwRef+fliplr(conj(handles.bwRef)))./2));
            
        [~,fwS,~] = calcStdDev((handles.fwSample+fliplr(conj(handles.fwSample)))./2,(handles.fwRef+fliplr(conj(handles.fwRef)))./2);
        [~,bwS,~] = calcStdDev((handles.bwSample+fliplr(conj(handles.bwSample)))./2,(handles.bwRef+fliplr(conj(handles.bwRef)))./2);
    else
        fwSpect = abs(mean(handles.fwSample)./mean(handles.fwRef));
        bwSpect = abs(mean(handles.bwSample)./mean(handles.bwRef));
            
        [~,fwS,~] = calcStdDev(handles.fwSample,handles.fwRef);
        [~,bwS,~] = calcStdDev(handles.bwSample,handles.bwRef);
    end
    h = plot(wn,fwSpect,wn,bwSpect);

    patch([wn fliplr(wn) wn(1)], [fwSpect-fwS fliplr(fwSpect+fwS) fwSpect(1)-fwS(1)],'b','EdgeColor','none','FaceAlpha',0.1)
    patch([wn fliplr(wn) wn(1)], [bwSpect-bwS fliplr(bwSpect+bwS) bwSpect(1)-bwS(1)],'r','EdgeColor','none','FaceAlpha',0.1)
    uistack(h,'top');
    ylabel '|s_n / {s_n}^{ref}|'
else
    if get(handles.checkboxComplexConj,'value')
        plot(wn,abs(mean(handles.fwSample+fliplr(conj(handles.fwSample)))./2),wn,abs(mean(handles.fwRef+fliplr(conj(handles.fwRef)))./2),wn,abs(mean(handles.bwSample+fliplr(conj(handles.bwSample)))./2),wn,abs(mean(handles.bwRef+fliplr(conj(handles.bwRef)))./2))
    else
        plot(wn,abs(mean(handles.fwSample)),wn,abs(mean(handles.fwRef)),wn,abs(mean(handles.bwSample)),wn,abs(mean(handles.bwRef)))
    end
    
    ylabel '|s_n| [V]'
end

xlabel 'Wavenumber [cm^{-1}]'
set(gca,'XDir','rev')
xlim([1300 2000]);

% --- Executes on button press in pushbuttonPlotPhase.
function pushbuttonPlotPhase_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlotPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure

wn = handles.wn;

if get(handles.checkboxReferencePlot,'value')
    if get(handles.checkboxComplexConj,'value')
        fwSpect = angle(mean((handles.fwSample+fliplr(conj(handles.fwSample)))./2)./mean((handles.fwRef+fliplr(conj(handles.fwRef)))./2));
        bwSpect = angle(mean((handles.bwSample+fliplr(conj(handles.bwSample)))./2)./mean((handles.bwRef+fliplr(conj(handles.bwRef)))./2));
            
        [~,~,fwP] = calcStdDev((handles.fwSample+fliplr(conj(handles.fwSample)))./2,(handles.fwRef+fliplr(conj(handles.fwRef)))./2);
        [~,~,bwP] = calcStdDev((handles.bwSample+fliplr(conj(handles.bwSample)))./2,(handles.bwRef+fliplr(conj(handles.bwRef)))./2);
    else
        fwSpect = angle(mean(handles.fwSample)./mean(handles.fwRef));
        bwSpect = angle(mean(handles.bwSample)./mean(handles.bwRef));
    
        [~,~,fwP] = calcStdDev(handles.fwSample,handles.fwRef);
        [~,~,bwP] = calcStdDev(handles.bwSample,handles.bwRef);
    end
    
    
    h = plot(wn,fwSpect,wn,bwSpect);
    patch([wn fliplr(wn) wn(1)], [fwSpect-fwP fliplr(fwSpect+fwP) fwSpect(1)-fwP(1)],'b','EdgeColor','none','FaceAlpha',0.1)
    patch([wn fliplr(wn) wn(1)], [bwSpect-bwP fliplr(bwSpect+bwP) bwSpect(1)-bwP(1)],'r','EdgeColor','none','FaceAlpha',0.1)
    uistack(h,'top')
    ylabel '\phi_n - {\phi_n}^{ref} [rad]'
else
    if get(handles.checkboxComplexConj,'value')
        plot(wn,angle(mean(handles.fwSample+fliplr(conj(handles.fwSample)))./2),wn,angle(mean(handles.fwRef+fliplr(conj(handles.fwRef)))./2),wn,angle(mean(handles.bwSample+fliplr(conj(handles.bwSample)))./2),wn,angle(mean(handles.bwRef+fliplr(conj(handles.bwRef)))./2))
    else
        plot(wn,angle(mean(handles.fwSample)),wn,angle(mean(handles.fwRef)),wn,angle(mean(handles.bwSample)),wn,angle(mean(handles.bwRef)))
    end
    
    ylabel '\phi_n [rad]'
end

xlabel 'Wavenumber [cm^{-1}]'
set(gca,'XDir','rev')
xlim([1300 2000]);

% --- Executes on button press in pushbuttonLoadSample.
function pushbuttonLoadSample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Global variable home is defined in evalSpectraJPK_OpeningFcn. This holds
%the default home directory to start in the uigetfile dialog.
global home

[filename,path]  = uigetfile([home '/*.*']);

%Stop if dialog was cancled.
if filename==0
    return
end

%Load complex forward and backward interferograms.
[IFfw, IFbw] = loadJPKspectra([path filename]);

%Get number of points for FFT from the text edit editNumPointsFFT
n = str2double(get(handles.editNumPointsFFT,'string'));

%Do alignment of interferograms, apodization, cutting, zerofilling and FFT.
checkAlignment = get(handles.checkboxCheckAlignment,'value');

%Get Mode: either just take sample side or reference side or both
mode = get(handles.popupmenuMode,'value');

%Get Phasecorrection
phaseCorrection = get(handles.checkboxPhaseCorrection,'value');

%Get zerofilling-factor
zerofilling = str2double(get(handles.editZeroFilling,'string'));

[fwSample,~] = JPKFFT(IFfw,n,zerofilling,0.4,checkAlignment,mode,phaseCorrection);
[bwSample,wn] = JPKFFT(IFbw,n,zerofilling,0.4,checkAlignment,mode,phaseCorrection);

%Save interferograms, spectra and wavenumber arrays in handles and
%workspace variables.
handles.IFfwSample = IFfw;
handles.IFbwSample = IFbw;
handles.fwSample = fwSample;
handles.bwSample = bwSample;
handles.wn = wn;
assignin('base','IFfwSample',IFfw);
assignin('base','IFbwSample',IFbw);
assignin('base','fwSample',fwSample);
assignin('base','bwSample',bwSample);
assignin('base','wn',wn);

guidata(hObject, handles);

% --- Executes on button press in checkboxReferencePlot.
function checkboxReferencePlot_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxReferencePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxReferencePlot



function editNumPointsFFT_Callback(hObject, eventdata, handles)
% hObject    handle to editNumPointsFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumPointsFFT as text
%        str2double(get(hObject,'String')) returns contents of editNumPointsFFT as a double
value = str2num(get(handles.editNumPointsFFT,'string'));

if round(log2(value)) ~= log2(value)
    set(handles.editNumPointsFFT,'string',num2str(2^round(log2(value))));
end

% --- Executes during object creation, after setting all properties.
function editNumPointsFFT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumPointsFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxCheckAlignment.
function checkboxCheckAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCheckAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxCheckAlignment


% --- Executes on selection change in popupmenuMode.
function popupmenuMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMode


% --- Executes during object creation, after setting all properties.
function popupmenuMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPlotImag.
function pushbuttonPlotImag_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlotImag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure

wn = handles.wn;

if get(handles.checkboxReferencePlot,'value')
    if get(handles.checkboxComplexConj,'value')
        fwSpect = imag(mean((handles.fwSample+fliplr(conj(handles.fwSample)))./2)./mean((handles.fwRef+fliplr(conj(handles.fwRef)))./2));
        bwSpect = imag(mean((handles.bwSample+fliplr(conj(handles.bwSample)))./2)./mean((handles.bwRef+fliplr(conj(handles.bwRef)))./2));
            
        [fwI,~,~] = calcStdDev((handles.fwSample+fliplr(conj(handles.fwSample)))./2,(handles.fwRef+fliplr(conj(handles.fwRef)))./2);
        [bwI,~,~] = calcStdDev((handles.bwSample+fliplr(conj(handles.bwSample)))./2,(handles.bwRef+fliplr(conj(handles.bwRef)))./2);
    else
        fwSpect = imag(mean(handles.fwSample)./mean(handles.fwRef));
        bwSpect = imag(mean(handles.bwSample)./mean(handles.bwRef));
    
        [fwI,~,~] = calcStdDev(handles.fwSample,handles.fwRef);
        [bwI,~,~] = calcStdDev(handles.bwSample,handles.bwRef);
    end
    
    h = plot(wn,fwSpect,wn,bwSpect);
    fwI = imag(fwI);
    bwI = imag(bwI);
    patch([wn fliplr(wn) wn(1)], [fwSpect-fwI fliplr(fwSpect+fwI) fwSpect(1)-fwI(1)],'b','EdgeColor','none','FaceAlpha',0.1)
    patch([wn fliplr(wn) wn(1)], [bwSpect-bwI fliplr(bwSpect+bwI) bwSpect(1)-bwI(1)],'r','EdgeColor','none','FaceAlpha',0.1)
    uistack(h,'top');
    ylabel 'Im(s_n/{s_n}^{ref})'
else
    if get(handles.checkboxComplexConj,'value')
        plot(wn,imag(mean(handles.fwSample+fliplr(conj(handles.fwSample)))./2),wn,imag(mean(handles.fwRef+fliplr(conj(handles.fwRef)))./2),wn,imag(mean(handles.bwSample+fliplr(conj(handles.bwSample)))./2),wn,imag(mean(handles.bwRef+fliplr(conj(handles.bwRef)))./2))
    else
        plot(wn,imag(mean(handles.fwSample)),wn,imag(mean(handles.fwRef)),wn,imag(mean(handles.bwSample)),wn,imag(mean(handles.bwRef)))
    end
    
    ylabel 'Im(s_n) [V]'
end

xlabel 'Wavenumber [cm^{-1}]'
set(gca,'XDir','rev')
xlim([1300 2000]);



function editZeroFilling_Callback(hObject, eventdata, handles)
% hObject    handle to editZeroFilling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editZeroFilling as text
%        str2double(get(hObject,'String')) returns contents of editZeroFilling as a double


% --- Executes during object creation, after setting all properties.
function editZeroFilling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editZeroFilling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxPhaseCorrection.
function checkboxPhaseCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPhaseCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPhaseCorrection



function editSpectrumName_Callback(hObject, eventdata, handles)
% hObject    handle to editSpectrumName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpectrumName as text
%        str2double(get(hObject,'String')) returns contents of editSpectrumName as a double


% --- Executes during object creation, after setting all properties.
function editSpectrumName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpectrumName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSaveSpectrum.
function pushbuttonSaveSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    spectrum.wn = handles.wn;
    spectrum.forwardSample = handles.fwSample;
    spectrum.forwardRef = handles.fwRef;
    spectrum.backwardSample = handles.bwSample;
    spectrum.backwardRef = handles.bwRef;
    spectrum.forwardSampleStdDev = calcStdDev(handles.fwSample);
    spectrum.forwardRefStdDev = calcStdDev(handles.fwRef);
    spectrum.backwardSampleStdDev = calcStdDev(handles.bwSample);
    spectrum.backwardRefStdDev = calcStdDev(handles.bwRef);
    
    assignin('base',char(get(handles.editSpectrumName,'String')),spectrum);

    guidata(hObject, handles);


% --- Executes on button press in checkboxComplexConj.
function checkboxComplexConj_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxComplexConj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxComplexConj


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

