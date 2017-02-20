function [ IFHypfw, IFHypbw ] = loadJPKHyperSpectralImage( filename )
%LOADJPKHYPERSPECTRALIMAGE Summary of this function goes here
%   Detailed explanation goes here
    
    data = readLabviewData(filename,4,'single',true);
    IFHypfw = data(:,:,1:size(data,3)/2,:);
    IFHypbw = data(:,:,size(data,3)/2+1:end,:);
end

