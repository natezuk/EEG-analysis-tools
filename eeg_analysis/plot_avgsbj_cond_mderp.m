function plot_avgsbj_cond_mderp(ctrl_erps,asd_erps,dly,cond,chan_to_plot,chan_lbls,exp_condition,...
    cond_lbl,fl_suffix,varargin)
% Plot the median ERP for individual channels and all channels, overlaid
% traces by condition. Plot these separately for controls and ASD subjects,
% *average* across subjects.
% 'ctrl_erps' and 'asd_erps', should be a cell array of cell arrays. Each
% of the main cells correspond to the ERPs for individual subjects. It is
% assumed that the ordering of conditions is the same for each subject, so
% only one 'cond' numeric array should be provided (not a cell array).
% (Update, 25-7-2022) This new function was modified from
% plot_multisbj_cond_mderp. Now we compute the median ERP for each subject,
% then the median across subject median ERPs. shadedErrorBar is used to
% also plot the standard error of the median using bootstrapped resampling
% of subject median ERPs.
% (Update, 8-4-2022) Changed standard error quantiles to 2.5% and 97.5% for
% the 95% confidence interval (before it was 90% confidence interval)

if nargin<8 || isempty(cond_lbl), cond_lbl={}; end
if nargin<9 || isempty(fl_suffix), fl_suffix=''; end

% Plotting parameters
fig_pos = [150 0 800 900];
ylim = [-10 10];
leg_loc = 'southeast';
% stderr_quantiles = [0.025 0.975];
spline_ds = 6; % (20-9-2022) Allow user to specify the downsampling spline if desired

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
ctrllqERP = NaN(ndly,nchan,length(unq_cond));
ctrluqERP = NaN(ndly,nchan,length(unq_cond));
for c = 1:length(unq_cond)
    % get the cells corresponding to this condition
    cond_idx = cond==unq_cond(c);
    % create a new erp cell array containing the conditions 
    ctrl_cond = NaN(ndly,nchan,nctrl);
    for n = 1:nctrl
        % Concatenate all subject data for a single condition (could be in
        % separate cells if pairs of experiment parameters are used)
        CTRL = cat_over_sbjs(ctrl_erps{n}(cond_idx));
        ctrl_cond(:,:,n) = spline_median(CTRL,spline_ds,3);
    end
    % Compute the median across subject median ERPs
    ctrlmdERP(:,:,c) = mean(ctrl_cond,3,'omitnan');
    ctrllqERP(:,:,c) = mean(ctrl_cond,3,'omitnan') - std(ctrl_cond,[],3,'omitnan')/sqrt(nctrl);
    ctrluqERP(:,:,c) = mean(ctrl_cond,3,'omitnan') + std(ctrl_cond,[],3,'omitnan')/sqrt(nctrl);
end
% ASD
asdmdERP = NaN(ndly,nchan,length(unq_cond));
asdlqERP = NaN(ndly,nchan,length(unq_cond));
asduqERP = NaN(ndly,nchan,length(unq_cond));
for c = 1:length(unq_cond)
    % get the cells corresponding to this condition
    cond_idx = cond==unq_cond(c);
    % create a new erp cell array containing the conditions 
    asd_cond = NaN(ndly,nchan,nctrl);
    for n = 1:nasd
        % Concatenate all subject data for a single condition (could be in
        % separate cells if pairs of experiment parameters are used)
        ASD = cat_over_sbjs(asd_erps{n}(cond_idx));
        asd_cond(:,:,n) = spline_median(ASD,spline_ds,3);
    end
    % Compute the median across subject median ERPs
    asdmdERP(:,:,c) = mean(asd_cond,3,'omitnan');
    asdlqERP(:,:,c) = mean(asd_cond,3,'omitnan') - std(asd_cond,[],3,'omitnan')/sqrt(nasd);
    asduqERP(:,:,c) = mean(asd_cond,3,'omitnan') + std(asd_cond,[],3,'omitnan')/sqrt(nctrl);
end

% Plot the ERP at each channel
figure
set(gcf,'Position',fig_pos);
cmap = colormap('hsv')*0.8;
for jj = 1:length(chan_to_plot)
    % get the index for the channel
    chan = strcmp(chan_lbls,chan_to_plot{jj});
    mdpl = NaN(length(unq_cond),1);
    % CONTROLS
    subplot(length(chan_to_plot),2,2*(jj-1)+1)
    hold on
    for c = 1:length(unq_cond)
        clr_idx = get_color_idx(c,length(unq_cond),cmap);
%         plot(dly,ctrlmdERP(:,chan,c),'Color',cmap(clr_idx,:),'LineWidth',1.5);
        shadedErrorBar(dly,ctrlmdERP(:,chan,c),[ctrluqERP(:,chan,c)'-ctrlmdERP(:,chan,c)';...
            ctrlmdERP(:,chan,c)'-ctrllqERP(:,chan,c)'],...
            'lineProps',{'Color',cmap(clr_idx,:),'LineWidth',2});
    end
    grid;
    set(gca,'FontSize',12,'YLim',ylim);
    xlabel('Delay (ms)');
    ylabel('Average ERP (\muV)');
    title(sprintf('Controls (N=%d), %s',nctrl,chan_to_plot{jj}),'Interpreter','none');
    % ASD
    subplot(length(chan_to_plot),2,2*(jj-1)+2)
    hold on
    for c = 1:length(unq_cond)
        clr_idx = get_color_idx(c,length(unq_cond),cmap);
%         plot(dly,asdmdERP(:,chan,c),'Color',cmap(clr_idx,:),'LineWidth',1.5);
        pl = shadedErrorBar(dly,asdmdERP(:,chan,c),[asduqERP(:,chan,c)'-asdmdERP(:,chan,c)';...
            asdmdERP(:,chan,c)'-asdlqERP(:,chan,c)'],...
            'lineProps',{'Color',cmap(clr_idx,:),'LineWidth',2});
        mdpl(c) = pl.mainLine;
    end
    grid;
    set(gca,'FontSize',12,'YLim',ylim);
    xlabel('Delay (ms)');
    ylabel('Average ERP (\muV)');
    title(sprintf('ASD (N=%d), %s',nasd,chan_to_plot{jj}),'Interpreter','none');
    % if a legend for each condition was provided, use that
    if ~isempty(cond_lbl)
        legend(mdpl,cond_lbl,'Location',leg_loc);
%         legend(cond_lbl,'Location',leg_loc);
    else % otherwise, just use the condition values
        legend(mdpl,unq_cond,'Location',leg_loc);
%         legend(unq_cond,'Location',leg_loc);
    end
end
if ~isempty(fl_suffix)
    img_fl = sprintf('fig/AllSbj_%s_avgsbjbycond_indivchans_%s.png',exp_condition,fl_suffix);
else
    img_fl = sprintf('fig/AllSbj_%s_avgsbjbycond_indivchans.png',exp_condition);
end
saveas(gcf,img_fl);