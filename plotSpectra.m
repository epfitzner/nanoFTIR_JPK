function f = plotSpectra(sample,ref,wn,wnMin, wnMax, name, nameRef,printFigure)

    f=figure('name',sprintf(['Sample: ' name '; ' 'Reference: ' nameRef]));

    
    set(f, 'Position', [300, 150, 1024, 768]);
    subplot(3,1,1)
    plot(wn,abs(sample./ref))
    title('Amplitude');
    axis([wnMin wnMax 0 1])
    axis 'auto y'
    xlabel 'Wavenumber [cm^{-1}]'

    subplot(3,1,2)
    plot(wn,(angle(sample./ref)))
    title('Phase');
    axis([wnMin wnMax 0 1])
    axis 'auto y'
    xlabel 'Wavenumber [cm^{-1}]'
    
    subplot(3,1,3)
    plot(wn,imag(sample./ref))
    title('Imaginary Part');
    axis([wnMin wnMax 0 1])
    axis 'auto y'
    xlabel 'Wavenumber [cm^{-1}]'
    
    
    if printFigure
        print(f,name,'-depsc');
    end
end