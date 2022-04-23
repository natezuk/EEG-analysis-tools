function md_distr = compute_median_distr(x,nboot)
% Compute a bootsrapped distribution of medians of x, in order to quantify
% the standard error of the median. If there are multiple columns of x,
% this is done separately for each column.
% Note: When the rows of x are resampled for each bootstrap iteration, NaN
% values are *not* ignored when calculating the number of values to
% resample. The same resampling is applied to all columns. This means that
% different resamplings may contain different numbers of NaN values, but we
% can ensure that resamplings are consistent across iterations in md_distr.
% Nate Zuk (2021)

if nargin<2, nboot = 1000; end

md_distr = NaN(nboot,size(x,2));
for n = 1:nboot
    % randomly sample rows of x, with replacement
    rw_smp = randi(size(x,1),size(x,1),1);
    % automatically omit nan values
    md_distr(n,:) = median(x(rw_smp,:),1,'omitnan');
end