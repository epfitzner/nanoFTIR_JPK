function [stdDevComplex, stdDevAngle] = calcStdDev(spectrum,ref)

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
end