function [mddiff,nulldiff,bootp] = bootstrap_mddiff(x)
% Calculate the bootstrapped median distribution of paired samples in x,
% and the null distribution by randomly swapping groups of pairs of x

nrows = size(x,1);

% bootstrapped median
nboot = 10000;
mddiff = NaN(nboot,1);
bootp = NaN(nboot,1);
for b = 1:nboot
    % randomly sample rows of x, with replacement
    randsmp = randi(nrows,nrows,1);
    smpx = x(randsmp,:);
    % calculate the median difference
    mddiff(b) = median(diff(smpx,[],2));
    % bootstrapped calculation of wilcoxon signed-rank
    bootp(b) = signrank(smpx(:,1),smpx(:,2));
end

% calculate a null median by randomly swapping groups
nulldiff = NaN(nboot,1);
for b = 1:nboot
    % randomly swap groups
    randswap = randi(2,nrows,1);
    nullx = NaN(nrows,2);
    for n = 1:nrows
        nullx(n,1) = x(n,randswap(n));
        nullx(n,2) = x(n,-(randswap(n)-1.5)+1.5);
    end
    % randomly sample rows
    randsmp = randi(nrows,nrows,1);
    nullsmpx = nullx(randsmp,:);
    % calculate the median difference
    nulldiff(b) = median(diff(nullsmpx,[],2));
end