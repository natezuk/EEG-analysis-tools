% Demonstrate how the spectrum of a noise signal with a particular duration
% changes after spline interpolation
eFs = 256;
nscale = 3;
tmin = -100; tmax = 2000;
t = floor(tmin/1000*eFs):ceil(tmax/1000*eFs);
% make a random noise sample
% s = randn(length(t),1);
% make a delta function
s = zeros(length(t),1);
s(t==0) = 1;


% Compute the power spectrum of each step
[P,frq_e] = periodogram(s,[],[],eFs);

% spline interpolation
[spline_matrix,SSPL] = spline_transform(s',nscale);
% 
% % transform a delta function (zero lag) using the spline matrix
% % then compute dot product with the spline-transformed design matrix
% %     dlt = [zeros(1,length(delays)-1) 1];
sflt = spline_matrix*SSPL';
% 
% clear SSPL

[Pflt,~] = periodogram(sflt,[],[],eFs);

figure
hold on
plot(frq_e,P,'k');
% plot(frq_mv,Pmv,'b');
cmap = colormap('jet');
plot(frq_e,Pflt,'Color',[0 0 1],'LineWidth',2);
set(gca,'XScale','log','YScale','log','FontSize',16);
xlabel('Frequency (Hz)');
ylabel('Power spectral density');
% legend('Original','Removed movmean','Spline filtered');

figure
hold on
plot([frq_e(2) frq_e(end)],[0 0],'k--');
plot(frq_e,20*log10(Pflt)-20*log10(P),'Color',[0 0 1],'LineWidth',2);
set(gca,'XScale','log','FontSize',16);
xlabel('Frequency (Hz)');
ylabel('Power spectral density of filter');

% fprintf('Geometric mean: %.3f\n',geomean([mdlFs/2 1000/(tmax-tmin)]));