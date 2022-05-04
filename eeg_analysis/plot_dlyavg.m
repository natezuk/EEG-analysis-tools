function plot_dlyavg(ctrl_erps,asd_erps,dly,dly_range,chan_to_avg,ylbl,suffix,varargin)
% Compute the average voltage within a range of delays and channels
% specified, and use dot_median_plot to plot the averages for each group

fig_pos = [380 630 380 340];
ctrl_clr = [0 0 1];
asd_clr = [0 0.8 0];
legloc = 'northeast';

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Examine the difference in average voltages over the delays and channels
% specified
ctrl_v = NaN(length(ctrl_erps),1);
for s = 1:length(ctrl_erps)
    v = calc_v_avg(ctrl_erps{s},dly,dly_range,chan_to_avg);
    ctrl_v(s) = median(v,'omitnan');
end
asd_v = NaN(length(asd_erps),1);
for s = 1:length(asd_erps)
    v = calc_v_avg(asd_erps{s},dly,dly_range,chan_to_avg);
    asd_v(s) = median(v,'omitnan');
end
% Generate the labels to plot controls and ASD data appropriately (around
% same x point as different colors)
dotmdlbls = {ones(length(ctrl_erps),1),ones(length(asd_erps),1)};
% Plot the differences across subjects
md_h = dot_median_plot(dotmdlbls,{ctrl_v, asd_v},[ctrl_clr; asd_clr]);
set(gcf,'Position',fig_pos);
set(gca,'XTickLabel','');
legend(md_h,{'Controls','ASD'},'Location',legloc);
ylabel(ylbl);
[p_v,~,st_v] = ranksum(ctrl_v,asd_v);
title(sprintf('Rank-sum: U = %.0f, p = %.3f',st_v.ranksum,p_v));
saveas(gcf,sprintf('fig/AllSbj_%s.png',suffix));