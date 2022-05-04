function plot_mderp(all_erps,dly,chan_to_plot,chan_lbls,sbj,exp_condition,fl_suffix,mark_times,varargin)
% Plot the median ERP for individual channels and all channels

if nargin<7 || isempty(fl_suffix), fl_suffix=''; end

% Use the marker to indicate particular times of interest in the experiment
if nargin<8 || isempty(mark_times), mark_times=[]; end

% plotting parameters
fig_pos = [200 200 1000 550];
img_pos = [360 1 650 500];

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% mdERP = median(all_erps{1},3);
mdERP = spline_median(all_erps{1},6,3);

% Plot the ERP at each channel
mx = max(max(mdERP));
mn = min(min(mdERP));
figure
set(gcf,'Position',fig_pos);
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    subplot(ceil(length(chan_to_plot)/2),2,jj)
    hold on
    % if there are markers, plot them
    for m = 1:length(mark_times)
        plot([mark_times(m) mark_times(m)],[mn mx],'k--');
    end
    plot(dly,mdERP(:,chan),'b','LineWidth',2);
    grid;
    set(gca,'FontSize',12);
    xlabel('Delay (ms)');
    ylabel('Median ERP (\muV)');
    title(sprintf('%s, %s',sbj,chan_to_plot{jj}),'Interpreter','none');
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_mdERP_indivchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_mdERP_indivchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);

% Plot an image of the ERP
figure
set(gcf,'Position',img_pos);
imagesc(dly,1:32,mdERP');
% get maximum magnitude
mx = max(max(abs(mdERP)));
colorbar;
caxis([-mx mx]);
set(gca,'FontSize',10,'YTick',1:32,'YTickLabel',chan_lbls);
xlabel('Delay (ms)');
ylabel('Channel');
title(sbj,'Interpreter','none');
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_mdERP_allchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_mdERP_allchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);