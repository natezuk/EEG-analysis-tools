function md_distr = compute_median_distr_sbjboot(x,sbj_lbl,nboot)
% Compute a bootstrapped distribution of medians of x, in order to quantify
% the standard error of the median. The bootstrapping is done separately
% for each subject, where each row of sbj_lbl is numbered 1 to #sbjs to
% indicate each subject. If there are multiple columns of x, this is done 
% separately for each column.
% Nate Zuk (2021)

if nargin<3, nboot = 1000; end

% Get the number of subjects
sbjs = unique(sbj_lbl);
nsbjs = length(sbjs);

md_distr = NaN(nboot,size(x,2));
for n = 1:nboot
    rw_selection = [];
    for s = 1:nsbjs
        % get the rows corresponding to this subject
        sbj_rws = find(sbj_lbl==sbjs(s));
        nrw = length(sbj_rws);
        % randomly sample rows of x, with replacement
        rw_smp = randi(nrw,nrw,1);
        % include these row indexes to the row selection
        rw_selection = [rw_selection; sbj_rws(rw_smp)];
    end
    % automatically omit nan values
    md_distr(n,:) = median(x(rw_selection,:),1,'omitnan');
end