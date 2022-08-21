function [p,tstat,nullt] = bootstrap_ttest_onesample(x,tail)
% Calculate the bootstrapped median distribution of paired samples in x,
% and the null distribution by randomly swapping groups of pairs of x

if nargin<2, tail = 'both'; end

% Calculate the true t-statistic
nrows = size(x,1);
tstat = mean(x)/(std(x)/sqrt(nrows));

% calculate the null t-statistics 
nboot = 10000;
nullt = NaN(nboot,1);
for b = 1:nboot
    % randomly sample rows
    randsmp = randi(nrows,nrows,1);
    nullsmpx = x(randsmp);
    % calculate the t-statistic of the null (relative to the mean of the
    % samples, see Efron & Tibrishani)
    nullt(b) = (mean(nullsmpx) - mean(x))/(std(nullsmpx)/sqrt(nrows));
end

% Determine the type of p-value
if strcmp(tail,'both')
    % Two-tailed p-value
    p = 2*min([sum(nullt>tstat) sum(nullt<tstat)])/nboot;
elseif strcmp(tail,'left')
    p = sum(nullt<tstat)/nboot;
elseif strcmp(tail,'right')
    p = sum(nullt>tstat)/nboot;
else
    error('Tail must be left, right, or both');
end