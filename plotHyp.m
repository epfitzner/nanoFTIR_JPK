function plotHyp( fw , bw , x , y , wn , refIdx )
%PLOTHYP Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 6
        refIdx = [];
    end
    
    fw = complexConjugateAvg(fw,4);
    bw = complexConjugateAvg(bw,4);
    
    if numel(refIdx) == 0
        fwRef = ones(size(fw,3), size(fw,4));
        bwRef = ones(size(bw,3), size(bw,4));
    else
        fwRef = reshape(mean(mean(fw(refIdx(1,:),refIdx(2,:),:,:),2),1),[size(fw,3) size(fw,4)]);
        bwRef = reshape(mean(mean(bw(refIdx(1,:),refIdx(2,:),:,:),2),1),[size(bw,3) size(bw,4)]);
    end
    
    fw = reshape(fw(x,y,:,:),[size(fw,3) size(fw,4)]);
    bw = reshape(bw(x,y,:,:),[size(bw,3) size(bw,4)]);
    
    scrsz = get(groot,'ScreenSize');
    figure('Position',[scrsz(3)/6 scrsz(4)/6 scrsz(3)*4/6 scrsz(4)*5/6]);
        
    ax1 = subplot(2,1,1);
    
    fwSpect = abs(mean(complexConjugateAvg(fw,2))./mean(complexConjugateAvg(fwRef,2)));
    bwSpect = abs(mean(complexConjugateAvg(bw,2))./mean(complexConjugateAvg(bwRef,2)));
            
    [~,fwS,fwP] = calcStdDev(complexConjugateAvg(fw,2),complexConjugateAvg(fwRef,2));
    [~,bwS,bwP] = calcStdDev(complexConjugateAvg(bw,2),complexConjugateAvg(bwRef,2));
    
    h = plot(wn,fwSpect,wn,bwSpect);

    patch([wn fliplr(wn) wn(1)], [fwSpect-fwS fliplr(fwSpect+fwS) fwSpect(1)-fwS(1)],'b','EdgeColor','none','FaceAlpha',0.1)
    patch([wn fliplr(wn) wn(1)], [bwSpect-bwS fliplr(bwSpect+bwS) bwSpect(1)-bwS(1)],'r','EdgeColor','none','FaceAlpha',0.1)
    uistack(h,'top');
    ylabel '|s_n / {s_n}^{ref}|'
    xlabel 'Wavenumber [cm^{-1}]'
    set(gca,'XDir','rev')
    xlim([1400 1800]);
    
    
    ax2 = subplot(2,1,2);
    
    fwSpect = angle(mean(complexConjugateAvg(fw,2))./mean(complexConjugateAvg(fwRef,2)));
    bwSpect = angle(mean(complexConjugateAvg(bw,2))./mean(complexConjugateAvg(bwRef,2)));
    
    h = plot(wn,fwSpect*180/pi,wn,bwSpect*180/pi);
    patch([wn fliplr(wn) wn(1)], [fwSpect-fwP fliplr(fwSpect+fwP) fwSpect(1)-fwP(1)]*180/pi,'b','EdgeColor','none','FaceAlpha',0.1)
    patch([wn fliplr(wn) wn(1)], [bwSpect-bwP fliplr(bwSpect+bwP) bwSpect(1)-bwP(1)]*180/pi,'r','EdgeColor','none','FaceAlpha',0.1)
    uistack(h,'top')
    ylabel '\phi_n - {\phi_n}^{ref} [°]'
    xlabel 'Wavenumber [cm^{-1}]'
    set(gca,'XDir','rev')
    xlim([1400 1800]);
end

