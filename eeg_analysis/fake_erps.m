function [ERP,dly] = fake_erps(stim,eeg,Fs,mindly,maxdly,baseline,nnull,varargin)
% Get fake evoked responses by randomizing the timings of the stimulus
% events.
% Inputs:
% - eeg = array containing EEG per trial
% - stim = array of stimulus vector for each trial (must contain 1s or 0s)
% - Fs = sampling frequency (Hz)
% - mindly = minimum possible delay of the model (ms)
% - maxdly = maximum possible delay of the model (ms)
% - baseline = two element array of delays to use as a baseline, non-inclusive (ms)
% Outputs:
% - ERP = event-related potential model (lags x channels x evts) (cell
% array for each condition)
% - dly = delays corresponding to the ERP (in ms)
% Nate Zuk (2021)
% ** Modified from eventtrigeeg.m, Nate Zuk, 2017

ncond = size(stim,2); % # of conditions (columns of stim)
nchan = size(eeg,2);

if nargin<7,
    nnull = []; % use the total number of stimulus events
end

% Parse varargin
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% note: delays are negative to account for the shift when creating the
% design matrix
dly = floor(mindly/1000*Fs):ceil(maxdly/1000*Fs);

%% Compute the ERP
fprintf('Computing ERP...');
erp_tm = tic;
% Preallocate the ERP (one cell per condition)
ERP = cell(ncond,1);
% iterate through conditions
for ii = 1:ncond
    % randomize the timings of the stimulus events
    if ~isempty(nnull)
        tot_evt = nnull;
    else
        tot_evt = sum(stim(:,ii));
    end
    evt_idx = randperm(length(stim)-2*length(dly),tot_evt)+length(dly);
        % make sure there no delays whose samples go beyond the EEG
        % duration
    % setup the ERP array
    ERP{ii} = NaN(length(dly),nchan,length(evt_idx));
    % iterate over events
    for n = 1:length(evt_idx)
        idx = dly'+evt_idx(n);
        % if the index is beyond the size of the eeg
        if any(idx<1) || any(idx>size(eeg,1))
            % output an error
            error('ERP index is beyond the range of recorded time in the EEG');
        else
            % get the eeg segment for this event
            erp_seg = eeg(idx,:);
            % baseline
            if ~isempty(baseline) % if a baseline is provided
                bsln_idx = dly>floor(baseline(1)/1000*Fs) & dly<ceil(baseline(2)/1000*Fs);
                bsln = mean(erp_seg(bsln_idx,:)); % average across indexes in baseline range
                erp_seg = erp_seg - ones(length(dly),1)*bsln;
            end
            % add the event to the overall ERP
            ERP{ii}(:,:,n) = erp_seg;
        end
    end
end
fprintf('Completed ERP @ %.3f s \n',toc(erp_tm));

% convert delays into ms, and return the negative of the delays (easier for
% plotting)
dly = dly/Fs*1000;