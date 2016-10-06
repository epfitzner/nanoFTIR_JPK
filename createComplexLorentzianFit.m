function createComplexLorentzianFit(wn, y, plotFit)

%(d+a./((b.^2-x.^2)-1i*c*x))

x0 = [1 1 1600 1];
opts.Display = 'Off';
opts.Lower = [-100 -inf 500 -1000];
[~, idx] = max(y);
opts.StartPoint = [1 100000 wn(idx) 1];
opts.Upper = [100 inf 4000 1000];
opts.MaxFunEvals= 10000;
[vestimated,resnorm,residuals,exitflag,output] = lsqcurvefit(@cmplxreal,x0,wn,[real(y);imag(y)],opts.Lower,opts.Upper,opts);
vestimated,resnorm,exitflag,output.firstorderopt

fit = vestimated(1)+vestimated(2)./((vestimated(3).^2-wn.^2)-1i*vestimated(4)*wn);
plot(wn,abs(fit),wn,abs(y))
figure
plot(wn,angle(fit),wn,angle(y))
figure
plot(y)
hold on
plot(fit)
hold off