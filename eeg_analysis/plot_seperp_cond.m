function plot_seperp_cond(ctrl_erps,asd_erps,dly,cond,chan_to_plot,chan_lbls,exp_condition,...
    cond_lbl,fl_suffix,varargin)
% Plot subject ERPs separated along the y-axis (like EEG plot)

if nargin<7, exp_condition = []; end
if nargin<8, cond_lbl = {}; end
if nargin<9, fl_suffix = ''; end

% Plotting parameters
xlim = [];
yshift = 20; % number in uV to shift each neighboring subject
mark_times = []; % times to mark in the ERP plots
spline_ds = 6; % downsampling factor for the splines
fig_pos = [100 100 450 900];
leg_loc = 'northeast';
cmap = [];

% Parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

if isempty(xlim), xlim = [min(dly) max(dly)]; end

% Get the number of conditions
unq_cond = unique(cond);
ncond = length(unq_cond);

if isempty(cmap)
    % create the colormap
    cmap = colormap('hsv')*0.8;
end

% Plot every correct/incorrect separated by subject
for c = 1:length(chan_to_plot)
    % get the channel index
    chanidx = strcmp(chan_lbls,chan_to_plot{c});
    figure
    set(gcf,'Position',fig_pos);
    subplot(1,2,1);
    title(sprintf('Controls (N=%d)',length(ctrl_erps)));
    hold on
    for s = 1:length(ctrl_erps)
        yoffset = (s-1)*yshift;
        for ii = 1:ncond
            % get the color index
            clridx = get_color_idx(ii,ncond,cmap);
            % concatenate over conditions
            cond_idx = cond==unq_cond(ii);
            CTRL = cat_over_sbjs(ctrl_erps{s}(cond_idx));
            % Correct
            plot(dly,yoffset+spline_median(CTRL(:,chanidx,:),spline_ds,3),...
                'Color',cmap(clridx,:),'LineWidth',1.5);
        end
    end
    if ~isempty(mark_times)
        for m = 1:length(mark_times)
            plot([mark_times(m) mark_times(m)],[-yshift*2 yoffset+yshift*2],'k--','LineWidth',1);
        end
    end
    set(gca,'FontSize',12,'XLim',xlim,'YTick',0:yshift:yoffset,...
        'YTickLabel',1:length(ctrl_erps),'YLim',[-2*yshift yoffset+2*yshift]);
    xlabel('Delay (ms)');
    ylabel(['ERP aligned to RT ,' chan_to_plot{c} ' (\muV)']);

    subplot(1,2,2);
    title(sprintf('ASD (N=%d)',length(asd_erps)));
    hold on
    for s = 1:length(asd_erps)
        yoffset = (s-1)*yshift;
        seppl = NaN(ncond,1);
        for ii = 1:ncond
            % get the color index
            clridx = get_color_idx(ii,ncond,cmap);
            % concatenate over conditions
            cond_idx = cond==unq_cond(ii);
            ASD = cat_over_sbjs(asd_erps{s}(cond_idx));
            % Correct
            seppl(ii) = plot(dly,yoffset+spline_median(ASD(:,chanidx,:),spline_ds,3),...
                'Color',cmap(clridx,:),'LineWidth',1.5);
        end
    end
    if ~isempty(mark_times)
        for m = 1:length(mark_times)
            plot([mark_times(m) mark_times(m)],[-yshift*2 yoffset+yshift*2],'k--','LineWidth',1);
        end
    end
    set(gca,'FontSize',12,'XLim',xlim,'YTick',0:yshift:yoffset,...
        'YTickLabel',1:length(asd_erps),'YLim',[-2*yshift yoffset+2*yshift]);
    xlabel('Delay (ms)');
    ylabel(['ERP aligned to RT ,' chan_to_plot{c} ' (\muV)']);
    % if a legend for each condition was provided, use that
    if ~isempty(cond_lbl)
        legend(seppl,cond_lbl,'Location',leg_loc);
    else % otherwise, just use the condition values
        legend(seppl,unq_cond,'Location',leg_loc);
    end
    % save the file
    if ~isempty(fl_suffix)
        img_fl = sprintf('fig/AllSbj_%s_seperpbycond_%s_%s.png',exp_condition,chan_to_plot{c},fl_suffix);
    else
        img_fl = sprintf('fig/AllSbj_%s_seperpbycond_%s.png',exp_condition,chan_to_plot{c});
    end
    saveas(gcf,img_fl);
end