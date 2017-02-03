function [stdDevComplex, stdDevAngle] = calcStdDev(spectrum,ref)
        
    if nargin == 1
       ref = zeros(size(spectrum)); 
    end
    rangeRef = abs(ref) > max(abs(ref),[],2)*ones(1,size(ref,2))*0.1;
    rangeSpectrum = abs(spectrum) > max(abs(spectrum),[],2)*ones(1,size(spectrum,2))*0.1;
    
    for i = 1:size(rangeRef,1)
      phaseOffsetRef(i) = mean(angle(ref(i,rangeRef(i,:))),2);
    end
    
    for i = 1:size(rangeSpectrum,1)
        phaseOffsetSpectrum(i) = mean(angle(spectrum(i,rangeSpectrum(i,:))),2);
    end
    
    ref = ref.*(exp(-1i.*phaseOffsetRef'*ones(1,size(ref,2))));
    spectrum = spectrum.*(exp(-1i.*phaseOffsetSpectrum'*ones(1,size(spectrum,2))));
    
    if nargin == 1
        stdDevComplex = sqrt(1/size(spectrum,1))*std(spectrum,1);
        stdDevAngle = 0;
        
        return
    end
    
    stdDev = sqrt(1/size(spectrum,1))*std(spectrum,1);
    stdDevRef = sqrt(1/size(ref,1))*std(ref,1);

    spectrum = mean(spectrum,1);
    ref = mean(ref,1);
    
    stdDevComplex = sqrt((stdDev./ref).^2 + (stdDevRef.*spectrum./ref.^2).^2);
    
    x = spectrum./ref;
    stdDevAngle = 1./(1+(real(x)./imag(x)).^2).*sqrt((real(stdDevComplex)./imag(x)).^2 + (imag(stdDevComplex).*real(x)./imag(x).^2).^2);
    
    
    %probiere: einzelne Phasenspektren errechenen und davon dann Std/sqrt(n).
end