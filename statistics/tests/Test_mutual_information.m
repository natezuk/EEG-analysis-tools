% Test the mutual information computation
% Gaussian noise, uncorrelated
nelems = 100000;
x = randn(nelems,1);
y = randn(nelems,1);
MI_uncorr = mutual_information(x,y);
fprintf('MI of two Gaussian noise signals: %.3f\n',MI_uncorr);

% Gaussian noise, perfectly correlated
MI_corr = mutual_information(x,x);
fprintf('MI of correlated Gaussian noise signals: %.3f\n',MI_corr);

% Sinusoidal signals pi/2 phase apart
x = cos(2*pi*(1:nelems)/100)';
y = sin(2*pi*(1:nelems)/100)';
MI_circ = mutual_information(x,y);
fprintf('MI of sin and cos: %.3f\n',MI_circ);