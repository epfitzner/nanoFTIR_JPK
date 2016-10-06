function yout = cmplxreal(v,wn)
    yout = v(1)*(v(2).^2-wn.^2+1i*v(3).*wn)./sqrt((v(2)^2-wn.^2).^2 + v(3)^2.*wn.^2)+v(4)+1i*v(5)+(v(6)).*wn;
    A = real(yout);
    B = imag(yout);
    
    yout = [A ; B];
end