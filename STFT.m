function STFT = STFT(IF,h)

    SFTF = zeros(size(IF,2),size(IF,2));
    
    t = -round(size(IF,2)/2):round(size(IF,2)/2)-1;
    
    g = 1./(sqrt(2*pi).*h).*exp(-t.^2./(2*h^2));
    
    for i = 1:size(IF,2)
        STFT(:,i) = IF.*circshift(g,[i i]);
    end
end