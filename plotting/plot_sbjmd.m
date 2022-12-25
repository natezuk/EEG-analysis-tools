function md_pl = plot_sbjmd(vals,sbjidx,cmap,varargin)
% Use shadedErrorBar to plot the median values across subjects and the
% standard error of the median, bootstrap resampling *within* subjects
% (this can also be used to resample across subjects, see 'sbjidx' below).
% Inputs:
% - vals: values to plot, dimensions: (subjects x reps) by x-axis ticks by
% condition
% - sbjidx: indexes indicating individual subject data, so all values in
% the first dimension of 'vals' will have sbjidx=1, the next subject will
% be 2, etc. (by default, if sbjidx is empty, then all datapoints are
% assigned to one 'subject', and resampling will be done across all
% datapoints. This is equivalen to setting 1 for all values in sbjidx)
% - cmap: colors to use for each condition (default: black for one
% condition, or 'hsv' for multiple conditions)
% Outputs:
% - md_pl = handles for each of the median lines in the plot
% Nate Zuk (2022)

nboot = 2000;
fig_handle = [];
quantile_range = [0.025 0.975];
xtick = [];
use_stderr = false;

% parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

nxtick = size(vals,2);
ncond = size(vals,3);

if isempty(xtick)
    xtick = 1:nxtick;
end

% Set the subject index (if not specified)
if isempty(sbjidx) || nargin<2
    sbjidx = ones(size(vals,1),1);
end

% get cmap if it wasn't specified
if nargin<3
    if ncond==1, cmap = [0 0 0];
    else, cmap = colormap('hsv');
    end
end

% Get the median value
md = squeeze(median(vals,1,'omitnan'));

% Bootstrap resampling across subjects
distr = NaN(nboot,nxtick,ncond);
for c = 1:ncond
    distr(:,:,c) = compute_median_distr_sbjboot(vals(:,:,c),sbjidx,nboot);
end
if use_stderr % if we should compute the standard error of the median 
    % (use the standard deviation of the bootstrapped distr)
    uq = squeeze(std(distr,[],1,'omitnan'));
    lq = squeeze(std(distr,[],1,'omitnan'));
else
    % get the upper and lower quantiles
    uq = squeeze(quantile(distr,quantile_range(2),1));
    lq = squeeze(quantile(distr,quantile_range(1),1));
end

% Make sure md, uq, and lq are column arrays
if size(md,1)==1
    md = md'; uq = uq'; lq = lq';
end

%% Plotting
if isempty(fig_handle)
    figure;
else
    gca = fig_handle;
end

md_pl = NaN(ncond,1);
for c = 1:ncond
    clr_idx = get_color_idx(c,ncond,cmap);
    if use_stderr
        pl = shadedErrorBar(xtick,md(:,c)',[uq(:,c) lq(:,c)]',...
            'lineProps',{'Color',cmap(clr_idx,:),'LineWidth',2});
    else
        pl = shadedErrorBar(xtick,md(:,c)',[uq(:,c)-md(:,c) md(:,c)-lq(:,c)]',...
            'lineProps',{'Color',cmap(clr_idx,:),'LineWidth',2});
    end
    md_pl(c) = pl.mainLine;
end
set(gca,'FontSize',12,'XTick',xtick,'XLim',[1 nxtick]);