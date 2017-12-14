function imagescHyp( fw , bw , wnDisp , wn , refIdx )
%IMAGESCHYP Summary of this function goes here
%   Detailed explanation goes here
    
    plotAvg = true;
    if nargin < 5
        refIdx = [];
    end
    
    fw = complexConjugateAvg(fw,4);
    bw = complexConjugateAvg(bw,4);
    
    if length(wnDisp) > 1
       wnIdx = wn>min(wnDisp)&wn<max(wnDisp);
       fw = reshape(mean(mean(fw(:,:,:,wnIdx),3),4),[size(fw,1) size(fw,2)]);
       bw = reshape(mean(mean(bw(:,:,:,wnIdx),3),4),[size(bw,1) size(bw,2)]);
    else
       wnIdx = find(diff(sign(wn-wnDisp)));
       fw = reshape(mean(fw(:,:,:,wnIdx),3),[size(fw,1) size(fw,2)]);
       bw = reshape(mean(bw(:,:,:,wnIdx),3),[size(bw,1) size(bw,2)]);
    end
  
    if numel(refIdx) == 0
        fwRef = ones(size(fw,1),size(fw,2));
        bwRef = ones(size(bw,1),size(bw,2));
    else
        fwRef = mean(mean(fw(refIdx(1,:),refIdx(2,:)),2),1);
        bwRef = mean(mean(bw(refIdx(1,:),refIdx(2,:)),2),1);
    end

    
    if plotAvg
        figure;
        
        ax3 = subplot(1,2,1);
        contourf(abs((bw+fw)./(bwRef+fwRef))',linspace(0.01,1,20),'LineColor', 'none','EdgeColor','none' )   
        %imagesc(abs((bw+fw)./(bwRef+fwRef))');
        colormap(ax3,hot)
        h = colorbar;
        set(gca,'YDir','normal')
        axis 'image'
        set(get(h,'title'),'string','|{s_n}^{Avg}| [a.u.]');

        ax4 = subplot(1,2,2);
        phiLim = [-0.1 0.3];
        contourf(angle((bw+fw)./(bwRef+fwRef))',linspace(phiLim(1),phiLim(2),20),'LineColor', 'none' )
        %imagesc(angle((bw+fw)./(bwRef+fwRef))');
        colormap(ax4,jet)
        h = colorbar;
        set(gca,'YDir','normal','CLim',phiLim)
        axis 'image'
        set(get(h,'title'),'string','Arg\{{s_n}^{Avg}\} [rad]');
    else
        scrsz = get(groot,'ScreenSize');
        figure('Position',[scrsz(3)/6 scrsz(4)/6 scrsz(3)*4/6 scrsz(4)*5/6]);

        ax1 = subplot(2,2,1);
        contourf(abs(fw./fwRef)',linspace(0.8,1,20),'LineColor', 'none' )
        colormap(ax1,hot)
        colorbar
        set(gca,'YDir','normal')
        title '|{s_n}^{Forw}|'

        ax2 = subplot(2,2,2);
        contourf(angle(fw./fwRef)',linspace(-0.01,0.1,20),'LineColor', 'none' )
        colormap(ax2,jet)
        colorbar
        set(gca,'YDir','normal','XDir','normal')
        title 'Arg[{s_n}^{Forw}]'

        ax3 = subplot(2,2,3);
        contourf(abs((bw)./(bwRef))',linspace(0.8,1,20),'LineColor', 'none','EdgeColor','none' )   
        colormap(ax3,hot)
        colorbar
        set(gca,'YDir','normal')
        title '|{s_n}^{Back}|'

        ax4 = subplot(2,2,4);
        contourf(angle((bw)./(bwRef))',linspace(-0.01,0.06,20),'LineColor', 'none' )
        colormap(ax4,jet)
        colorbar
        set(gca,'YDir','normal')
        title 'Arg[{s_n}^{Back}]'
    end
end

