function [FFT,wn,IF] = JPKFFT(IF_, length, zerofilling, cutoff, checkAlignment, mode, phaseCorrection)  

%Average Interferograms
    averageInterferograms = false;
    
    if averageInterferograms
        IF_ = mean(IF_,1);
    end
    
%Create placeholder for IF
    IF = zeros(size(IF_,1),length);
    IFPC = zeros(size(IF_,1),length);
    
    for i = 1:size(IF_,1)        
%Substract offset from each interferogram
        IF_(i,:) = IF_(i,:)-mean(IF_(i,:));
        
%Calculate the offset of the individual interferograms with cross
%correlating them to the first interferogram
        ref = 1;
        
        C = crossCorrelation((IF_(i,round(size(IF_,2)*cutoff):round(size(IF_(1,:),2)*(1-cutoff)))),(IF_(ref,round(size(IF_,2)*cutoff):round(size(IF_(1,:),2)*(1-cutoff)))));
        [~, maxIdxC] = max(real(C));
        
        maxIdxC = maxIdxC-(size(C,2)+1)/2;
%Shift individual interferograms according the cross correlation such that
%all interferograms overlay
        IF_(i,:) = circshift(IF_(i,:),-maxIdxC,2);

    end
    

%Find Maximum of the alligned averaged interferogram in a window
%cutoff:1-cutoff
    IFavg = (abs(mean(IF_,1)));

    if true
        %Find center burst from regular maximum searching
        [~, maxIdx] = max(abs(IFavg(round(size(IFavg,2)*cutoff):round(size(IFavg(1,:),2)*(1-cutoff)))-mean(IFavg)));
        maxIdx = maxIdx(1,1)+round(size(IFavg,2)*cutoff);
    else
        %Find center burst from shifting a 4-term BMH apodization across
        %the average interferogram
        maxIdx = optimizeOffsetToBMHApodiziation(IFavg,cutoff)+round(size(IFavg,2)*cutoff);
    end

    
    for i = 1:size(IF_,1)
%Cut Interferograms 
        IF(i,:) = IF_(i,maxIdx-length/2:maxIdx+length/2-1);
        
        %Decide for Apodization type
    
        if true
            %Blackman-Harris apodization
            w = blackmanharrisApodization(length,4);
            
            %Phasecorrection
            wPC = blackmanharrisApodization(length/16,4);
            wPC = [zeros(1,length*15/32) wPC zeros(1,length*15/32)];
        else
            %Triangle apodization
            w = [linspace(0,1,length/2) linspace(1,0,length/2)];%ones(1,length);
            
            %Phasecorrection
            wPC = [linspace(0,1,length/64) linspace(1,0,length/64)];
            wPC = [zeros(1,length*31/64) wPC zeros(1,length*31/64)];
        end
        
        IF(i,:) = IF(i,:).*w;   
        
        IFPC(i,:) = IF(i,:).*wPC;
    end
    
    
%Zerofilling Interferogram
    IF = [IF zeros(size(IF,1),length*(zerofilling-1))];
    IFPC = [IFPC zeros(size(IFPC,1),length*(zerofilling-1))];
    
    
%Shift Interferogram maximum to first point in array
    IF = circshift(IF,-(round(length/2))+1,2);
    IFPC = circshift(IFPC,-(round(length/2))+1,2);   

%FFT
    FFT = fft(IF,[],2);   
    FFTPC = fft(IFPC,[],2);

%Do Phasecorrection    
    if phaseCorrection
        FFT = FFT./(FFTPC./abs(FFTPC));
        
%Fill either nothing, right side or left side with zeros. I.e. selecting
%both, reference side or sample side.
        IF = ifft(FFT,[],2);
        IFPC = ifft(FFTPC,[],2);
        
        switch mode
            case 2
                %IF(:,end-length+1:end) = zeros(size(IF,1),length);
                IF(:,end-length+2:end) = fliplr(IFPC(:,2:length));
            case 3
                %IF(:,1:length) = zeros(size(IF,1),length);
                IF(:,2:length) = fliplr(IFPC(:,end-length+2:end));
        end
        FFT = fft(IF,[],2);
    end

    %Check alignement of spectra optically
    if checkAlignment
        scrsz = get(groot,'ScreenSize');
        figure('Position',[scrsz(3)/4 scrsz(3)/4 scrsz(3)*2/4 scrsz(4)*3/4]);
        
        subplot(2,1,1)
        plot(real(fftshift(IF,2)'))
        xlim([length*zerofilling/2*0.975 length*zerofilling/2*1.025]);
        
        subplot(2,1,2)
        imagesc(real(fftshift(IF,2)))
        xlim([length*zerofilling/2*0.975 length*zerofilling/2*1.025]);
    end

%Calculate the wavenumber array by assuming the points are spearated by
%HeNe fringes
    wn = linspace(0,1/(632.8e-9*100),length*zerofilling);

    disp(['Nominal resolution: ' num2str(abs(wn(2)-wn(1))*zerofilling) ' 1/cm']);
%Average Spectra
    %FFT = mean(FFT,1);
end