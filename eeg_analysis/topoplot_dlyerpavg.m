function [ctrl_v,asd_v] = topoplot_dlyerpavg(ctrl_erps,asd_erps,dly,dly_range,suffix,ylbl,varargin)
% Plot the average ERP magnitudes between two for control and ASD participants
% on an EEG topoplot.
% This requires fieldtrip.

nctrl = length(ctrl_erps);
nasd = length(asd_erps);
ncond = length(ctrl_erps{1});
if isstruct(ctrl_erps{1})
    nchan = size(ctrl_erps{1}{1},2); % get the number of channels
else
    nchan = size(ctrl_erps{1},2);
    ncond = 1;
end

if nargin < 6, ylbl = ''; end

fig_pos = [100 100 800 300];

% Parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

ctrl_v = NaN(nctrl,nchan,ncond);
for s = 1:nctrl
    for c = 1:ncond
        if isstruct(ctrl_erps{s})
            erp = spline_median(ctrl_erps{s}{c},6,3);
        else
            erp = spline_median(ctrl_erps{s},6,3);
        end
        ctrl_v(s,:,c) = calc_v_avg(erp,dly,dly_range,[]);
    end
end
asd_v = NaN(nasd,nchan,ncond);
for s = 1:nasd
    for c = 1:ncond
        if isstruct(asd_erps{s})
            erp = spline_median(asd_erps{s}{c},6,3);
        else
            erp = spline_median(asd_erps{s},6,3);
        end
        asd_v(s,:,c) = calc_v_avg(erp,dly,dly_range,[]);
    end
end

% Calculate the median values across subjects
ctrl_v = squeeze(median(ctrl_v,1));
asd_v = squeeze(median(asd_v,1));
if ncond==1
    ctrl_v = ctrl_v'; asd_v = asd_v';
end
% Calculate the range of values
minval = min([min(min(ctrl_v)), min(min(asd_v))]);
maxval = max([max(max(ctrl_v)), max(max(asd_v))]);

% Configure the topoplots
cfg = [];
cfg.layout = 'biosemi32.lay';
cfg.baselinetype = 'absolute';
layout = ft_prepare_layout(cfg);

% plot all subjects
figure
set(gcf,'Position',fig_pos);
for c = 1:ncond,
    % Controls
    subplot(ncond,2,1)
    hold on
    ft_plot_topo(layout.pos(1:nchan,1),layout.pos(1:nchan,2),ctrl_v(:,c),...
        'mask',layout.mask,'outline',layout.outline,'interplim','mask');
    caxis([minval maxval]);
    colorbar;
    set(gca,'FontSize',12,'XTick',[],'YTick',[]);
    xlabel(['Cond = ' num2str(c)]);
    ylabel(ylbl);
    if c==1, title(sprintf('Controls (N=%d)',nctrl)); end
    % ASD
    subplot(1,2,2)
    ft_plot_topo(layout.pos(1:nchan,1),layout.pos(1:nchan,2),asd_v(:,c),...
        'mask',layout.mask,'outline',layout.outline,'interplim','mask');
    caxis([minval maxval]);
    colorbar;
    set(gca,'FontSize',12,'XTick',[],'YTick',[]);
    xlabel(['Cond = ' num2str(c)]);
    if c==1, title(sprintf('ASD (N=%d)',nasd)); end
end

saveas(gcf,sprintf('fig/AllSbj_topo_dlyerpavg_%s.png',suffix));