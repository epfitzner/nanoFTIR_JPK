function [sample,ref,wn] = loadSpectra(sampleDir,refDir, n,zerofilling, singelSided, length)
    directory = sampleDir;
    pos = strfind(directory, '/');
    name = directory(pos(size(pos,2)):size(directory,2));
    ampIF = importdata([directory name '_O' num2str(n) '-F-abs.ascii']);
    phiIF = importdata([directory name '_O' num2str(n) '-F-arg.ascii']);
    parameters = importdata([directory name '.parameters.txt']);
    
    length = parameters.data(6);
    mirrorMax = parameters.data(3);
    
    %if frequency axis exists in folder, take that. In case it does not
    %exist, create wavenumber axis from the parameter file.

    [sample, IFSample, wn] = neaSpecFFTAsymm(ampIF,phiIF,length,mirrorMax,zerofilling,singelSided);
    
    directory = refDir;
    pos = strfind(directory, '/');
    nameRef = directory(pos(size(pos,2)):size(directory,2));
    ampIFRef = importdata([directory nameRef '_O' num2str(n) '-F-abs.ascii']);
    phiIFRef = importdata([directory nameRef '_O' num2str(n) '-F-arg.ascii']);
    
    [ref, IFRef] = neaSpecFFTAsymm(ampIFRef,phiIFRef,length,mirrorMax,zerofilling,singelSided);
    
    assignin('base','ampIF',ampIF);
    assignin('base','phiIF',phiIF);
    assignin('base','ampIFRef',ampIFRef);
    assignin('base','phiIFRef',phiIFRef);
    assignin('base','sample',sample);
    assignin('base','ref',ref);
    assignin('base','wn',wn);
    assignin('base','IFSample',IFSample);
    assignin('base','IFRef',IFRef);
    
    
end