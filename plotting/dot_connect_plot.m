function grp_handles = dot_connect_plot(yvals,cond_lbl,cmap,varargin)
% Plot paired y-values connected with lines between conditions. Groups are
% plotted spaced along the x-axis. The median of each condition is plotted
% with thicker circles that are not connected between conditions. (Note:
% The median is calculated without omitting NaN values)
% Inputs:
% - yvals: A 2D numeric array OR a cell array containing 2D numeric arrays.
%   -- In the array, each row contains paired datapoints, and each column
%   corresponds to a separate condition. These datapoints will be painted in black.
%   -- If yvals is a cell array containing multiple cells, each 2D numeric
%   array will be plotted separately along the x-axis using a different
%   color. Each cell of yvales must contain the same number of columns.
% - cond_lbl: a cell array of column (condition) labels, used for the x-axis
%   in the plot
% - (optional) cmap = 64x3 dimension matrix specifying the rgb values of
%   the colormap to use (only used if there is more than one cell in
%   yvals)
% Outputs:
% - grp_handles = handle labels for the median circles for each group
% (Update, 28-9-2022): Median uses 'omitnan'

% plotting parameters
indiv_circ_size = 10; % size of the circles for individual datapoints
md_circ_size = 14; % size of the circles for medians
indiv_line_width = 1.5; % width of the individual lines and circle lines
md_line_width = 3; % width of the median circle line (medians are not connected between conditions)
group_span = 0.5; % span, in x-values, of all conditions for a single group 
    % (centers of each group are a value of 1 apart)
fig_handle = []; % figure handle

% Parse varargin
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

if ~iscell(yvals) % if it's not a cell array, split columns into separate cells
    yvals = {yvals};
end

% Get the number of groups (number of cells)
ncells = length(yvals);

% Make sure the conditions labels are the same length as the number of
% columns in all yvals cells
nconds = cellfun(@(x) size(x,2),yvals);
if any(length(cond_lbl)~=nconds)
    error('cond_lbl length must be the same as the number of columns in ALL yvals arrays');
end
nconds = nconds(1); % just get the first entry, since they are all the same

% Check if a figure handle was specified, or make a new one
if ~isempty(fig_handle)
    gca = fig_handle;
else
    figure;
    gca = axes;
end
if nargin<3 || isempty(cmap) % if the colormap isn't defined
    cmap = colormap('jet');
end

% setup x-axis locations for conditions and groups
grp_cnt = 1:ncells; % centers of each group on the x axis
xpos_cond = linspace(-group_span/2,group_span/2,nconds);
grp_handles = NaN(ncells,1);
all_xtick = NaN(1,ncells*nconds); % will be used to store all xtick values for labeleing
hold on
for n = 1:ncells
    % get the color to plot
    % If there's more than one repeat, use different colors
    if ncells==1
        clr = [0 0 0]; % otherwise use black
    else
        if size(cmap,2)>ncells
            cidx = round((n-1)/ncells*(size(cmap,1)-1))+1;
        else
            cidx = n;
        end
        clr = cmap(cidx,:);
    end
    % plot the individual circles in a slightly lighter color
    plot(grp_cnt(n)+xpos_cond,yvals{n},'-o','Color',clr*0.5+0.5,...
        'LineWidth',indiv_line_width,'MarkerSize',indiv_circ_size);
    grp_handles(n) = plot(grp_cnt(n)+xpos_cond,median(yvals{n},'omitnan'),'o',...
        'Color',clr,'LineWidth',md_line_width,'MarkerSize',md_circ_size);
    % store the xticks
    idx = (1:nconds)+(n-1)*nconds;
    all_xtick(idx) = grp_cnt(n)+xpos_cond;
end
% label the conditions on the x axis
set(gca,'FontSize',12,'XTick',all_xtick,'XTickLabel',cond_lbl);
