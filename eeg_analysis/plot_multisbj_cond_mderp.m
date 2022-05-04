function plot_multisbj_cond_mderp(ctrl_erps,asd_erps,dly,cond,chan_to_plot,chan_lbls,exp_condition,...
    cond_lbl,fl_suffix,varargin)
% Plot the median ERP for individual channels and all channels, overlaid
% traces by condition. Plot these separately for controls and ASD subjects, median
% across subjects.
% 'ctrl_erps' and 'asd_erps', should be a cell array of cell arrays. Each
% of the main cells correspond to the ERPs for individual subjects. It is
% assumed that the ordering of conditions is the same for each subject, so
% only one 'cond' numeric array should be provided (not a cell array).

if nargin<8 || isempty(cond_lbl), cond_lbl={}; end
if nargin<9 || isempty(fl_suffix), fl_suffix=''; end

% Plotting parameters
fig_pos = [150 0 800 900];
ylim = [-10 10];

% Parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% get the set of unique ibis
unq_cond = unique(cond);

% Get the number of subjects in each group
nctrl = length(ctrl_erps);
nasd = length(asd_erps);

% get the ERP dimensions
ndly = length(dly);
nchan = length(chan_lbls);

% Controls
ctrlmdERP = NaN(ndly,nchan,length(unq_cond));
for c = 1:length(unq_cond)
    % get the cells corresponding to this ibi
    cond_idx = find(cond==unq_cond(c));
    % create a new erp cell array containing the conditions 
    ctrl_cond = cell(nctrl*length(cond_idx),1);
    for n = 1:nctrl
        erp_cell_idx = (n-1)*length(cond_idx) + (1:length(cond_idx));
        for ii = 1:length(cond_idx)
            ctrl_cond(erp_cell_idx(ii)) = ctrl_erps{n}(cond_idx(ii));
        end
    end
    % concatenate across subjects
    CTRL = cat_over_sbjs(ctrl_cond);
    ctrlmdERP(:,:,c) = spline_median(CTRL,6,3);
end
% ASD
asdmdERP = NaN(ndly,nchan,length(unq_cond));
for c = 1:length(unq_cond)
    % get the cells corresponding to this ibi
    cond_idx = find(cond==unq_cond(c));
    % create a new erp cell array containing the conditions 
    asd_cond = cell(nasd*length(cond_idx),1);
    for n = 1:nasd
        erp_cell_idx = (n-1)*length(cond_idx) + (1:length(cond_idx));
        for ii = 1:length(cond_idx)
            asd_cond(erp_cell_idx(ii)) = asd_erps{n}(cond_idx(ii));
        end
    end
    % concatenate across subjects
    ASD = cat_over_sbjs(asd_cond);
    asdmdERP(:,:,c) = spline_median(ASD,6,3);
end

% Plot the ERP at each channel
figure
set(gcf,'Position',fig_pos);
cmap = colormap('hsv')*0.8;
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    % CONTROLS
    subplot(length(chan_to_plot),2,2*(jj-1)+1)
    hold on
    for c = 1:length(unq_cond)
        clr_idx = get_color_idx(c,length(unq_cond),cmap);
        plot(dly,ctrlmdERP(:,chan,c),'Color',cmap(clr_idx,:),'LineWidth',1.5);
    end
    grid;
    set(gca,'FontSize',12,'YLim',ylim);
    xlabel('Delay (ms)');
    ylabel('Median ERP (\muV)');
    title(sprintf('Controls (N=%d), %s',nctrl,chan_to_plot{jj}),'Interpreter','none');
    % ASD
    subplot(length(chan_to_plot),2,2*(jj-1)+2)
    hold on
    for c = 1:length(unq_cond)
        clr_idx = get_color_idx(c,length(unq_cond),cmap);
        plot(dly,asdmdERP(:,chan,c),'Color',cmap(clr_idx,:),'LineWidth',1.5);
    end
    grid;
    set(gca,'FontSize',12,'YLim',ylim);
    xlabel('Delay (ms)');
    ylabel('Median ERP (\muV)');
    title(sprintf('ASD (N=%d), %s',nasd,chan_to_plot{jj}),'Interpreter','none');
    % if a legend for each condition was provided, use that
    if ~isempty(cond_lbl)
        legend(cond_lbl,'Location','southeast');
    else % otherwise, just use the condition values
        legend(unq_cond,'Location','southeast');
    end
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/AllSbj_%s_mdERPbycond_indivchans_%s.png',exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/AllSbj_%s_mdERPbycond_indivchans.png',exp_condition);
end
saveas(gcf,img_fl);