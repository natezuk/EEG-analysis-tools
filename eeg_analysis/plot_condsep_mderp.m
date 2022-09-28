function plot_condsep_mderp(erps,dly,chan_to_plot,chan_lbls,sbj,exp_condition,row_lbl,cnd_lbl,fl_suffix,mark_times,varargin)
% Plot the median ERP of separate conditions, using different line styles 
% (solid vs dashed for example), where separate conditions are stored in 
% columns of the cell array erps. The difference between conditions in each 
% row is plotted as a separate trace.
% Nate Zuk (2022)

if nargin<7, row_lbl={}; end
if nargin<8, cnd_lbl={}; end
if nargin<9, fl_suffix=''; end
if nargin<10, mark_times=[]; end

% plotting parameters
spline_ds = 6; % downsampling factor for the splines
line_styles = {'-','--','-.'};
yax_range = [-15 20]; % range of y-axis voltages to use for plotting mark_times 
leg_loc = 'southwest';

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% get the set of unique ibis
nrow = size(erps,1);
ncond = size(erps,2); % number of conditions

% get the ERP dimensions
ndly = size(erps{1,1},1);
nchan = length(chan_lbls);

cndERP = NaN(ndly,nchan,nrow,ncond);
for ii = 1:ncond
    for c = 1:nrow
        cndERP(:,:,c,ii) = spline_median(erps{c,ii},spline_ds,3);
    end
end

% Make the legend using the row-condition labels
lg = cell(nrow*ncond,1);
for ii = 1:ncond
    for c = 1:nrow
        idx = (ii-1)*nrow + c;
        lg{idx} = [row_lbl{c} ', ' cnd_lbl{ii}];
    end
end

% Plot the ERP at each channel
figure
cmap = colormap('hsv')*0.8;
cnd_plt = NaN(nrow*ncond,1);
set(gcf,'Position',[200 200 1000 550]);
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    subplot(ceil(length(chan_to_plot)/2),2,jj)
    hold on
    % plot dashed lines for each time point that should be marked
    for m = 1:length(mark_times)
        plot([mark_times(m) mark_times(m)],yax_range,'k--');
    end
    for ii = 1:ncond
        for c = 1:nrow
            plidx = (ii-1)*nrow + c;
            clr_idx = get_color_idx(c,nrow,cmap);
            cnd_plt(plidx) = plot(dly,cndERP(:,chan,c,ii),'Color',cmap(clr_idx,:),'LineStyle',line_styles{ii},'LineWidth',1.5);
        end
    end
    grid;
    set(gca,'FontSize',12);
    xlabel('Delay (ms)');
    ylabel('Median ERP (\muV)');
    title(sprintf('%s, %s',sbj,chan_to_plot{jj}),'Interpreter','none');
end
% if a legend for each condition was provided, use that
% make the legend only in the last plot
if ~isempty(row_lbl)
    legend(cnd_plt,lg,'Location',leg_loc);
else % otherwise, just use the condition values
    legend(cnd_plt,unq_cond,'Location',leg_loc);
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_condsep_indivchans_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_condsep_indivchans.png',sbj,exp_condition);
end
saveas(gcf,img_fl);