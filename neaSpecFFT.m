function [FFT] = neaSpecFFT(ampIF, phiIF, length, zerofilling, phaseCorrection)
    IF = ampIF(:,1:length).*exp(-1i*phiIF(:,1:length));
        
    offset = zeros(1,size(IF,1));

%Average Interferograms
    averageInterferograms = false;
    
    if averageInterferograms
        IF = mean(IF,1);
    end
    
    for i = 1:size(IF,1)
        IF(i,:) = IF(i,:) - mean(IF(i,:),2);            
        
%Find centerburst 
        [~, maxIdx(i)] = max(abs(IF(i,:)));

        N = size(IF,2);
        n = linspace(0,N-1,N);

%Apodization: 4-term Blackman-Harris (a_0=0.35875, a_1=0.48829, a_2=0.14128, a_3=0.01168)
        
        a_0=0.35875; 
        a_1=0.48829; 
        a_2=0.14128; 
        a_3=0.01168;

        if true
            w = a_0 - a_1*cos(2*pi*n/(N-1)) + a_2*cos(4*pi*n/(N-1)) - a_3*cos(6*pi*n/(N-1));
        else
            w = [linspace(0,1,maxIdx) linspace(1,0,length-maxIdx)];
        end
        
        IF(i,:) = IF(i,:).*w;
        
    end

%Zerofilling Interferogram
    IF = [IF zeros(size(IF,1),N*(zerofilling-1))];
    
%Shift Interferogram
    for i = 1:size(IF,1)

        if false
            IF(i,:) = circshift(IF(i,:),round(length*(zerofilling-1)/2)-(length/2-maxIdx(i)),2);
        else
            IF(i,:) = circshift(IF(i,:),maxIdx(i)+1,2);
        end 
    end

%FFT
    FFT = fft(IF,[],2);   

    
%Average Spectra
    FFT = mean(FFT,1);

end