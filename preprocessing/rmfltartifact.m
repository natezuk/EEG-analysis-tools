function neweeg = rmfltartifact(eeg,Fs,varargin)
% Remove artifacts at the start and end of the eeg signal caused by the
% filtering process.
% Inputs:
% - eeg = eeg signal (time x channel)
% - Fs = sampling frequency (Hz)
% Outputs:
% - neweeg = eeg with artifacts removed
% Edited for Prob_Sequence

% Filter parameters
N = 4; % order of the butterworth filter
Fc_low = 1; % 3 dB lower cutoff frequency of the butterworth filter
Fc_high = 30; % 3 dB upper cutoff frequency of the butterworth filter

if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Remove artifacts produced by the filter using linear regression
dltstart = [1; zeros(size(eeg,1)-1,1)]; %starting artifact
artfct = prefiltereeg(dltstart,Fs,'N',N,'Fc_low',Fc_low,'Fc_high',Fc_high);
b = artfct \ eeg;
neweeg = eeg-artfct*b;

dltend = [zeros(size(eeg,1)-1,1); 1]; %ending artifact
artfct = prefiltereeg(dltend,Fs,'N',N,'Fc_low',Fc_low,'Fc_high',Fc_high);
b = artfct \ neweeg;
neweeg = neweeg-artfct*b;