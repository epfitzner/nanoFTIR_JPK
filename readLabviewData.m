function data = readLabviewData(fileName,nDim,prec,complex)

    if nargin == 1
        nDim = 1;
        prec = 'double';
        complex = false;
    elseif nargin == 2
        prec = 'double';
        complex = false;
    elseif nargin == 3
        complex = false;
    elseif nargin > 4
        error('Too many input argumetnts.');
    end
    
    fid = fopen(fileName,'r','ieee-be'); % Open the binary file
    
    DimArray = zeros(0,nDim);
    
    for i = 1:nDim
        Dim4 = fread(fid,4); % Reads the first dimension
        
        Dim = 2^32*Dim4(1) + 2^16*Dim4(2) + 2^8*Dim4(3) + Dim4(4);
        
        DimArray(i) = Dim;
    end
    
    if complex
        dataFull = fread(fid,2*prod(DimArray),prec,0,'ieee-be'); % Load double precision data
        data = dataFull(1:2:length(dataFull)) + 1i.*dataFull(2:2:length(dataFull));
    else
        data = fread(fid,prod(DimArray),prec,0,'ieee-be'); % Load double precision data
    end
    
    data = reshape(data,fliplr(DimArray));
    
    data = permute(data, fliplr(1:length(DimArray)));
end