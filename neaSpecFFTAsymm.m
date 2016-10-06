function [FFT, IF, wn] = neaSpecFFTAsymm(ampIF, phiIF, length, mirrorMax, zerofilling,singleSided)
    IF = ampIF(:,1:length).*exp(-1i*phiIF(:,1:length));
        

%Average Interferograms
    averageInterferograms = true;
    
    if averageInterferograms
        IF = mean(IF,1);
    end
    
    %Shift Interferogram

%Calculate the maximum of the avegare interferogram

    avgIF = mean(IF,1);
    [~, maxIdxMean] = max(avgIF);

    for i = 1:size(IF,1)
        %Calculate the offset of the individual interferograms of the
        %average interferogram by crosscorrelation
        C = crossCorrelation(IF(i,:),avgIF);
        [~, maxIdxC] = max(C);
        maxIdxC = maxIdxC-(size(C,2)+1)/2;
        IF(i,:) = circshift(IF(i,:),-maxIdxC,2);       
        
%Substract mean value from each interferogram
        IF(i,:) = IF(i,:) - mean(IF(i,:),2);            
        
%Phasecorrection for single sided interferograms
        if singleSided
            pc(i,:) = IF(i,2*maxIdxMean-size(IF,2):size(IF,2));
            w = linspace(0,1,round(size(pc,2)/2));
            w = [w fliplr(w(1:size(w,2)-1))];
            pc(i,:) = pc(i,:).*w;
            temp = -round(size(pc,2)/2)+1;
        end
        
%Apodization: 4-term Blackman-Harris (a_0=0.35875, a_1=0.48829, a_2=0.14128, a_3=0.01168)
        
        a_0=0.35875; 
        a_1=0.48829; 
        a_2=0.14128; 
        a_3=0.01168;

        if singleSided
            IFSS(i,:) = [IF(i,1:maxIdxMean) fliplr(IF(i,1:maxIdxMean-1))];
            n = 0:2*maxIdxMean-2;
            N = 2*maxIdxMean-1;
            w = a_0 - a_1*cos(2*pi*n/(N-1)) + a_2*cos(4*pi*n/(N-1)) - a_3*cos(6*pi*n/(N-1)); 
            IFSS(i,:) = w.*IFSS(i,:);
        else
            if maxIdxMean<length/2
                n = 0:2*maxIdxMean-1;
                N = 2*maxIdxMean;
                w = a_0 - a_1*cos(2*pi*n/(N-1)) + a_2*cos(4*pi*n/(N-1)) - a_3*cos(6*pi*n/(N-1));
                w = [w zeros(1,length-2*maxIdxMean)];
                %IF(i,2*maxIdxMean+1:length) = 0;
            else
                n = 0:2*(length-maxIdxMean)-1;
                N = 2*(length-maxIdxMean);
                w = a_0 - a_1*cos(2*pi*n/(N-1)) + a_2*cos(4*pi*n/(N-1)) - a_3*cos(6*pi*n/(N-1));
                w = [zeros(1,2*maxIdxMean-length) w];
                %IF(i,1:2*maxIdxMean-length) = 0;
            end
            w = [linspace(0,1,maxIdxMean) linspace(1,0,length-maxIdxMean)];
            IF(i,:) = w.*IF(i,:);
        end        
    end
    
%Zerofilling Interferogram
    if singleSided
        pc = [pc zeros(size(pc,1),length*zerofilling*2-size(pc,2))];
        pc = circshift(pc,temp-2,2);
        pc = fft(pc,[],2);
        pc = cos(angle(pc))+1i*sin(angle(pc));
        pc = pc.*abs(pc);
        
        IFSS = [IFSS zeros(size(IFSS,1),2^nextpow2(size(IFSS,2))-size(IFSS,2)+2^nextpow2(size(IFSS,2))*(zerofilling-1))];

%Put Maximum in 0
        IFSS = circshift(IFSS,-maxIdxMean+1,2);
    
        
%FFT
        FFT = fft(IFSS,[],2);
        
        if false
            hold on
            FFT = FFT.*pc;           
        end
        
        clear IF;
        IF = IFSS;
    else              
        IF = [IF zeros(size(IF,1),length*(zerofilling-1))];

%Put Maximum in 0
        IF = circshift(IF,-maxIdxMean+1-4,2);
        

%FFT
        FFT = fft(IF,[],2);
    end
     
%Average Spectra
    FFT = mean(FFT,1);

%Create wavenumber vector
    if singleSided
        mirrorMax = mirrorMax*maxIdxMean/(length*2);
    else
        if maxIdxMean<length/2
            mirrorMax = mirrorMax*maxIdxMean/length;
        else
            mirrorMax = mirrorMax*(length-maxIdxMean)/length;
        end
    end
    wn = linspace(0,1/(mirrorMax*0.0000001*2),size(FFT,2));
end