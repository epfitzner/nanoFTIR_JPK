function saveSpectrumToWS( hObject, eventdata, handles , name)
%SAVESPECTRUMTOWS Summary of this function goes here
%   Detailed explanation goes here
    spectrum.wn = handles.wn;
    spectrum.forwardSample = handles.fwSample;
    spectrum.forwardRef = handles.fwRef;
    spectrum.backwardSample = handles.bwSample;
    spectrum.backwardRef = handles.bwRef;
    spectrum.forwardSampleStdDev = calcStdDev(handles.fwSample);
    spectrum.forwardRefStdDev = calcStdDev(handles.fwRef);
    spectrum.backwardSampleStdDev = calcStdDev(handles.bwSample);
    spectrum.backwardRefStdDev = calcStdDev(handles.bwRef);
    
    assignin('base',name,spectrum);

    guidata(hObject, handles);

end

