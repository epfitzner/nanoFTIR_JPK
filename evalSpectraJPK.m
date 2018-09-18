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

% Last Modified by GUIDE v2.5 06-Aug-2018 17:18:25

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

%Get File type
isBinary = get(handles.checkboxLoadBinary,'value');

%Which harmonic to load
harm = str2double(get(handles.editHarmonic,'string'));

if isBinary
    data = readLabviewData([path filename],4,'double',true);
    IFfw = reshape(data(harm,1,:,:),[size(data,3) size(data,4)]);
    IFbw = reshape(data(harm,2,:,:),[size(data,3) size(data,4)]);
else
    [IFfw, IFbw] = loadJPKspectra([path filename]);
end
        
[fwRef,~] = JPKFFT(IFfw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);
[bwRef,wn] = JPKFFT(IFbw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);

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

global colorCounter;
colors = lines(64);

if get(handles.checkboxAppend,'value')
    figure(1);
    hold on
    colorCounter = colorCounter+1;
else
    figure(1);
    colorCounter = 1;
end

idx = get(handles.listbox2,'value');

wn = handles.data(idx).wn;
fwSample = handles.data(idx).fwSample;
bwSample = handles.data(idx).bwSample;
fwRef = handles.data(idx).fwRef;
bwRef = handles.data(idx).bwRef;

if get(handles.checkboxReferencePlot,'value')
    if get(handles.checkboxComplexConj,'value')
        fwSpect = abs(mean(complexConjugateAvg(fwSample,2))./mean(complexConjugateAvg(fwRef,2)));
        bwSpect = abs(mean(complexConjugateAvg(bwSample,2))./mean(complexConjugateAvg(bwRef,2)));
            
        [~,fwS,~] = calcStdDev(complexConjugateAvg(fwSample,2),complexConjugateAvg(fwRef,2));
        [~,bwS,~] = calcStdDev(complexConjugateAvg(bwSample,2),complexConjugateAvg(bwRef,2));
    else
        fwSpect = abs(mean(fwSample)./mean(fwRef));
        bwSpect = abs(mean(bwSample)./mean(bwRef));
            
        [~,fwS,~] = calcStdDev(fwSample,fwRef);
        [~,bwS,~] = calcStdDev(bwSample,bwRef);
    end
    
    if get(handles.checkboxAvgForwBackw,'value')
        spec = (fwSpect+bwSpect)./2;
        h = plot(wn,spec,'color',colors(colorCounter,:));
        S = (fwS+bwS)./2;
        
        patch([wn fliplr(wn) wn(1)], [spec-S fliplr(spec+S) spec(1)-S(1)],colors(colorCounter,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        uistack(h,'top');
    else    
        h = plot(wn,fwSpect,'color',colors(colorCounter,:));
        hold on
        plot(wn,bwSpect,'color',colors(colorCounter+1,:));

        patch([wn fliplr(wn) wn(1)], [fwSpect-fwS fliplr(fwSpect+fwS) fwSpect(1)-fwS(1)],colors(colorCounter,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        patch([wn fliplr(wn) wn(1)], [bwSpect-bwS fliplr(bwSpect+bwS) bwSpect(1)-bwS(1)],colors(colorCounter+1,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        uistack(h,'top');
        hold off
        colorCounter = colorCounter+1;
    end
    ylabel '|s_n / {s_n}^{ref}|'
else
    if get(handles.checkboxComplexConj,'value')
        if get(handles.checkboxAvgForwBackw,'value')
            plot(wn,(abs(mean(complexConjugateAvg(fwSample,2)))+abs(mean(complexConjugateAvg(bwSample,2))))./2,wn,(abs(mean(complexConjugateAvg(fwRef,2)))+abs(mean(complexConjugateAvg(bwRef,2))))./2)
        else
            plot(wn,abs(mean(complexConjugateAvg(fwSample,2))),wn,abs(mean(complexConjugateAvg(fwRef,2))),wn,abs(mean(complexConjugateAvg(bwSample,2))),wn,abs(mean(complexConjugateAvg(bwRef,2))))
        end
    else
        if get(handles.checkboxAvgForwBackw,'value')
            plot(wn,(abs(mean(fwSample))+abs(mean(bwSample)))./2,wn,(abs(mean(fwRef))+abs(mean(bwRef)))./2)
        else
            plot(wn,abs(mean(fwSample)),wn,abs(mean(fwRef)),wn,abs(mean(bwSample)),wn,abs(mean(bwRef)))
        end
    end
    
    ylabel '|s_n| [V]'
end

xlabel 'Wavenumber [cm^{-1}]'
set(gca,'XDir','rev')
xlim([1100 2100]);

% --- Executes on button press in pushbuttonPlotPhase.
function pushbuttonPlotPhase_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlotPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global colorCounter;
colors = lines(64);

if get(handles.checkboxAppend,'value')
    figure(3);
    hold on
    colorCounter = colorCounter+1;
else
    figure(3);
    colorCounter = 1;
end

idx = get(handles.listbox2,'value');

wn = handles.data(idx).wn;
fwSample = handles.data(idx).fwSample;
bwSample = handles.data(idx).bwSample;
fwRef = handles.data(idx).fwRef;
bwRef = handles.data(idx).bwRef;

if get(handles.checkboxReferencePlot,'value')
    if get(handles.checkboxComplexConj,'value')
        fwSpect = angle(mean(complexConjugateAvg(fwSample,2))./mean(complexConjugateAvg(fwRef,2)));
        bwSpect = angle(mean(complexConjugateAvg(bwSample,2))./mean(complexConjugateAvg(bwRef,2)));
            
        [~,~,fwP] = calcStdDev(complexConjugateAvg(fwSample,2),complexConjugateAvg(fwRef,2));
        [~,~,bwP] = calcStdDev(complexConjugateAvg(bwSample,2),complexConjugateAvg(bwRef,2));
    else
        fwSpect = angle(mean(fwSample)./mean(fwRef));
        bwSpect = angle(mean(bwSample)./mean(bwRef));
    
        [~,~,fwP] = calcStdDev(fwSample,fwRef);
        [~,~,bwP] = calcStdDev(bwSample,bwRef);
    end
    
    if get(handles.checkboxAvgForwBackw,'value')
        spec = (fwSpect+bwSpect)./2;
        h = plot(wn,spec,'color',colors(colorCounter,:));
        P = (fwP+bwP)./2;
        
        patch([wn fliplr(wn) wn(1)], [spec-P fliplr(spec+P) spec(1)-P(1)],colors(colorCounter,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        uistack(h,'top');
    else    
        h = plot(wn,fwSpect,'color',colors(colorCounter,:));
        hold on
        plot(wn,bwSpect,'color',colors(colorCounter+1,:));

        patch([wn fliplr(wn) wn(1)], [fwSpect-fwP fliplr(fwSpect+fwP) fwSpect(1)-fwP(1)],colors(colorCounter,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        patch([wn fliplr(wn) wn(1)], [bwSpect-bwP fliplr(bwSpect+bwP) bwSpect(1)-bwP(1)],colors(colorCounter+1,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        uistack(h,'top');
        hold off
        colorCounter = colorCounter+1;
    end
    
    ylabel '\phi_n - {\phi_n}^{ref} [rad]'
else
    if get(handles.checkboxComplexConj,'value')
        if get(handles.checkboxAvgForwBackw,'value')
            plot(wn,angle(mean(complexConjugateAvg(fwSample,2))+mean(complexConjugateAvg(bwSample,2))),wn,angle(mean(complexConjugateAvg(fwRef,2))+mean(complexConjugateAvg(bwRef,2))))
        else
            plot(wn,angle(mean(complexConjugateAvg(fwSample,2))),wn,angle(mean(complexConjugateAvg(fwRef,2))),wn,angle(mean(complexConjugateAvg(bwSample,2))),wn,angle(mean(complexConjugateAvg(bwRef,2))))
        end
    else
        if get(handles.checkboxAvgForwBackw,'value')
            plot(wn,angle(mean(fwSample)+mean(bwSample)),wn,angle(mean(fwRef)+mean(bwRef)))
        else
            plot(wn,angle(mean(fwSample)),wn,angle(mean(fwRef)),wn,angle(mean(bwSample)),wn,angle(mean(bwRef)))
        end
    end
    
    ylabel '\phi_n [rad]'
end

xlabel 'Wavenumber [cm^{-1}]'
set(gca,'XDir','rev')
xlim([1100 2100]);

% --- Executes on button press in pushbuttonLoadSample.
function pushbuttonLoadSample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Global variable home is defined in evalSpectraJPK_OpeningFcn. This holds
%the default home directory to start in the uigetfile dialog.
global home

[filename,path]  = uigetfile([home '/*.*'],'Multiselect','on');

%Stop if dialog was cancled.
if path == 0
    return
end

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

%Get File type
isBinary = get(handles.checkboxLoadBinary,'value');

%Which harmonic to load
harm = str2double(get(handles.editHarmonic,'string'));

if iscell(filename)
    for i = 1:size(filename,2)
        %Load complex forward and backward interferograms.
        if isBinary
            data = readLabviewData([path filename{i}],4,'double',true);
            

            IFfw = reshape(data(harm,1,:,:),[size(data,3) size(data,4)]);
            IFbw = reshape(data(harm,2,:,:),[size(data,3) size(data,4)]);

            %Execute Zerofilling, alignment, Phasecorrection and FFT
            [fwSample,~] = JPKFFT(IFfw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);
            [bwSample,wn] = JPKFFT(IFbw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);

            handles.fwSample = fwSample;
            handles.bwSample = bwSample;
            handles.IFfwSample = IFfw;
            handles.IFbwSample = IFbw;
            handles.wn = wn;
            
            guidata(hObject, handles);
            
            %Check if filename is a valid variable name
            if ~isvarname(filename{i})
                name = [matlab.lang.makeValidName(filename{i}) '_harm' num2str(harm)];
            else
                name = [filename{i} '_harm' num2str(harm)];
            end

            %Save to Workspace if more than one file loaded
            [hObject,handles] = saveSpectrumToWS(hObject,eventdata,handles,name);

        else
            [IFfw, IFbw] = loadJPKspectra([path filename{i}]);

            %Execute Zerofilling, alignment, Phasecorrection and FFT
            [fwSample,~] = JPKFFT(IFfw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);
            [bwSample,wn] = JPKFFT(IFbw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);

            handles.fwSample = fwSample;
            handles.bwSample = bwSample;
            handles.IFfwSample = IFfw;
            handles.IFbwSample = IFbw;
            handles.wn = wn;
            
            guidata(hObject, handles);
            
            %Check if filename is a valid variable name
            if ~isvarname(filename{i})
                name = matlab.lang.makeValidName(filename{i});
            else
                name = filename{i};
            end

            %Save to Workspace if more than one file loaded
            [hObject,handles] = saveSpectrumToWS(hObject,eventdata,handles,name);
        end
    end
else
    %Load complex forward and backward interferograms.
    if isBinary
        data = readLabviewData([path filename],4,'double',true);
        IFfw = reshape(data(harm,1,:,:),[size(data,3) size(data,4)]);
        IFbw = reshape(data(harm,2,:,:),[size(data,3) size(data,4)]);
    else
        [IFfw, IFbw] = loadJPKspectra([path filename]);
    end

    %Execute Zerofilling, alignment, Phasecorrection and FFT
    [fwSample,~] = JPKFFT(IFfw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);
    [bwSample,wn] = JPKFFT(IFbw,n,zerofilling,0.3,checkAlignment,mode,phaseCorrection);
    
    handles.fwSample = fwSample;
    handles.bwSample = bwSample;
    handles.IFfwSample = IFfw;
    handles.IFbwSample = IFbw;
    handles.wn = wn;
            
    guidata(hObject, handles);
            
    if ~isvarname(filename)
        name = matlab.lang.makeValidName(filename);
    else
        name = filename;
    end
            
    [hObject,handles] = saveSpectrumToWS(hObject,eventdata,handles,name);
    
    guidata(hObject, handles);
end
    

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

global colorCounter
colors = lines(64);

if get(handles.checkboxAppend,'value')
    figure(2);
    hold on
    colorCounter = colorCounter+1;
else
    figure(2);
    colorCounter = 1;
end

idx = get(handles.listbox2,'value');

wn = handles.data(idx).wn;
fwSample = handles.data(idx).fwSample;
bwSample = handles.data(idx).bwSample;
fwRef = handles.data(idx).fwRef;
bwRef = handles.data(idx).bwRef;

if get(handles.checkboxReferencePlot,'value')
    if get(handles.checkboxComplexConj,'value')
        fwSpect = imag(mean(complexConjugateAvg(fwSample,2))./mean(complexConjugateAvg(fwRef,2)));
        bwSpect = imag(mean(complexConjugateAvg(bwSample,2))./mean(complexConjugateAvg(bwRef,2)));
            
        [fwI,~,~] = calcStdDev(complexConjugateAvg(fwSample,2),complexConjugateAvg(fwRef,2));
        [bwI,~,~] = calcStdDev(complexConjugateAvg(bwSample,2),complexConjugateAvg(bwRef,2));
    else
        fwSpect = imag(mean(fwSample)./mean(fwRef));
        bwSpect = imag(mean(bwSample)./mean(bwRef));
    
        [fwI,~,~] = calcStdDev(fwSample,fwRef);
        [bwI,~,~] = calcStdDev(bwSample,bwRef);
    end
    
    if get(handles.checkboxAvgForwBackw,'value')
        S = (fwSpect+bwSpect)./2;
        h = plot(wn,S,'color',colors(colorCounter,:));
        I = imag((fwI+bwI)./2);
        patch([wn fliplr(wn) wn(1)], [S-I fliplr(S+I) S(1)-I(1)],colors(colorCounter,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        uistack(h,'top');
    else
        h = plot(wn,fwSpect,'color',colors(colorCounter,:));
        hold on
        plot(wn,bwSpect,'color',colors(colorCounter+1,:));
        fwI = imag(fwI);
        bwI = imag(bwI);
        patch([wn fliplr(wn) wn(1)], [fwSpect-fwI fliplr(fwSpect+fwI) fwSpect(1)-fwI(1)],colors(colorCounter,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        patch([wn fliplr(wn) wn(1)], [bwSpect-bwI fliplr(bwSpect+bwI) bwSpect(1)-bwI(1)],colors(colorCounter+1,:),'EdgeColor','none','FaceAlpha',0.1,'HandleVisibility','off')
        uistack(h,'top');
        hold off
        colorCounter = colorCounter+1;
    end
    
    ylabel 'Im(s_n/{s_n}^{ref})'
    
else
    if get(handles.checkboxComplexConj,'value')
        if get(handles.checkboxAvgForwBackw,'value')
            plot(wn,imag((mean(complexConjugateAvg(fwSample,2))+mean(complexConjugateAvg(bwSample,2)))./2),wn,imag((mean(complexConjugateAvg(fwRef,2))+mean(complexConjugateAvg(bwRef,2)))./2))
        else
            plot(wn,imag(mean(complexConjugateAvg(fwSample,2))),wn,imag(mean(complexConjugateAvg(fwRef,2))),wn,imag(mean(complexConjugateAvg(bwSample,2))),wn,imag(mean(complexConjugateAvg(bwRef,2))))
        end
    else
        if get(handles.checkboxAvgForwBackw,'value')
            plot(wn,imag((mean(fwSample)+mean(bwSample))./2),wn,imag((mean(fwRef)+mean(bwRef))./2))
        else
            plot(wn,imag(mean(fwSample)),wn,imag(mean(fwRef)),wn,imag(mean(bwSample)),wn,imag(mean(bwRef)))
        end
    end
    
    ylabel 'Im(s_n) [V]'
end

xlabel 'Wavenumber [cm^{-1}]'
set(gca,'XDir','rev')
xlim([1100 2100]);



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

    name = char(get(handles.editSpectrumName,'String'));
    saveSpectrumToWS(hObject,eventdata,handles,name);
    

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



function editHarmonic_Callback(hObject, eventdata, handles)
% hObject    handle to editHarmonic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHarmonic as text
%        str2double(get(hObject,'String')) returns contents of editHarmonic as a double


% --- Executes during object creation, after setting all properties.
function editHarmonic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHarmonic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxLoadBinary.
function checkboxLoadBinary_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxLoadBinary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxLoadBinary


% --- Executes on button press in checkboxAvgForwBackw.
function checkboxAvgForwBackw_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAvgForwBackw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAvgForwBackw


% --- Executes on button press in checkboxAppend.
function checkboxAppend_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAppend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global colorCounter
colorCounter = 0;
% Hint: get(hObject,'Value') returns toggle state of checkboxAppend
