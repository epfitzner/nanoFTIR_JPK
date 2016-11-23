function n = optimizeOffsetToBMHApodiziation(IFAvg,cutoff)
    
    %Substract offset from average interferogram if not done
    IFAvg = IFAvg - mean(IFAvg);
    
    %Cut cutoff regions with zeros
    IF = IFAvg(round(size(IFAvg,2)*cutoff):round(size(IFAvg(1,:),2)*(1-cutoff)));
    
    %Create 4-Term Blackman-Harris Apodization
    w = fftshift(blackmanharrisApodization(length(IF),4));
    
    %Permute average interferoram, multiply with apodization and integrate.
    maxi = zeros(length(IF),1);

    for i = 1:length(IF)
        maxi(i) = sum(abs(circshift(w,[0,i]).*IF));
    end
    
    [~,n] = max(maxi);
end