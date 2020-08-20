function [coeff,score2D,score,wnRange] = pcaHyp(fw,bw,wn,wnRange,components,refIdx)
    %Prepare the data: average forward and backward and do complex
    %conjugate averaging

    autoSave = false;
    
    fw = complexConjugateAvg(fw,4);
    bw = complexConjugateAvg(bw,4);
    
    data = (fw+bw)./2;
    
    data = squeeze(mean(data,3));
    
    %Cut wavenumber matrix and data matrix to wnRange
    data = data(:,:,wn>min(wnRange)&wn<max(wnRange));
    
    wnRange = wn(wn>min(wnRange)&wn<max(wnRange));
    
    
    %Reference all spectra to spectra contained in refIdx
    if numel(refIdx) == 0
        Ref = ones(size(data));
    else
        Ref = zeros(size(data));
        for i = 1:size(data,3)
            Ref(:,:,i) = squeeze(mean(mean(data(refIdx(1,:),refIdx(2,:),i),2),1));
        end
    end

    data = data./Ref;
    
    %cut 3D data set into 2D dataset (dim 1 -> concatenated spatial 
    %coordinate (observations), 
    %dim2 -> wavenumber (variables))
    data2D = zeros(size(data,1)*size(data,2),size(data,3));
    coords = zeros(size(data,1)*size(data,2),2);
    for i = 1:size(data,1)*size(data,2)
        data2D(i,:) = data(mod(i,size(data,1))+1,ceil(i/size(data,1)),:);
        coords(i,1) = mod(i,size(data,1))+1;
        coords(i,2) = ceil(i/size(data,1));
    end
    
    %Do the actual PCA on phase, imaginary part or magnitude
    [coeff,score,~,~,explained] = pca(angle(data2D));

    %put the scores into a 3D data set again (dim1 and dim2 -> spatial 
    %coordinates x and y, dim3 -> variable  (in this case wavennumber))
    score2D = zeros(size(data,1),size(data,2),size(score,2));
    for k = 1:size(score,1)
        score2D(coords(k,1),coords(k,2),:) = score(k,:);
    end
    
    %Plot the coefficients for the first #components 
    fig=figure;
    hold on
    for j = 1:components
        plot(wnRange,coeff(:,j).*explained(j)./100,'LineWidth',2);
        set(gca,'LineWidth',2,'FontSize',20,'Box','on');
    end
    xlabel 'Wavenumber [cm^{-1}]'
    ylabel 'weighted Component'
    if autoSave
        saveas(fig,'weighted_components.eps');
    end
    
    fig=figure;
    plot(explained(1:10))
    xlabel 'Number of Component'
    ylabel 'Percent Explained by Component'
    if autoSave
        saveas(fig,'weights.eps');
    end
    
    %plot the Score maps for the first #components
    for j = 1:components
        fig=figure;
        contourf(squeeze(score2D(:,:,j)).',10,'LineColor', 'none','EdgeColor','none');
        axis image
        colormap jet
        colorbar
        if autoSave
            saveas(fig,['component' num2str(j) '.eps']);
        end
    end
    
    
end