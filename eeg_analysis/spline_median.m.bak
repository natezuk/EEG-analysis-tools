function [md,mddistr] = spline_median(x,ds,dim,sbj_lbls,varargin)
% Calculate the median across the dimension specified, after computing the
% B-spline coefficients approximating a smoother representation of the data
% along the first dimension of x (for example, smoothing along delays). Up
% to 4 dimensions are allowed
% If sbj_lbls is specified, then calculate the distribution of median
% values using resampling with replacement within subjects. The last
% dimension must be 

if nargin<4 || isempty(sbj_lbls)
    sbj_lbls = [];
end

nboot = 100; % number of permutations for calculating the median distribution

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

ndly = size(x,1); % compute the number of sample points along the dimension
% calculate the spline transformation matrices
spline_matrix = spline_transform(1:ndly,ds);
spline_inv = (spline_matrix'*spline_matrix)^(-1)*spline_matrix';

% calculate the spline median
md = spl_md(x,spline_matrix,spline_inv,dim);

% if sbj_lbls is not empty, calculate the distribution of medians too
if ~isempty(sbj_lbls)
    dim_idx = setxor(1:4,dim);
    mddistr = NaN([nboot size(x,dim_idx)]);
    for b = 1:nboot
        if mod(b,10)==0, fprintf('.'); end
        rsmp_idx = sbjboot(sbj_lbls);
        % assume the resampled dimension is 'dim'
        xidx = {1:ndly,1:size(x,2),1:size(x,3),1:size(x,4)};
        xidx{dim} = rsmp_idx;
        mddistr(b,:,:,:) = spl_md(x(xidx{:}),spline_matrix,spline_inv,dim);
    end
    fprintf('\n');
end


function md = spl_md(x,spline_matrix,spline_inv,dim)
% setup
size_x = size(x,1:4); % get the size of all dimensions of x
size_splx = size_x; % get the dimensions for x, the first dimension size will be changed
size_splx(1) = size(spline_matrix,2); % reduce the size of the delay dimension
splx = NaN(size_splx);
% Transform to spline coefficients
for kk = 1:size_splx(4)
    for jj = 1:size_splx(3)
        for ii = 1:size_splx(2)
            splx(:,ii,jj,kk) = spline_inv*x(:,ii,jj,kk);
        end
    end
end

% Compute the median across the desired dimension (skip NaNs)
splmd = median(splx,dim,'omitnan');

% Transform back to delays
dim_idx = setxor(1:4,dim);
md = NaN(size_x(dim_idx));
for jj = 1:size_x(dim_idx(3))
    for ii = 1:size_x(dim_idx(2))
        md(:,ii,jj) = spline_matrix*splmd(:,ii,jj);
    end
end