function [erps,dly,trig_vals,chan_lbls,null_erp] = calc_all_erps(eeg_fl,triggers,erp_range,baseline,reference,...
    sound_delay,desiredFs)
% Load a file with EEG, and get all event-related potentials (not averaged)
% Nate Zuk (2021)

if nargin<7
    desiredFs = 256; % specify a sampling rate to use
end

% Load the preprocessed data
d = load(eeg_fl);
disp(eeg_fl);
% Get data
eeg = d.eeg;
eFs = d.eFs;
nose = d.nose;
mastoids = d.mastoids;
trigs = d.trigs;
% If the desired sampling rate is different than the recorded sampling
% rate, downsample the EEG and triggers
%%% Can't do this because some triggers have only one sample at the higher
%%% sampling rate (ELSP1904)
% if eFs~=desiredFs
%     warning('Resampling from %d to %d Hz...',eFs,desiredFs);
%     eeg = nt_resample(eeg,desiredFs,eFs);
%     trigs = downsample(trigs,eFs/desiredFs);
%     eFs = desiredFs;
% end
% retain only the trigger onsets
difftrigs = [0; diff(trigs)];
trigs(difftrigs<=0) = 0;
% Setup the stimulus matrix (each row is a different condition)
stim = zeros(length(trigs),1);
% check if the second digit of the trigger matches the floor(iti)
trig_onsets = find(any(trigs==triggers,2));
trig_vals = trigs(trig_onsets);
% store the index for the block start, but offset by sound_delay
sound_delay_idx = round(sound_delay/1000*eFs);
stim(trig_onsets + sound_delay_idx) = 1;
% Remove the reference
veeg = var(eeg);
fprintf('EEG channel variance: %.3f [%.3f %.3f]\n',...
    median(veeg),quantile(veeg,0.25),quantile(veeg,0.75));
if strcmp(reference,'nose')
    fprintf('Nose variance: %.3f\n',var(nose));
    reeg = eeg - nose*ones(1,size(eeg,2));
elseif strcmp(reference,'mastoids')
    fprintf('Mastoids variance: %.3f, %.3f\n',var(mastoids(:,1)),var(mastoids(:,2)));
    use_mastoids = var(mastoids)<3*quantile(veeg,0.75);
    if any(use_mastoids==0)
        if sum(use_mastoids==0)==2
            warning('** Both mastoid channels are bad, using P7 / P8 instead...');
            use_mastoids = [1 1];
            pchans = [11 20];
            mastoids = eeg(:,pchans);
        else
            warning('Mastoid channel %d was rejected',find(use_mastoids==0));
        end
    end
    reeg = eeg - mean(mastoids(:,use_mastoids),2)*ones(1,size(eeg,2));
end
% Calculate the ERP
[erps,dly] = get_all_erps(stim,reeg,d.eFs,erp_range(1),erp_range(2),...
    baseline);
% If the EEG was sampled differently than the desired sampling rate,
% resample
if eFs~=desiredFs
    warning('Resampling from %d to %d Hz',eFs,desiredFs);
    dly_rsmp = floor(erp_range(1)/1000*desiredFs):ceil(erp_range(2)/1000*desiredFs);
    erp_rsmp = NaN(length(dly_rsmp),size(erps{1},2),size(erps{1},3));
    for ii = 1:size(erps{1},3)
        erp_rsmp(:,:,ii) = nt_resample(erps{1}(:,:,ii),length(dly_rsmp),length(dly));
    end
    erps = {erp_rsmp};
    dly = dly_rsmp/desiredFs*1000;
end
chan_lbls = d.chan_lbls;
% Calculate a set of null erps if desired
if nargout==5
    % Create a set of fake erps
    null_erp = fake_erps(stim,reeg,d.eFs,erp_range(1),erp_range(2),...
        baseline,1000);
end