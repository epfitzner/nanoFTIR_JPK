function C = crossCorrelation(A,B)
%   Calculate the cross correlation of the maps A and B.
%   Both maps must have the same size (nxm).

%   Thorw error if the size of A and B does not fit.

%   Substract a the average of both maps individually.
    A=A-mean(mean(A));
    B=B-mean(mean(B));
   
%   If the maps are quadratic, calculate the length of the cross
%   correlation and do the actual cross correlation.
    if (size(A,1) == 1)||(size(A,2) == 1)
        if (size(A,1) == 1)
            corrLength1=size(A,2)+size(B,2)-1;
        else
            corrLength1=size(A,1)+size(B,1)-1;
        end

        C=fftshift(ifft(fft(A,corrLength1).*conj(fft(B,corrLength1))));
    else
        
%   If the maps are not quadratic, calculate the lengths of the cross
%   correlation in each direction and do the actual cross correlation.
        corrLength1=size(A,1)+size(B,1)-1;
        corrLength2=size(A,2)+size(B,2)-1;
        
        C=fftshift(ifft2(fft2(A,corrLength1,corrLength2).*conj(fft2(B,corrLength1,corrLength2))));
    end
end