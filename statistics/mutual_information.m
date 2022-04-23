function [MI,pxy,px,py,xedges,yedges] = mutual_information(x,y,nbins)
% Compute the mutual information between vectors x and y, computed in bits.
% Inputs:
% - x, y = input arrays
% - nbins = number of bins with which to compute probabilities 
%     (default = 50)
% Outputs:
% - MI = mutual information, in bits
% - pxy = joint probability distribution
% - px, py = marginal probability distributions of x and y
% - xedges, yedges = edges of the bins at which the probabilites were
%     computed
% Nate Zuk (2020)

if nargin<3, nbins = 50; end

if length(x)~=length(y)
    error('x and y must have the same length');
end

% check to make sure there are at least nbins unique values in x and y,
% otherwise reduce the number of bins
if length(unique(x))<nbins
    warning('Reducing nbins to %d based on # unique values of x...',length(unique(x)));
    nbins = length(unique(x));
end
if length(unique(y))<nbins
    warning('Reducing nbins to %d based on # unique values of y...',length(unique(y)));
    nbins = length(unique(y));
end

% Identify bin sizes based on even organization of the sorted values of x
% and y. This ensures that every bin has at least one element of x and y (no
% bins with zero elements).
srt_x = sort(unique(x));
nelems_x = length(srt_x); % get the number of elements of x
xedges = [srt_x(round(linspace(1,nelems_x,nbins))); 2*srt_x(end)-srt_x(end-1)];
    % include last element twice, so it is included in last bin

srt_y = sort(unique(y));
nelems_y = length(srt_y);
yedges = [srt_y(round(linspace(1,nelems_y,nbins))); 2*srt_y(end)-srt_y(end-1)];

% Compute marginal and joint probability distributions
% (each bin is inclusive of lower bound, exclusive of upper bound)
pxy = NaN(length(xedges)-1,length(yedges)-1);
for ii = 1:length(xedges)-1
    for jj = 1:length(yedges)-1
        xidx = x>=xedges(ii)&x<xedges(ii+1);
        yidx = y>=yedges(jj)&y<yedges(jj+1);
        pxy(ii,jj) = sum(xidx&yidx)/length(x); % joint probability distribution
    end
end
px = sum(pxy,2); % marginal probabilities
py = sum(pxy,1)';

% Compute mutual information
indepxy = px*py'; % probabilities, if x and y are independent
log_mtrx = log2(pxy./indepxy);
% set all -Inf elements (if pxy=0) to 0, which ignores them in the summation
% for MI
log_mtrx(log_mtrx==-Inf) = 0;
MI = sum(sum(pxy.*log_mtrx));