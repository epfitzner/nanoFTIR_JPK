function vestimated = createComplexHarmOscillatorFit(wn, y, wnStart,wnStop)

%(d+a./((b.^2-x.^2)-1i*c*x)
%A = v(1)*(v(2).^2-wn.^2+1i*v(3).*wn)./sqrt((v(2)^2-wn.^2).^2 + v(3)^2.*wn.^2)+v(4);

x0 = [1 1700 1 1 1 1];

start = find(diff(sign(wn-wnStart)));
stop = find(diff(sign(wn-wnStop)));

if stop<start
    temp = start;
    start = stop;
    stop = temp;
    clear temp;
end

yIn = y(start:stop);

opts.TolFun = 1e-20;
opts.TolX = 1e-30;
opts.MaxFunEvals = 10000;

vestimated = lsqcurvefit(@cmplxreal,x0,wn(start:stop),[real(yIn) ; imag(yIn)],[],[],opts);
vestimated

fit = cmplxreal(vestimated,wn(start:stop));
cmplxFit = fit(1,:)+1i*fit(2,:);
plot(wn(start:stop),angle(yIn),wn(start:stop),angle(cmplxFit))
figure
plot(wn(start:stop),abs(yIn),wn(start:stop),abs(cmplxFit))
figure
plot(yIn)
hold on
plot(cmplxFit)
hold off