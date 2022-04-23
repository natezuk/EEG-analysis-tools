function flteeg = prefiltereeg(eeg,Fs,varargin)
% Filter the eeg using a zero-phase lowpass butterworth filter 
% Setup for Prob_sequence

N = 4; % order of the butterworth filter
Fc_low = 1; % 3 dB lower cutoff frequency of the butterworth filter
Fc_high = 30; % 3 dB upper cutoff frequency of the butterworth filter

if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Generate bandpass filter
b = fdesign.bandpass('N,F3dB1,F3dB2',N,Fc_low,Fc_high,Fs);
bpf = design(b,'butter');

flteeg = filtfilthd(bpf,eeg);