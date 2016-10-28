function [FFT,wn] = JPKFFT(IF_, length, zerofilling, cutoff)  

%Average Interferograms
    averageInterferograms = false;
    
    if averageInterferograms
        IF_ = mean(IF,1);
    end
%Flip interferograms such that positive x axis means less OPD (where the reference puls laggs the tip puls behind)    
    IF_ = fliplr(IF_);
    
%Create placeholder for IF
    IF = zeros(size(IF_,1),length);
    
    for i = 1:size(IF_,1)        
%Substract offset from each interferogram
        IF_(i,:) = IF_(i,:)-mean(IF_(i,:));
        
%Calculate the offset of the individual interferograms with cross
%correlating them to the first interferogram
        C = crossCorrelation((IF_(i,:)),(IF_(1,:)));
        [~, maxIdxC] = max(C);
        maxIdxC = maxIdxC-(size(C,2)+1)/2;
%Shift individual interferograms according the cross correlation such that
%all interferograms overlay
        IF_(i,:) = circshift(IF_(i,:),-maxIdxC,2);
    end

%Find Maximum of the alligned averaged interferogram in a window
%cutoff:1-cutoff
    IFavg = (abs(mean(IF_,1)));
    [~, maxIdx] = max(abs(IFavg(round(size(IFavg,2)*cutoff):round(size(IFavg(1,:),2)*(1-cutoff)))-mean(IFavg)));
    
    maxIdx = maxIdx(1,1)+round(size(IFavg,2)*cutoff);
    
    for i = 1:size(IF_,1)
%Cut Interferograms 
        IF(i,:) = IF_(i,maxIdx-length/2:maxIdx+length/2-1);

        N = length;
        n = linspace(0,N-1,N);

%Apodization: 4-term Blackman-Harris (a_0=0.35875, a_1=0.48829, a_2=0.14128, a_3=0.01168)
        
        a_0=0.35875; 
        a_1=0.48829; 
        a_2=0.14128; 
        a_3=0.01168;

        if true
            %Blackman-Harris apodization
            w = a_0 - a_1*cos(2*pi*n/(N-1)) + a_2*cos(4*pi*n/(N-1)) - a_3*cos(6*pi*n/(N-1));
        else
            %Triangle apodization
            w = [linspace(0,1,length/2) linspace(1,0,length/2)];
        end
        
        IF(i,:) = IF(i,:).*w;
    end
    
%Zerofilling Interferogram
    IF = [IF zeros(size(IF,1),N*(zerofilling-1))];
    
%Check alignement of spectra
    figure
    plot(abs(IF'))  
    
%Shift Interferogram maximum to first point in array 
    IF = circshift(IF,round(-length/2)+1,2);
     
%FFT
    FFT = fft(IF,[],2);   

%Calculate the wavenumber array by assuming the points are spearated by
%HeNe fringes
    wn = linspace(0,1/(632.8e-9*100),length*zerofilling);
    
    sprintf(['Nominal resolution: ' num2str(abs(wn(2)-wn(1))*zerofilling) ' 1/cm']);
%Average Spectra
    %FFT = mean(FFT,1);
end