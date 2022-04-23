function [v,idx] = get_triggered_eyeblinks(eeg_channel,eyeblink_thres,Fs,varargin)
% For a single EEG channel, identify eyeblinks based on sparse events (>99%
% quantile), get the peak of each event, and get the event in a 500 ms
% window surrounding the peak
% Inputs:
% - eeg_channel = voltage values for a single EEG channel
% - Fs = sampling rate of the EEG
% Outputs:
% - v = matrix of voltages for each triggered eyeblink (uV x eyeblinks)
% - idx = matrix of indexes in the original EEG signal for each eyeblink
% Nate Zuk (2021)

% Parameters
wnd = 500; % window around the peak of each eyeblink, in ms

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

%% Detect eyeblinks
% get voltages above threshold
thres_passing = eeg_channel>eyeblink_thres;
% remove continguous indexes after the first threshold crossing
diff_pass = [0; diff(thres_passing)];
thres_passing(diff_pass<=0) = false;
% get their indexes
thres_idx = find(thres_passing);

%% Extract eyeblinks around peak
dly = -ceil(wnd/2000*Fs):ceil(wnd/2000*Fs); % get the indexes that will be 
    % used to get the eyeblink around each peak
v = NaN(length(dly),length(thres_idx));
idx = NaN(length(dly),length(thres_idx));
% for each eyeblink...
for n = 1:length(thres_idx)
    % find the peak within half the width after the threshold crossing
    check_idx = thres_idx(n) + (0:ceil(wnd/2000*Fs));
    % remove indexes longer than the eeg signal
    check_idx(check_idx>length(eeg_channel)) = [];
    thresd_seg = eeg_channel(check_idx);
    pk_seg_idx = find(thresd_seg==max(thresd_seg),1);
    % get the index of the peak in the eeg signal
    pk_idx = pk_seg_idx + thres_idx(n);
    % get the eyeblink indexes within the window
    idx(:,n) = pk_idx + dly;
    % make sure the indexes are within the range of times in the original
    % eeg signal
    use_idx = idx(:,n)>0 & idx(:,n)<length(eeg_channel);
    v(use_idx,n) = eeg_channel(idx(use_idx,n));
    % make indexes outside the range of times in the eeg signal NaN
    idx(~use_idx,n) = NaN;
end