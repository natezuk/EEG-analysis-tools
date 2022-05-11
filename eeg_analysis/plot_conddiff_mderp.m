function plot_conddiff_mderp(erps,dly,chan_to_plot,chan_lbls,sbj,exp_condition,row_lbl,fl_suffix,mark_times)
% Plot the difference in median ERP between two conditions, where separate
% conditions are stored in columns of the cell array erps. The difference
% between conditions in each row is plotted as a separate trace.
% Nate Zuk (2022)

if nargin<8, row_lbl={}; end
if nargin<9, fl_suffix=''; end
if nargin<10, mark_times=[]; end

% get the set of unique ibis
nrow = size(erps,1);

% get the ERP dimensions
ndly = size(erps{1,1},1);
nchan = length(chan_lbls);

diffERP = NaN(ndly,nchan,nrow);
for c = 1:nrow
    diffERP(:,:,c) = spline_median(erps{c,2},6,3) - spline_median(erps{c,1},6,3);
end

% Plot the ERP at each channel
mx = max(max(max(diffERP)));
mn = min(min(min(diffERP)));
figure
cmap = colormap('hsv')*0.8;
cnd_plt = NaN(nrow,1);
set(gcf,'Position',[200 200 1000 550]);
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    subplot(ceil(length(chan_to_plot)/2),2,jj)
    hold on
    % plot dashed lines for each time point that should be marked
    for m = 1:length(mark_times)
        plot([mark_times(m) mark_times(m)],[mn mx],'k--');
    end
    for c = 1:nrow
        clr_idx = get_color_idx(c,nrow,cmap);
        cnd_plt(c) = plot(dly,diffERP(:,chan,c),'Color',cmap(clr_idx,:),'LineWidth',1.5);
    end
    grid;
    set(gca,'FontSize',12);
    xlabel('Delay (ms)');
    ylabel('Median ERP difference (\muV)');
    title(sprintf('%s, %s',sbj,chan_to_plot{jj}),'Interpreter','none');
    % if a legend for each condition was provided, use that
    if ~isempty(row_lbl)
        legend(cnd_plt,row_lbl,'Location','southwest');
    else % otherwise, just use the condition values
        legend(cnd_plt,unq_cond,'Location','southwest');
    end
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_conddiff_indivchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_conddiff_indivchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);

% Plot an image of the ERP    
% get maximum magnitude
mx = max(max(max(abs(diffERP))));
nplot_col = ceil(sqrt(nrow));
figure
set(gcf,'Position',[100 300 900 700]);
for c = 1:nrow
    subplot(ceil(nrow/nplot_col),nplot_col,c);
    imagesc(dly,1:nchan,diffERP(:,:,c)');
    colorbar;
    caxis([-mx mx]);
    set(gca,'FontSize',10,'YTick',1:32,'YTickLabel',chan_lbls);
    xlabel('Delay (ms)');
    ylabel('Channel');
    if ~isempty(row_lbl)
        title([sbj ', ' row_lbl{c}],'Interpreter','none');
    else
        title([sbj ', ' num2str(unq_cond(c))],'Interpreter','none');
    end
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_conddiff_allchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_conddiff_allchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);