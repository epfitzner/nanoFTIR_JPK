function w = blackmanharrisApodization(N,order)
    %Apodization: 4-term Blackman-Harris (a_0=0.35875, a_1=0.48829, a_2=0.14128, a_3=0.01168)

    a_0=0.35875; 
    a_1=0.48829; 
    a_2=0.14128; 
    a_3=0.01168;
    
    if order == 3
        a_3 = 0;
    elseif order == 4
    else
        error('Decide order between 3 and 4 term BMH.');
        return;
    end

    n = linspace(0,N-1,N);
        
    %Blackman-Harris apodization
    w = a_0 - a_1*cos(2*pi*n/(N-1)) + a_2*cos(4*pi*n/(N-1)) - a_3*cos(6*pi*n/(N-1));
end