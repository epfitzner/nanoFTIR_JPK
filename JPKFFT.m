function [FFT,wn,IF] = JPKFFT(IF_, L, zerofilling, cutoff, checkAlignment, mode, phaseCorrection)  
    
%Create placeholder for IF
    IF = zeros(size(IF_,1),L);
    IFPC = zeros(size(IF_,1),L);
    
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
    
%Calculate the mean of the prealigned IFs and calculate the
%crosscorrelation to that averaged IF
    IFMean = mean(IF_);
    
    for i = 1:size(IF_,1)  
        C = crossCorrelation((IF_(i,round(size(IF_,2)*cutoff):round(size(IF_(1,:),2)*(1-cutoff)))),(IFMean(round(size(IF_,2)*cutoff):round(size(IF_(1,:),2)*(1-cutoff)))));
        [~, maxIdxC] = max(real(C));
        
        maxIdxC = maxIdxC-(size(C,2)+1)/2;
%Shift individual interferograms according the cross correlation such that
%all interferograms overlay
        IF_(i,:) = circshift(IF_(i,:),[0 -maxIdxC]);
    end
    
    
    %Decide for Apodization type

    pcLength = 12;

    PC = 1;

    switch PC

        case 1
        %Blackman-Harris apodization
        w = blackmanharrisApodization(L,4);

        %Phasecorrection
        wPC = blackmanharrisApodization(pcLength,4);
        wPC = [zeros(1,L/2-pcLength/2) wPC zeros(1,L/2-pcLength/2)];

        case 2
        %Triangle apodization
        w = [linspace(0,1,L/2) linspace(1,0,L/2)];

        %Phasecorrection
        wPC = [linspace(0,1,pcLength/2) linspace(1,0,pcLength/2)];
        wPC = [zeros(1,L-pcLength/2) wPC zeros(1,L-pcLength/2)];
    end     

    %Find centerburst of aligned spectra
    [~, maxIdx] = max(real(mean(IF_)));
    
    %Cut Interferograms 
    IF = IF_(:,maxIdx-L/2:maxIdx+L/2-1);
    
    IF = IF.*(ones(size(IF,1),1)*w);
    IFPC = IF.*(ones(size(IF,1),1)*wPC);
      
%Shift Interferogram maximum to first point in array
    IF = circshift(IF,-(round(L/2))+1,2);
    IFPC = circshift(IFPC,-(round(L/2))+1,2);   
    
%FFT
    FFT = fft(IF,[],2);   
    FFTPC = fft(IFPC,[],2);
    
%Do Phasecorrection    
    if phaseCorrection
        FFT = FFT./(FFTPC./abs(FFTPC));
        FFTPC = FFTPC./(FFTPC./abs(FFTPC));
        
        IF = ifft(FFT,[],2);
        IFPC = ifft(FFTPC,[],2);       
    end

%Process asymmetric interferogram
%Strength of asymmetric Apodization
    asymFactor = 128;
    
    wAsym = ones(size(IF));
    apo = ones(size(IF,1),1)*[zeros(1,L/2-asymFactor) blackmanharrisApodization(2*asymFactor,4) zeros(1,L/2-asymFactor)];
    apo = fftshift(apo,2);

    w = fftshift(w);
    
    switch mode
        case 2
            wAsym(:,L/2+1:end) = apo(:,L/2+1:end)./(ones(size(IF,1),1)*w(L/2+1:end));
            IF = IF.*wAsym;
        case 3
            wAsym(:,1:L/2) = apo(:,1:L/2)./(ones(size(IF,1),1)*w(1:L/2));
            IF = IF.*wAsym;
    end

%Zerofilling Interferogram
    IF = [IF(:,1:L/2) zeros(size(IF,1),L*(zerofilling-1)) IF(:,L/2+1:end)];
    IFPC = [IFPC(:,1:L/2) zeros(size(IFPC,1),L*(zerofilling-1)) IFPC(:,L/2+1:end)];
    
%Do final FFT   
    FFT = fft(IF,[],2);

    
%Check alignement of spectra manually
    if checkAlignment
        scrsz = get(groot,'ScreenSize');
        figure('Position',[scrsz(3)/4 scrsz(3)/4 scrsz(3)*2/4 scrsz(4)*3/4]);
        
        subplot(2,1,1)
        plot(real(fftshift(IF,2)'))
        xlim([L*zerofilling/2*0.975 L*zerofilling/2*1.025]);
        
        subplot(2,1,2)
        imagesc(real(fftshift(IF,2)))
        xlim([L*zerofilling/2*0.975 L*zerofilling/2*1.025]);
    end

%Calculate the wavenumber array by assuming the points are spearated by
%HeNe fringes
    wn = linspace(0,1/(632.816e-9*100),L*zerofilling);

end