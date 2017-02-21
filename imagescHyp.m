function imagescHyp( fw , bw , wnDisp , wn , refIdx )
%IMAGESCHYP Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin < 5
        refIdx = [];
    end
    
    wnIdx = find(diff(sign(wn-wnDisp)));
    
    fw = complexConjugateAvg(fw,4);
    bw = complexConjugateAvg(bw,4);
    
    fw = reshape(mean(fw(:,:,:,wnIdx),3),[size(fw,1) size(fw,2)]);
    bw = reshape(mean(bw(:,:,:,wnIdx),3),[size(bw,1) size(bw,2)]);
    
    if numel(refIdx) == 0
        fwRef = ones(size(fw,1),size(fw,2));
        bwRef = ones(size(bw,1),size(bw,2));
    else
        fwRef = mean(mean(fw(refIdx(1,:),refIdx(2,:)),2),1);
        bwRef = mean(mean(bw(refIdx(1,:),refIdx(2,:)),2),1);
    end

    scrsz = get(groot,'ScreenSize');
    figure('Position',[scrsz(3)/4 scrsz(3)/4 scrsz(3)*2/4 scrsz(4)*3/4]);
        
    ax1 = subplot(2,2,1);
    imagesc(abs(fw./fwRef))
    colormap(ax1,hot)
    colorbar
    
    ax2 = subplot(2,2,2);
    imagesc(angle(fw./fwRef))
    colormap(ax2,jet)
    colorbar
    
    ax3 = subplot(2,2,3);
    imagesc(abs(bw./bwRef))   
    colormap(ax3,hot)
    colorbar
    
    ax4 = subplot(2,2,4);
    imagesc(angle(bw./bwRef))
    colormap(ax4,jet)
    colorbar
end

