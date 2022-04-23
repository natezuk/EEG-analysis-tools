function plot_multisbj_mderp(ctrl_erps,asd_erps,dly,chan_to_plot,chan_lbls,exp_condition,fl_suffix,varargin)
% Plot the median ERP by subject group (this is based on plot_mderp.m, but
% here we will plot the median across all ctrl subjects and asd subjects
% separately). 'ctrl_erps' and 'asd_erps' are cell arrays of erps, one cell
% per subject.
% Nate Zuk (2022)

if nargin<7, fl_suffix=''; end

% plotting parameters
fig_pos = [200 200 1000 550];
img_pos = [360 1 1300 500];
legloc = 'Southwest';
ctrl_clr = [0 0 1];
asd_clr = [0 0.8 0];

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Get the number of subjects in each group
nctrl = length(ctrl_erps);
nasd = length(asd_erps);

% Concatenate erp arrays across subjects
CTRL = cat_over_sbjs(ctrl_erps);
ASD = cat_over_sbjs(asd_erps);

% Compute the median across subjects and 
ctrlmdERP = spline_median(CTRL,6,3);
asdmdERP = spline_median(ASD,6,3);
%%% Calculate quantiles?

% Generate the figure legends for the single trace plots
mdleg{1} = sprintf('Control (N=%d)',nctrl);
mdleg{2} = sprintf('ASD (N=%d)',nasd);

% Plot the ERP at each channel
figure
set(gcf,'Position',fig_pos);
% Controls
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    subplot(ceil(length(chan_to_plot)/2),2,jj)
    hold on
    plot(dly,ctrlmdERP(:,chan),'Color',ctrl_clr,'LineWidth',2);
    plot(dly,asdmdERP(:,chan),'Color',asd_clr,'LineWidth',2);
    grid;
    set(gca,'FontSize',12);
    xlabel('Delay (ms)');
    ylabel('Median ERP (\muV)');
    title(sprintf('%s',chan_to_plot{jj}),'Interpreter','none');
end
legend(mdleg,'Location',legloc);
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/AllSbj_%s_mdERP_indivchans_%s.png',exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/AllSbj_%s_mdERP_indivchans.png',exp_condition);
end
saveas(gcf,img_fl);

% Plot an image of the ERP
figure
% Control
subplot(1,2,1);
set(gcf,'Position',img_pos);
imagesc(dly,1:32,ctrlmdERP');
% get maximum magnitude
mx = max(max(abs(ctrlmdERP)));
colorbar;
caxis([-mx mx]);
set(gca,'FontSize',10,'YTick',1:32,'YTickLabel',chan_lbls);
xlabel('Delay (ms)');
ylabel('Channel');
title(sprintf('Control (N=%d)',nctrl));
% ASD
subplot(1,2,2);
imagesc(dly,1:32,asdmdERP');
% get maximum magnitude
mx = max(max(abs(asdmdERP)));
colorbar;
caxis([-mx mx]);
set(gca,'FontSize',10,'YTick',1:32,'YTickLabel',chan_lbls);
xlabel('Delay (ms)');
ylabel('Channel');
title(sprintf('ASD (N=%d)',nasd));
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/AllSbj_%s_mdERP_allchans_%s.png',exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/AllSbj_%s_mdERP_allchans.png',exp_condition);
end
saveas(gcf,img_fl);

end