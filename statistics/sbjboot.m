function rsmp_idx = sbjboot(sbj_lbl)
% Resample indexes with replacement so that the number of indexes for each
% subject (based on sbj_lbls) remain the same after resampling.
% Nate Zuk (2022)

% Get the number of subjects
sbjs = unique(sbj_lbl);
nsbjs = length(sbjs);

rsmp_idx = [];
for s = 1:nsbjs
    % get the rows corresponding to this subject
    sbj_rws = find(sbj_lbl==sbjs(s));
    nrw = length(sbj_rws);
    % randomly sample rows of x, with replacement
    rw_smp = randi(nrw,nrw,1);
    % include these row indexes to the row selection
    rsmp_idx = [rsmp_idx; sbj_rws(rw_smp)];
end