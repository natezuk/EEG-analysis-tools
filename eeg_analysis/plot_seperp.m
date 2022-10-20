function plot_seperp(ctrl_erps,asd_erps,dly,chan_to_plot,chan_lbls,exp_condition,...
    fl_suffix,varargin)
% Plot subject ERPs separated along the y-axis (like EEG plot)

if nargin<6, exp_condition = []; end
if nargin<7, fl_suffix = ''; end

% Plotting parameters
yshift = 20; % number in uV to shift each neighboring subject
mark_times = []; % times to mark in the ERP plots
spline_ds = 6; % downsampling factor for the splines
fig_pos = [100 100 450 900];

% Parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Plot every correct/incorrect separated by subject
for c = 1:length(chan_to_plot)
    chan_idx = strcmp(chan_to_plot{c},chan_lbls);
    figure
    set(gcf,'Position',fig_pos);
    subplot(1,2,1);
    title(sprintf('Controls (N=%d)',length(ctrl_erps)));
    hold on
    for s = 1:length(ctrl_erps)
        yoffset = (s-1)*yshift;
        % Correct
        plot(dly,yoffset+spline_median(ctrl_erps{s}(:,chan_idx,:),spline_ds,3),...
            'Color','k','LineWidth',1.5);
    end
    if ~isempty(mark_times)
        for m = 1:length(mark_times)
            plot([mark_times(m) mark_times(m)],[-yshift*2 yoffset+yshift*2],'k--','LineWidth',1);
        end
    end
    set(gca,'FontSize',12,'XLim',[0 500],'YTick',0:yshift:yoffset,'YTickLabel',1:length(ctrl_erps),'YLim',[-2*yshift yoffset+yshift]);
    xlabel('Delay (ms)');
    ylabel(['ERP aligned to RT ,' chan_to_plot{c} ' (\muV)']);

    subplot(1,2,2);
    title(sprintf('ASD (N=%d)',length(asd_erps)));
    hold on
    for s = 1:length(asd_erps)
        yoffset = (s-1)*yshift;
        % Correct
        plot(dly,yoffset+spline_median(asd_erps{s}(:,chan_idx,:),spline_ds,3),...
            'Color','k','LineWidth',1.5);
    end
    if ~isempty(mark_times)
        for m = 1:length(mark_times)
            plot([mark_times(m) mark_times(m)],[-yshift*2 yoffset+yshift*2],'k--','LineWidth',1);
        end
    end
    set(gca,'FontSize',12,'XLim',[0 500],'YTick',0:yshift:yoffset,'YTickLabel',1:length(asd_erps),'YLim',[-2*yshift yoffset+yshift]);
    xlabel('Delay (ms)');
    ylabel(['ERP aligned to RT ,' chan_to_plot{c} ' (\muV)']);
    % save the file
    if ~isempty(fl_suffix)
        img_fl = sprintf('fig/AllSbj_%s_seperp_%s_%s.png',exp_condition,chan_to_plot{c},fl_suffix);
    else
        img_fl = sprintf('fig/AllSbj_%s_seperp_%s.png',exp_condition,chan_to_plot{c});
    end
    saveas(gcf,img_fl);
end