function [results,gof] = fitComplexLorentzian(wn,data,par0)
    %Fit simultaneously real and imaginary part of mulitple complex
    %lorentzians to data.
    %Size of par0 is 4xm where m-1 is the number of lorentzian
    %contributions involved 
    %par0(1,1:m-1): Amplitude of Lorentzian
    %par0(2,1:m-1): Frequency of Lorentzian
    %par0(3,1:m-1): gamma (Width of Lorentzian)
    %par0(1:4,m):   defines a complex polynomial first order
    %y = par0(1,m)+1i*par0(2,m) + (par0(3,m)+1i*par0(4,m))*x;
    
    m = size(par0,2)-1;

    Re = @(par) real(par(1)./((par(2).^2-wn.^2)-1i.*par(3).*wn));
    Im = @(par) imag(par(1)./((par(2).^2-wn.^2)-1i.*par(3).*wn));

    slope = @(par) (par(1)+1i.*par(2)) + (par(3)+1i.*par(4)).*wn;
    
    Upper = [inf inf inf inf inf inf inf];
    Lower = [0 -inf -inf -inf -inf -inf -inf]; 
        
    function err = parFunc(par)
        err = 0;
        fitted = 0;
 
        %sum up the different lorentzian contributions
        for i  = 1:m         
            fitted = fitted + Re(par(:,i))+1i.*Im(par(:,i));
        end          
         
        %Add the complex first-order polynomial
        fitted = fitted + slope(par(:,m+1));
        
        %Calculate the rmse
        err = err + sum(abs(fitted-data).^2);
    end

    err = @(par) parFunc(par);

    opts.MaxFunEvals = 100000;
    opts.MaxIter = 100000;
    
    %Execute the fit
    results = fminsearch(err,par0,opts);
    
    
    %Plot Amplitudes
    figure
    subplot(2,1,1)
    plot(wn,abs(data),'color','k','LineStyle','none','Marker','o')
    hold on
    
    resultLine = 0;
    for i = 1:size(par0,2)
        resultLine = resultLine + Re(results(:,i)) + 1i.*Im(results(:,i));
        %Plot individual Lorentzian contributions
        plot(wn,abs(Re(results(:,i)) + 1i.*Im(results(:,i))+slope(results(:,m+1))),'LineStyle','--')
    end
    %Plot compound Lorentzian amplitude
    plot(wn,abs(resultLine+slope(results(:,m+1))),'color','r')
    xlabel 'Wavenumber [cm^{-1}]'
    ylabel '|s_n|'
    
    %Plot Imaginary
    subplot(2,1,2)
    plot(wn,imag(data),'color','k','LineStyle','none','Marker','o')
    hold on
    for i = 1:size(par0,2)
        %Plot individual Lorentzian contributions
        plot(wn,Im(results(:,i) + imag(slope(results(:,m+1))),'LineStyle','--')
    end
    %Plot compound Lorentzian imaginary part
    plot(wn,imag(resultLine+slope(results(:,m+1))),'color','r')
    xlabel 'Wavenumber [cm^{-1}]'
    ylabel 'Im\{s_n\}'
    
    
    gof.rmse = 0;
end