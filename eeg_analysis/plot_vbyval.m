function plot_vbyval(erps,val,dly,dly_range,chans_to_avg,sbj,exp_condition,val_axis,cond_lbl,fl_suffix,varargin)
% Plot the ERP voltages within a particular delay range, or averaged across a set
% of channels, ordered by the values in 'val'. If erps contains multiple
% conditions (multiple cells), then val must have the same number of
% columns as the number of cells in erps.
% Nate Zuk (2022)

nbins = 10;
quantiles = [0.25 0.75];
baseline = [900 1100];

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

ncond = length(erps);
v = NaN(size(val));
for ii = 1:ncond
%     v(:,ii) = calc_v_avg(erps{ii},dly,dly_range,chans_to_avg)...
%         - calc_v_avg(erps{ii},dly,baseline,chans_to_avg);
    v(:,ii) = calc_v_avg(erps{ii},dly,dly_range,chans_to_avg);
end

figure
hold on
cmap = colormap('hsv')*0.8;
cnd_plt = NaN(ncond,1);
for ii = 1:ncond
    % get the voltages, median within each bin of values
    [ymd,yquantiles,xbins] = distr_by_xbins(val(:,ii),v(:,ii),quantiles,nbins);
    xcnt = xbins(1:end-1) + diff(xbins)/2;
    % plot
    clr_idx = get_color_idx(ii,ncond,cmap);
    cnd_plt(ii) = plot(xcnt,ymd,'Color',cmap(clr_idx,:),'LineWidth',2);
    plot(xcnt,yquantiles(:,1),'--','Color',cmap(clr_idx,:),'LineWidth',2);
    plot(xcnt,yquantiles(:,2),'--','Color',cmap(clr_idx,:),'LineWidth',2);
end
set(gca,'FontSize',12);
xlabel(val_axis);
ylabel([sprintf('Voltage, %d - %d ms ',dly_range(1),dly_range(2)) '(\muV)']);
legend(cnd_plt,cond_lbl);
if ~isempty(fl_suffix)
    saveas(gcf,sprintf('fig/%s_%s_vbyval_%s.png',sbj,exp_condition,fl_suffix));
else
    saveas(gcf,sprintf('fig/%s_%s_vbyval.png',sbj,exp_condition));
end