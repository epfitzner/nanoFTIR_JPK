function [stdDevComplex, stdDevAbs, stdDevAngle] = calcStdDev(sample,ref)
        
    if nargin == 1
       ref = zeros(size(sample)); 
    end
    rangeRef = abs(ref) > max(abs(ref),[],2)*ones(1,size(ref,2))*0.1;
    rangeSpectrum = abs(sample) > max(abs(sample),[],2)*ones(1,size(sample,2))*0.1;
    
    for i = 1:size(rangeRef,1)
      phaseOffsetRef(i) = mean(angle(ref(i,rangeRef(i,:))),2);
    end
    
    for i = 1:size(rangeSpectrum,1)
        phaseOffsetSpectrum(i) = mean(angle(sample(i,rangeSpectrum(i,:))),2);
    end
    
    ref = ref.*(exp(-1i.*phaseOffsetRef'*ones(1,size(ref,2))));
    sample = sample.*(exp(-1i.*phaseOffsetSpectrum'*ones(1,size(sample,2))));
    
    
    %Calculate the quantile for 95% confidence and the present number of
    %individual spectra
    
    [status,~] = license('checkout','Statistics_Toolbox');
    
    if status
        t = tinv(0.975,size(sample,1));
    else
        warning('Statistics Toolbox license not available. t approximated as 2.');
        t = 2;
    end
        
    if nargin == 1
        stdDevComplex = t*sqrt(1/size(sample,1))*(std(real(sample),1)+1i*std(imag(sample),1));
        stdDevAbs = abs(stdDevComplex);
        stdDevAngle = 0;
        
        return
    end
    
    stdDev = t*sqrt(1/size(sample,1))*(std(real(sample),1)+1i*std(imag(sample),1));
    stdDevRef = t*sqrt(1/size(ref,1))*(std(real(ref),1)+1i*std(imag(ref),1));

    sample = mean(sample,1);
    ref = mean(ref,1);
    spectrum = sample./ref;
    
    dRedxR = (real(sample).*abs(ref).^2-2.*real(ref).*(real(sample).*real(ref)+imag(sample).*imag(ref)))./abs(ref).^4;
    dRedxS = real(ref)./abs(ref).^2;
    dRedyR = (imag(sample).*abs(ref).^2-2.*imag(ref).*(real(sample).*real(ref)+imag(sample).*imag(ref)))./abs(ref).^4;
    dRedyS = imag(ref)./abs(ref).^2;
    dImdxR = (imag(sample).*abs(ref).^2-2.*real(ref).*(imag(sample).*real(ref)-imag(ref).*real(sample)))./abs(ref).^4;
    dImdxS = -imag(ref)./abs(ref).^2;
    dImdyR = (-real(sample).*abs(ref).^2-2.*imag(ref).*(imag(sample).*real(ref)-imag(ref).*real(sample)))./abs(ref).^4;
    dImdyS = real(ref)./abs(ref).^2;
    
    stdDevComplex = sqrt((dRedxR.*real(stdDevRef)).^2+(dRedxS.*real(stdDev)).^2+(dRedyR.*imag(stdDevRef)).^2+(dRedyS.*imag(stdDev)).^2) + ...
                1i.*sqrt((dImdxR.*real(stdDevRef)).^2+(dImdxS.*real(stdDev)).^2+(dImdyR.*imag(stdDevRef)).^2+(dImdyS.*imag(stdDev)).^2);
    
    stdDevAbs = 1./(abs(spectrum)).*sqrt(((real(spectrum).*dRedxR+imag(spectrum).*dImdxR).*real(stdDevRef)).^2 + ...
                                        ((real(spectrum).*dRedxS+imag(spectrum).*dImdxS).*real(stdDev)).^2 + ...
                                        ((real(spectrum).*dRedyR+imag(spectrum).*dImdyR).*imag(stdDevRef)).^2 + ...
                                        ((real(spectrum).*dRedyS+imag(spectrum).*dImdyS).*imag(stdDev)).^2);
    
    stdDevAngle = 1./abs(spectrum).^2.*sqrt(((dImdxR.*real(spectrum)-dRedxR.*imag(spectrum)).*real(stdDevRef)).^2 + ...
                                           ((dImdxS.*real(spectrum)-dRedxS.*imag(spectrum)).*real(stdDev)).^2 + ...
                                           ((dImdyR.*real(spectrum)-dRedyR.*imag(spectrum)).*imag(stdDevRef)).^2 + ...
                                           ((dImdyS.*real(spectrum)-dRedyS.*imag(spectrum)).*imag(stdDev)).^2);
                                       
    %probiere: einzelne Phasenspektren errechenen und davon dann Std/sqrt(n).
end