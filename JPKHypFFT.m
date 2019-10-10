function [ FFTHyp,wnHyp,IFHyp ] = JPKHypFFT( IFHyp_, length, zerofilling, cutoff, checkAlignment, mode, phaseCorrection, singleSided )
%JPKHYPFFT Summary of this function goes here
%   Detailed explanation goes here

    if singleSided
        factor = 2;
    else
        factor = 1;
    end
    
    FFTHyp = zeros(size(IFHyp_,1),size(IFHyp_,2),size(IFHyp_,3),length*zerofilling*factor);
    IFHyp = zeros(size(IFHyp_,1),size(IFHyp_,2),size(IFHyp_,3),length*zerofilling*factor);
    
    [TempFFTHyp,wnHyp,TempIFHyp] = JPKFFT(reshape(IFHyp_(:,:,:,:),[size(IFHyp_,1)*size(IFHyp_,2)*size(IFHyp_,3) size(IFHyp_,4)]), length, zerofilling, cutoff, checkAlignment, mode, phaseCorrection,singleSided);
    FFTHyp = reshape(TempFFTHyp,size(FFTHyp));
    IFHyp = reshape(TempIFHyp,size(IFHyp));

end

