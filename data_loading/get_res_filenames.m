function [fnms,sbjs] = get_res_filenames(respath,exp_condition,suffix)
% Get the filenames for EEG results .mat files that correspond to a 
% specific experiment and electrode reference
% These are usually named: <sbj>_<exp_cond>_<suffix>.mat. If the suffix is
% not provided, the filename is assumed to be: <sbj>_<exp_cond>.mat
% <sbj> must be 8 characters long
% Nate Zuk (2021)

if nargin<3, suffix = ''; end

if ~isempty(suffix)
    expected_ending = sprintf('_%s_%s.mat',exp_condition,suffix);
else
    expected_ending = sprintf('_%s.mat',exp_condition);
end

fls = what(respath);
mats = fls.mat;

% Identify files that correspond to the experiment and expected filename
sbjs = {};
fnms = {};
for m = 1:length(mats)
    if strcmp(mats{m}(9:end),expected_ending)
        % if it matches, save the filename
        fnms = [fnms; mats(m)];
        sbjs = [sbjs; {mats{m}(1:8)}];
    end
end