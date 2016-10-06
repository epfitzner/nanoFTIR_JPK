
start = 1;
stop = 9;

cm=colormap(jet(stop-start+1));
   
ampContrast = zeros(1,stop-start+1);
ampIntensity = zeros(1,stop-start+1);
phiContrast = zeros(1,stop-start+1);

hold on

fitting = true;

for i = start:stop
    %get indices ranges, in which the amplitude reference spectra are above
    %a certain threshold (7.5 %)
    idx = find(abs(spectra{i,3})>0.075*max(abs(spectra{i,3}))&600<wn&wn<2300);   
    
    if false
        %plot phase or amplitude spectra
        plot(wn,abs(spectra{i,2}),'color',cm(i-start+1,:),'LineWidth',2);
        %plot(wn(idx),abs(spectra{i,3}(idx)),'color',cm(i-start+1,:),'LineWidth',2);
        %axis([min(wn(idx)) max(wn(idx)) 0 1])
        axis([wn(idx(1)) wn(idx(size(idx,2))) 0 1])
        axis 'auto y'
        xlabel 'Wavenumber [cm^{-1}]'
    end
    
    if fitting
       %fit spectra
       fitresult = createGuassianFit(wn(idx),abs(spectra{i,2}(idx)),true);
       maximum(i-start+1) = fitresult.c;
       width(i-start+1) = fitresult.b;
       assignin('base','maximum',maximum);
       assignin('base','width',width);
    end

    if false
        %Evaluate the contrast of amplitude and phase with baseline
        %correction from  
        start_wn = 811; %1687
        stop_wn = 856; %to 1780
        zoom = spectra{i,2}(start_wn:stop_wn);
        wn_zoom = wn(start_wn:stop_wn);
        x = [0:stop_wn-start_wn];

        slope = (abs(spectra{i,2}(stop_wn))-abs(spectra{i,2}(start_wn)))/(stop_wn-start_wn+1);
        line = slope*x*1;
        plot(wn_zoom,abs(zoom)-line,'color',cm(i-start+1,:),'LineWidth',2)
        ampContrast(i) = max(abs(zoom)-line)-min(abs(zoom)-line);
        ampIntensity(i) = mean(abs(zoom));
        assignin('base','ampContrast',ampContrast)
        assignin('base','ampIntensity',ampIntensity)

        zoom = unwrap(angle(zoom));
        slope = (zoom(size(zoom,2))-zoom(1))/(stop_wn-start_wn+1);
        line = slope*x*1;
        %plot(wn_zoom,zoom-line,'color',cm(i-start+1,:),'LineWidth',2)
        phiContrast(i) = max(zoom-line)-min(zoom-line);
        assignin('base','phiContrast',phiContrast)
    end
        
    if false
        %plot complex spectra in polar plot
        plot((spectra{i,2}(769:865)),'color',cm(i-start+1,:),'LineWidth',2);
        text(real(spectra{i,2}(834)),imag(spectra{i,2}(834)),'\leftarrow','FontSize',16,'FontWeight','bold');%mark at 1736 cm^{-1}
        %text(real(spectra{i,2}(769)),imag(spectra{i,2}(769)),num2str((i-2)/10+1.46));
        axis equal
    end

end

if fitting
    plot(antennaLength, width,'-','LineWidth',2,'color','red')
    assignin('base','maxi_wo',maximum);
    ylabel 'Fitted Maximum [cm^{-1}]'
    xlabel 'Antenna Length L [µm]'
    hold on
end