function [hObject,handles] = saveSpectrumToWS( hObject, eventdata, handles , name)
%SAVESPECTRUMTOWS Summary of this function goes here
%   Detailed explanation goes here
    data.name = name;
    data.wn = handles.wn;
    data.fwSample = handles.fwSample;
    data.fwRef = handles.fwRef;
    data.bwSample = handles.bwSample;
    data.bwRef = handles.bwRef; 
    data.IFfwSample = handles.IFfwSample;
    data.IFfwRef = handles.IFfwRef;
    data.IFbwSample = handles.IFbwSample;
    data.IFbwRef = handles.IFbwRef; 
    
    
    assignin('base',name,data);
    
%set the item to the listbox
    nameList = cell(1);
    
    if ~isfield(handles,'data')
        handles.data = data;
        set(handles.listbox2,'string',data.name);
    else
        handles.data = [handles.data data];
    
        list = get(handles.listbox2,'string');
        list = [list ; cellstr(name)];
        set(handles.listbox2,'string',list)
    end
    
    assignin('base','data',handles.data);
end