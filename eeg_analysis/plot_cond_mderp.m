function plot_cond_mderp(erps,dly,cond,chan_to_plot,chan_lbls,sbj,exp_condition,cond_lbl,fl_suffix,mark_times,varargin)
% Plot the median ERP for individual channels and all channels, overlaid
% traces by condition ('erps' should be a cell array of blocks corresponding
% to different conditions, repeated conditions are combined when computing the median)

if nargin<8, cond_lbl={}; end
if nargin<9, fl_suffix=''; end
if nargin<10, mark_times=[]; end

indiv_chan_pos = [200 200 1000 550];
all_chan_pos = [100 100 900 800];
leg_loc = 'southeast';

% get the set of unique ibis
unq_cond = unique(cond);

% get the ERP dimensions
ndly = size(erps{1},1);
nchan = length(chan_lbls);

mdERP = NaN(ndly,nchan,length(unq_cond));
for c = 1:length(unq_cond)
    % get the cells corresponding to this ibi
    cond_idx = find(cond==unq_cond(c));
    % concatenate those cells together along the 3rd dimension
    tottr = [0; cumsum(cellfun(@(x) size(x,3),erps(cond_idx)))];
    allerp = NaN(ndly,nchan,tottr(end));
    for b = 1:length(cond_idx)
        tr_idx = tottr(b)+1:tottr(b+1);
        allerp(:,:,tr_idx) = erps{cond_idx(b)};
    end
%     mdERP(:,:,c) = median(allerp,3,'omitnan');
    mdERP(:,:,c) = spline_median(allerp,6,3);
end

% Plot the ERP at each channel
mx = max(max(max(mdERP)));
mn = min(min(min(mdERP)));
figure
cmap = colormap('hsv')*0.8;
cnd_plt = NaN(length(unq_cond),1);
set(gcf,'Position',indiv_chan_pos);
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    subplot(ceil(length(chan_to_plot)/2),2,jj)
    hold on
    % plot dashed lines for each time point that should be marked
    for m = 1:length(mark_times)
        plot([mark_times(m) mark_times(m)],[mn mx],'k--');
    end
    for c = 1:length(unq_cond)
        clr_idx = get_color_idx(c,length(unq_cond),cmap);
        cnd_plt(c) = plot(dly,mdERP(:,chan,c),'Color',cmap(clr_idx,:),'LineWidth',1.5);
    end
    grid;
    set(gca,'FontSize',12);
    xlabel('Delay (ms)');
    ylabel('Median ERP (\muV)');
    title(sprintf('%s, %s',sbj,chan_to_plot{jj}),'Interpreter','none');
    % if a legend for each condition was provided, use that
    if ~isempty(cond_lbl)
        legend(cnd_plt,cond_lbl,'Location',leg_loc);
    else % otherwise, just use the condition values
        legend(cnd_plt,unq_cond,'Location',leg_loc);
    end
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_mdERPbycond_indivchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_mdERPbycond_indivchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);

% Plot an image of the ERP    
% get maximum magnitude
nplot_col = ceil(sqrt(length(unq_cond)));
mx = max(max(max(abs(mdERP))));
figure
set(gcf,'Position',all_chan_pos);
for c = 1:length(unq_cond)
    subplot(ceil(length(unq_cond)/nplot_col),nplot_col,c);
    imagesc(dly,1:nchan,mdERP(:,:,c)');
    colorbar;
    caxis([-mx mx]);
    set(gca,'FontSize',10,'YTick',1:32,'YTickLabel',chan_lbls);
    xlabel('Delay (ms)');
    ylabel('Channel');
    if ~isempty(cond_lbl)
        title([sbj ', ' cond_lbl{c}],'Interpreter','none');
    else
        title([sbj ', ' num2str(unq_cond(c))],'Interpreter','none');
    end
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_mdERPbycond_allchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_mdERPbycond_allchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);