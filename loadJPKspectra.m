function [ IFfw, IFbw ] = loadJPKspectra(filename)
    %Load Data in Matlab.
    %Data structure: nxm matrix with n being 2 # of interferograms and m
    %the number of points in one interferogram (length).
    %The first n/2 interferograms are the real parts and the second n/2
    %interferograms are the corresponding imaginary ones.
    
    data = importdata(filename);
    
    n = round(size(data,1)/4);
    length = size(data,2);
    %Placeholder for the to be created interferograms.
    IFfw = zeros(n,length);
    IFbw = zeros(n,length);
    
    %Create complex interferograms by using the corresponding real and
    %imaginary parts of one interferogram.
    for i=1:n
        IFfw(i,:) = data(i,:)+1i*data(i+n,:);
        IFbw(i,:) = data(i+2*n,:)+1i*data(i+3*n,:);
    end
end