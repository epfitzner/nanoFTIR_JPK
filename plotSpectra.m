function plotSpectra(data)
    wn = data.wn;
    
    reference = true;

    complConj = true;

    AvgFwBw = true;

    holdOn = true;

    mode = 3;  %1: imaginary part, 2: abs, 3: angle
    
    if holdOn
        hold on;
    else
        figure
    end

    CO = get(gca,'ColorOrder');

    if reference
        if AvgFwBw
            if complConj
                spect = mean(complexConjugateAvg([data.forwardSample; data.backwardSample],2))./mean(complexConjugateAvg([data.forwardRef; data.backwardRef],2));

                [I,A,P] = calcStdDev(complexConjugateAvg([data.forwardSample; data.backwardSample],2),complexConjugateAvg([data.forwardRef; data.backwardRef],2));
            else
                spect = mean([data.forwardSample; data.backwardSample])./mean([data.forwardRef; data.backwardRef]);

                [I,A,P] = calcStdDev([data.forwardSample; data.backwardSample],[data.forwardRef; data.backwardRef]);
            end

            
            
            switch mode
                case 1
                    spect = imag(spect);
                    h = plot(wn,spect);
                    I=imag(I);
                    index = ceil(length(get(gca, 'Children'))/2);
                    patch([wn fliplr(wn) wn(1)], [spect-I fliplr(spect+I) spect(1)-I(1)],CO(index,:),'EdgeColor','none','FaceAlpha',0.1);
                case 2
                    spect = abs(spect);
                    h = plot(wn,spect);
                    index = ceil(length(get(gca, 'Children'))/2);
                    patch([wn fliplr(wn) wn(1)], [spect-A fliplr(spect+A) spect(1)-A(1)],CO(index,:),'EdgeColor','none','FaceAlpha',0.1);
                case 3
                    spect = angle(spect);
                    h = plot(wn,spect);
                    index = ceil(length(get(gca, 'Children'))/2);
                    patch([wn fliplr(wn) wn(1)], [spect-P fliplr(spect+P) spect(1)-P(1)],CO(index,:),'EdgeColor','none','FaceAlpha',0.1);
            end
        else
            if complConj
                fwSpect = mean(complexConjugateAvg(data.forwardSample,2))./mean(complexConjugateAvg(data.forwardRef,2));
                bwSpect = mean(complexConjugateAvg(data.backwardSample,2))./mean(complexConjugateAvg(data.backwardRef,2));

                [fwI,fwAbs,fwPhi] = calcStdDev(complexConjugateAvg(data.forwardSample,2),complexConjugateAvg(data.forwardRef,2));
                [bwI,bwAbs,bwPhi] = calcStdDev(complexConjugateAvg(data.backwardSample,2),complexConjugateAvg(data.backwardRef,2));
            else
                fwSpect = imag(mean(data.forwardSample)./mean(data.forwardRef));
                bwSpect = imag(mean(data.backwardSample)./mean(data.backwardRef));

                [fwI,fwAbs,fwPhi] = calcStdDev(data.forwardSample,data.forwardRef);
                [bwI,bwAbs,bwPhi] = calcStdDev(data.backwardSample,data.backwardRef);
            end

            switch mode
                case 1
                    fwSpect = imag(fwSpect);
                    bwSpect = imag(bwSpect);
                    fwI = imag(fwI);
                    bwI = imag(bwI);
                    h = plot(wn,fwSpect,wn,bwSpect);
                    patch([wn fliplr(wn) wn(1)], [fwSpect-fwI fliplr(fwSpect+fwI) fwSpect(1)-fwI(1)],'b','EdgeColor','none','FaceAlpha',0.1)
                    patch([wn fliplr(wn) wn(1)], [bwSpect-bwI fliplr(bwSpect+bwI) bwSpect(1)-bwI(1)],'r','EdgeColor','none','FaceAlpha',0.1)
                case 2
                    fwSpect = abs(fwSpect);
                    bwSpect = abs(bwSpect);
                    h = plot(wn,fwSpect,wn,bwSpect);
                    patch([wn fliplr(wn) wn(1)], [fwSpect-fwAbs fliplr(fwSpect+fwAbs) fwSpect(1)-fwAbs(1)],'b','EdgeColor','none','FaceAlpha',0.1)
                    patch([wn fliplr(wn) wn(1)], [bwSpect-bwAbs fliplr(bwSpect+bwAbs) bwSpect(1)-bwAbs(1)],'r','EdgeColor','none','FaceAlpha',0.1)
                case 3
                    fwSpect = angle(fwSpect);
                    bwSpect = angle(bwSpect);
                    h = plot(wn,fwSpect,wn,bwSpect);
                    patch([wn fliplr(wn) wn(1)], [fwSpect-fwPhi fliplr(fwSpect+fwPhi) fwSpect(1)-fwPhi(1)],'b','EdgeColor','none','FaceAlpha',0.1)
                    patch([wn fliplr(wn) wn(1)], [bwSpect-bwPhi fliplr(bwSpect+bwPhi) bwSpect(1)-bwPhi(1)],'r','EdgeColor','none','FaceAlpha',0.1)
            end
        end

        uistack(h,'top');
        ylabel 'Im(s_n/{s_n}^{ref})'
    else
        if complConj
            plot(wn,imag(mean(complexConjugateAvg(data.fwSample,2))),wn,imag(mean(complexConjugateAvg(data.fwRef,2))),wn,imag(mean(complexConjugateAvg(data.bwSample,2))),wn,imag(mean(complexConjugateAvg(data.bwRef,2))))
        else
            plot(wn,imag(mean(data.fwSample)),wn,imag(mean(data.fwRef)),wn,imag(mean(data.bwSample)),wn,imag(mean(data.bwRef)))
        end

        ylabel 'Im(s_n) [V]'
    end

    xlabel 'Wavenumber [cm^{-1}]'
    set(gca,'XDir','rev')
    xlim([1300 2000]);

    if holdOn
        hold off;
    end
    
end