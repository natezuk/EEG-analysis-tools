function plot_erpbyval(erps,vals,dly,chan_to_plot,chan_lbls,val_lbl,sbj,exp_condition,fl_suffix,varargin)
% Plot each ERP sorted by the values associated with each trial. 
% If any values are NaN, those ERPs are skipped when plotting.

if nargin<10, fl_suffix=''; end
% if nargin<10, mark_times=[]; end

% indiv_chan_pos = [200 200 1000 550];
all_chan_pos = [100 100 900 800];
nytick = 20;
crange = [-50 50];
smooth_wnd = 13; % size of smoothing window
% leg_loc = 'southeast';

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Sort the values
[srtv,idx] = sort(vals); % ascending

% Plot an image of the ERP    
% get maximum magnitude
nplot_col = ceil(sqrt(length(chan_to_plot)));
val_ticks = round(linspace(1,length(srtv),nytick));
figure
set(gcf,'Position',all_chan_pos);
for c = 1:length(chan_to_plot)
    chan_idx = strcmp(chan_to_plot{c},chan_lbls);
    subplot(ceil(length(chan_to_plot)/nplot_col),nplot_col,c);
    erp_set = squeeze(erps{1}(:,chan_idx,idx))';
    % apply a gaussian smoothing window
    erp_set = smoothdata(erp_set,1,'gaussian',smooth_wnd);
    imagesc(dly,1:length(srtv),erp_set);
    colorbar;
    caxis(crange);
    set(gca,'FontSize',10,'YTick',val_ticks,'YTickLabel',srtv(val_ticks));
    xlabel('Delay (ms)');
    ylabel(val_lbl);
    title([sbj ', ' chan_to_plot{c}],'Interpreter','none');
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/%s_%s_erpbyval_%s.png',sbj,exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/%s_%s_erpbyval.png',sbj,exp_condition);
end
saveas(gcf,img_fl);