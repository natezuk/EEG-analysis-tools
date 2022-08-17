function plot_wavelet(all_erps,dly,chan_to_plot,chan_lbls,sbj,exp_condition,fl_suffix,mark_times,varargin)
% Plot the mean wavelet transform (using analytic Morlet wavelets) for
% specified channels

if nargin<7 || isempty(fl_suffix), fl_suffix=''; end

% Use the marker to indicate particular times of interest in the experiment
if nargin<8 || isempty(mark_times), mark_times=[]; end

% plotting parameters
img_pos = [100 100 1000 550];
freq_limits = [1 50]; % frequency limits
nytick = 10; % number of y-axis labels (frequencies labeled)

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Calculate the sampling frequency based on the delay vector
Fs = 1000/(dly(2)-dly(1));
ntr = size(all_erps{1},3); % number of trials

% Compute the continuous wavelet transform using analytic morlet wavelets
nfreq = floor(10*(log2(freq_limits(2)/freq_limits(1))))+1; % calculate the number of frequencies, 10 voices per octave
CW = NaN(length(dly),nfreq,length(chan_to_plot),ntr);
for n = 1:ntr
    for ii = 1:length(chan_to_plot)
        chan_idx = strcmp(chan_to_plot{ii},chan_lbls);
        % check if any values are NaN
        if sum(isnan(all_erps{1}(:,chan_idx,n)))>0
            warning('Trial %d chan %s contains NaNs',n,chan_to_plot{ii});
        else
            [cw,freq] = cwt(all_erps{1}(:,chan_idx,n),'amor',Fs,'FrequencyLimits',freq_limits);
            CW(:,:,ii,n) = cw';
        end
    end
end

% Plot an image of the ERP
freq_lbls = round(linspace(1,nfreq,nytick));
nplot_col = ceil(sqrt(length(chan_to_plot)));
figure
set(gcf,'Position',img_pos);
for c = 1:length(chan_to_plot)
    subplot(ceil(length(chan_to_plot)/nplot_col),nplot_col,c);
    imagesc(dly,1:nfreq,median(abs(CW(:,:,c,:)),4,'omitnan')');
    colorbar;
    hold on
    % plot the mark_times
    for m = 1:length(mark_times)
        plot(mark_times(m)*[1 1],[1 nfreq],'r--','LineWidth',1.5);
    end
    set(gca,'FontSize',10,'YTick',freq_lbls,'YTickLabel',freq(freq_lbls));
    xlabel('Delay (ms)');
    ylabel('Frequency (Hz)');
    title(sprintf('%s, %s',sbj,chan_to_plot{c}),'Interpreter','none');
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_timefreq_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_timefreq.png',sbj,exp_condition);
end
saveas(gcf,img_fl);