function [ERP,dly] = compute_erp(stim,eeg,Fs,mindly,maxdly,baseline,varargin)
% Compute the event-triggered EEG signal, equivalent to an ERP (event-related potential). 
% Inputs:
% - eeg = array containing EEG per trial
% - stim = array of stimulus vector for each trial (must contain 1s or 0s)
% - Fs = sampling frequency (Hz)
% - mindly = minimum possible delay of the model (ms)
% - maxdly = maximum possible delay of the model (ms)
% - baseline = two element array of delays to use as a baseline, non-inclusive (ms)
% Outputs:
% - ERP = event-related potential model (lags x channels)
% - dly = delays corresponding to the ERP (in ms)
% Nate Zuk (2021)
% ** Modified from eventtrigeeg.m, Nate Zuk, 2017

ncond = size(stim,2); % # of conditions (columns of stim)
nchan = size(eeg,2);

reject_threshold = 30; % if the uV is larger than this value (positive or negative)
    % skip this threshold

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
% Preallocated the ERP
ERP = zeros(length(dly),nchan,ncond);
% nevt_skipped = 0;
% iterate through conditions
for ii = 1:ncond
    % get the indexes of all events
    evt_idx = find(stim(:,ii));
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
            bsln_idx = dly>floor(baseline(1)/1000*Fs) & dly<ceil(baseline(2)/1000*Fs);
            bsln = mean(erp_seg(bsln_idx,:)); % average across indexes in baseline range
            erp_seg = erp_seg - ones(length(dly),1)*bsln;
            % output warning if the magnitude is greater than some
            % threshold
            if any(abs(erp_seg)>reject_threshold)
                warning('This event should be rejected');
                %%% (23-6-2021): Tested included this rejection criterion.
                %%% The ERPs did not change very much for the ones I looked
                %%% at using mastoid reference (sagi2015, Shahaf2017,
                %%% Shahaf2020)
%                 evt_idx = evt_idx - 1;
%                 continue; % skip this event
            end
            % add the event to the overall ERP
            ERP(:,:,ii) = ERP(:,:,ii) + erp_seg;
        end
    end
    % divide by the number of events (get the average)
    ERP(:,:,ii) = ERP(:,:,ii)/length(evt_idx);
end
fprintf('Completed ERP @ %.3f s \n',toc(erp_tm));

% convert delays into ms, and return the negative of the delays (easier for
% plotting)
dly = dly/Fs*1000;