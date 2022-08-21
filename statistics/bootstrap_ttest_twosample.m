function [p,tstat,nullt] = bootstrap_ttest_twosample(x,y,tail)
% Calculate the significance of a t-statistic for x using bootstrapped t
% for a null distribution (see Efron & Tibrishani)

if nargin<3, tail = 'both'; end

% Calculate the true t-statistic
nx = size(x,1);
ny = size(y,1);
tstat = (mean(x)-mean(y))/(var(x)/sqrt(nx)+var(y)/sqrt(ny));

% Center both x and y on the average of the two distributions
z = mean([x; y]);
shftx = x-mean(x)+z;
shfty = y-mean(y)+z;

% calculate the null t-statistics 
nboot = 10000;
nullt = NaN(nboot,1);
for b = 1:nboot
    % randomly sample rows
    smpx = randi(nx,nx,1);
    smpy = randi(ny,ny,1);
    nullsmpx = shftx(smpx);
    nullsmpy = shfty(smpy);
    % calculate the t-statistic of the null (see Efron & Tibrishani)
    nullt(b) = (mean(nullsmpx) - mean(nullsmpy))/(var(nullsmpx)/sqrt(nx) + var(nullsmpy)/sqrt(ny));
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