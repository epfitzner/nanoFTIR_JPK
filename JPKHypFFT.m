function [ FFTHyp,wnHyp,IFHyp ] = JPKHypFFT( IFHyp_, length, zerofilling, cutoff, checkAlignment, mode, phaseCorrection )
%JPKHYPFFT Summary of this function goes here
%   Detailed explanation goes here

    FFTHyp = zeros(size(IFHyp_,1),size(IFHyp_,2),size(IFHyp_,3),length*zerofilling);
    IFHyp = zeros(size(IFHyp_,1),size(IFHyp_,2),size(IFHyp_,3),length*zerofilling);
    
    for i = 1:size(IFHyp_,1)
        for j = 1:size(IFHyp_,2)
            [ FFTHyp(i,j,:,:),wnHyp,IFHyp(i,j,:,:) ] =  JPKFFT(reshape(IFHyp_(i,j,:,:),[size(IFHyp_,3) size(IFHyp_,4)]), length, zerofilling, cutoff, checkAlignment, mode, phaseCorrection);
        end
    end
end

