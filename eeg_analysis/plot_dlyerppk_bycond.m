function [ctrl_v,asd_v] = plot_dlyerppk_bycond(ctrl_erps,asd_erps,dly,dir,dly_range,chan_to_avg,suffix,cond_lbls,ylbl,varargin)
% Plot the ERP magnitudes for individual control and ASD subjects with
% lines connecting the different conditions. The 'ctrl_erps' and
% 'asd_erps', are cell arrays of cell arrays. Each cell in the main array
% is for a subject, and each cell for the subject arrays correspond to
% different conditions (see plot_multisbj_cond_mderp.m, which requires an
% identical arrangement of ERPs in the input).
% For dly_range and chan_to_avg, see the inputs to calc_v_avg.m, which
% requires these inputs
% (Update 28-7-2022) Modified from plot_dlyavg_bycond, now calculating 1)
% median ERP for each subject, and 2) using the peak value of the median
% ERP.
% (Update 2-10-2022) If multiple channels are specified, first average the
% ERP over these channels, then compute the peak ERP voltage within the
% range of delays.
% Nate Zuk (2022)

nctrl = length(ctrl_erps);
nasd = length(asd_erps);
ncond = length(ctrl_erps{1});

fig_pos = [100 100 1000 350];
ctrl_clr = [0 0 1]; % color for control subjects
asd_clr = [0 0.8 0]; % color for ASD subjects

if nargin < 7 || isempty(cond_lbls)
    cond_lbls = 1:ncond;
end

if nargin < 8 || isempty(ylbl)
    ylbl = 'Values';
end

% Parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

ctrl_v = NaN(nctrl,ncond);
for s = 1:nctrl
    for c = 1:ncond
        erp = spline_median(ctrl_erps{s}{c},6,3);
        if length(chan_to_avg)>1
            % average over channels first
            erp = mean(erp(:,chan_to_avg,:),2);
            ctrl_v(s,c) = calc_v_pk(erp,dly,dir,dly_range,[]);
        else
            ctrl_v(s,c) = calc_v_pk(erp,dly,dir,dly_range,chan_to_avg);
        end
        % calculate the average voltage within the delay range and set of
        % channels specified
%         v = calc_v_avg(ctrl_erps{s}{c},dly,dly_range,chan_to_avg);
%         ctrl_v(s,c) = median(v);
    end
end
asd_v = NaN(nasd,ncond);
for s = 1:nasd
    for c = 1:ncond
        erp = spline_median(asd_erps{s}{c},6,3);
        if length(chan_to_avg)>1
            % average over channels first
            erp = mean(erp(:,chan_to_avg,:),2);
            asd_v(s,c) = calc_v_pk(erp,dly,dir,dly_range,[]);
        else
            asd_v(s,c) = calc_v_pk(erp,dly,dir,dly_range,chan_to_avg);
        end
        % calculate the average voltage within the delay range and set of
        % channels specified
%         v = calc_v_avg(asd_erps{s}{c},dly,dly_range,chan_to_avg);
%         asd_v(s,c) = median(v);
    end
end

% Stats: If # conditions > 2, use friedman test, otherwise use signrank
if ncond>2
    [p_ctrl,tbl] = friedman(ctrl_v,1,'off');
    st_ctrl = tbl{2,5};
    [p_asd,tbl] = friedman(asd_v,1,'off');
    st_asd = tbl{2,5};
    stat_used = 'Friedman';
else
    [p_ctrl,~,st] = signrank(ctrl_v(:,1),ctrl_v(:,2));
    st_ctrl = st.signedrank;
    [p_asd,~,st] = signrank(asd_v(:,1),asd_v(:,2));
    st_asd = st.signedrank;
    stat_used = 'Sign-rank';
end

% plot all subjects
figure
set(gcf,'Position',fig_pos);
% Controls
subplot(1,2,1)
hold on
plot([0 ncond+1],[0 0],'k--');
plot(1:ncond,ctrl_v,'o-','Color',(ctrl_clr*0.5)+0.5,'MarkerSize',10,'LineWidth',1);
plot(1:ncond,median(ctrl_v),'o','Color',ctrl_clr,'MarkerSize',12,'LineWidth',3);
set(gca,'FontSize',12,'XLim',[0 ncond+1],'XTick',1:ncond,'XTickLabel',cond_lbls,...
    'XTickLabelRotation',45);
ylabel(ylbl);
if strcmp(stat_used,'Friedman')
    title(sprintf('Controls (N=%d); %s: stat = %.2f, p = %.3f',nctrl,stat_used,st_ctrl,p_ctrl));
else
    title(sprintf('Controls (N=%d); %s: stat = %d, p = %.3f',nctrl,stat_used,st_ctrl,p_ctrl));
end
% ASD
subplot(1,2,2)
hold on
plot([0 ncond+1],[0 0],'k--');
plot(1:ncond,asd_v,'o-','Color',asd_clr*0.5+0.5,'MarkerSize',10,'LineWidth',1);
plot(1:ncond,median(asd_v),'o','Color',asd_clr,'MarkerSize',12,'LineWidth',3);
set(gca,'FontSize',12,'XLim',[0 ncond+1],'XTick',1:ncond,'XTickLabel',cond_lbls,...
    'XTickLabelRotation',45);
ylabel(ylbl);
if strcmp(stat_used,'Friedman')
    title(sprintf('ASD (N=%d); %s: stat = %.2f, p = %.3f',nctrl,stat_used,st_asd,p_asd));
else
    title(sprintf('ASD (N=%d); %s: stat = %d, p = %.3f',nasd,stat_used,st_asd,p_asd));
end

saveas(gcf,sprintf('fig/AllSbj_dlyerppkbycond_%s.png',suffix));