function [icasig,A,eeg_center,W] = icaexamineeeg(EEG,Fs)
% Concatenate the EEG signal across trials and compute the ICA components
% NZ (23-12-2019) -- Using Fieldtrip to make topoplots
% NZ (2-4-2021) -- Include eeg_center as output array, which retains the
% average of each EEG channel (channels are zero-centered before
% transforming via ICA)

numIC = 20;

if iscell(EEG),
    disp('Concatenating the trials...');
    eeg = [];
    for ii = 1:length(EEG), % concatenate the EEG signal
        eeg = [eeg; EEG{ii}];
    end
else
    eeg = EEG;
end

eeg_center = mean(eeg);

% Compute the ICA components of the eeg
[icasig,A,W] = fastica(eeg','numOfIC',numIC,'interactivePCA','on','g','gauss');

% Plot the results
EEGplot(icasig',Fs,1);
ylabel('Component');

% Plot the topographies of each component
pcprplt = 5;
cfg = [];
cfg.layout = 'biosemi32.lay';
cfg.baselinetype = 'absolute';
layout = ft_prepare_layout(cfg); % get the layout of the channels
% nchan = size(A,1); % get the number of channels
nchan = 32;
figure
for ii = 1:size(A,2)
    subplot(5,ceil(size(icasig,1)/pcprplt),ii);
%     topoplot(A(:,ii),'chanlocs.xyz');
    ft_plot_topo(layout.pos(1:nchan,1),layout.pos(1:nchan,2),A(1:nchan,ii),...
        'mask',layout.mask,'outline',layout.outline,'interplim','mask');
    title(['Component #' num2str(ii)]);
end

% Plot the average variance contributed by each component
figure
for ii = 1:ceil(size(icasig,1)/pcprplt),
    subplot(ceil(size(icasig,1)/pcprplt),1,ii);
    if ii*pcprplt>size(A,2),
        pcplt = (ii-1)*pcprplt+1:size(A,2);
    else
        pcplt = (ii-1)*pcprplt+1:ii*pcprplt;
    end
    plot(A(:,pcplt).^2./var(eeg)');
%     plot(A(:,pcplt).^2);
    pcleg = cell(length(pcplt),1);
    for jj = 1:length(pcplt),
        pcleg{jj} = num2str(pcplt(jj));
    end
    legend(pcleg)
end
xlabel('Component');
ylabel('Variance');