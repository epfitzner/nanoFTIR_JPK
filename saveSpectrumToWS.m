function saveSpectrumToWS( hObject, eventdata, handles , name)
%SAVESPECTRUMTOWS Summary of this function goes here
%   Detailed explanation goes here
    spectrum.wn = handles.wn;
    spectrum.forwardSample = handles.fwSample;
    spectrum.forwardRef = handles.fwRef;
    spectrum.backwardSample = handles.bwSample;
    spectrum.backwardRef = handles.bwRef;
    
    assignin('base',name,spectrum);

    guidata(hObject, handles);

end

