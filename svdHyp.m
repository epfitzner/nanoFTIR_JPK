function [fw,bw] = svdHyp(fw,bw,components)
    %Prepare the data: average forward and backward and do complex
    %conjugate averaging
    
    %cut 3D data set into 2D dataset (dim 1 -> concatenated spatial 
    %coordinate (observations), 
    %dim2 -> wavenumber (variables))
    for i=1:size(fw,3)
        fw2D = zeros(size(fw,1)*size(fw,2),size(fw,4));
        bw2D = zeros(size(bw,1)*size(bw,2),size(bw,4));
        coordsFw = zeros(size(fw,1)*size(fw,2),2);
        coordsBw = zeros(size(bw,1)*size(bw,2),2);
        
        for j = 1:size(fw,1)*size(fw,2)
            fw2D(j,:) = fw(mod(j,size(fw,1))+1,ceil(j/size(fw,1)),i,:);
            bw2D(j,:) = bw(mod(j,size(bw,1))+1,ceil(j/size(bw,1)),i,:);
            coordsFw(j,1) = mod(j,size(fw,1))+1;
            coordsFw(j,2) = ceil(j/size(fw,1));
            coordsBw(j,1) = mod(j,size(bw,1))+1;
            coordsBw(j,2) = ceil(j/size(bw,1));
        end
    
        %Do the actual PCA on phase, imaginary part or magnitude
        [Ufw,Sfw,Vfw] = svd((fw2D));
        [Ubw,Sbw,Vbw] = svd((bw2D));
        
        Sfw_ = zeros(size(Sfw));
        Sbw_ = zeros(size(Sbw));
        
        for j = 1:components
            Sfw_(j,j) = Sfw(j,j);
            Sbw_(j,j) = Sbw(j,j);
        end

        fw2D = Ufw*Sfw_*Vfw';
        bw2D = Ubw*Sbw_*Vbw';

        %put the scores into a 3D data set again (dim1 and dim2 -> spatial 
        %coordinates x and y, dim3 -> variable  (in this case wavennumber))

        for j = 1:size(fw2D,1)
            fw(coordsFw(j,1),coordsFw(j,2),i,:) = fw2D(j,:);
            bw(coordsFw(j,1),coordsFw(j,2),i,:) = bw2D(j,:);
        end 
    end
end