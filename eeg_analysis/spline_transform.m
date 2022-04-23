function [spline_matrix,B,spline_knots] = spline_transform(X,ds_prop,delays,spline_matrix)
% Converts the design matrix X (time x delay) to a cubic-spline basis,
% which accounts for continuity across sampling points and allows one to
% reduce the number of parameters necessary to create the TRF model.
% (The Curve Fitting Toolbox is necessary)
% Inputs:
% - X = the design matrix (time x delay, the delays *MUST* be
%   increasing in the design matrix)
% - ds_prop = integer for the proportion of downsampling in delays (the EEG
%   should be downsampled only until 2x the highest frequency of interest.
%   For example: if the EEG was sampled at 128 Hz and low-pass filtered at 
%   16 Hz, the downsampling rate should be 4)
% - (optional) delays = values for the delays corresponding to each column
%   in X (the delays *MUST* be increasing). Otherwise a linear spacing is
%   assumed
% - (optional) spline_matrix = if the spline transform is already known,
%   this matrix is used to convert to the spline basis instead of creating a
%   new one
% Outputs
% - B = the design matrix transformed to the spline basis
% - spline_matrix = the matrix to convert from X to B (B = X*S*(S'S)^(-1)) and
%   from B to X (X = B*S');
% - spline_knots = knots of the splines used in the transform, in the same 
%   domain as the delays specified
% Nate Zuk (2019)

% Assume a linear spacing of delays 
if nargin<3 | isempty(delays)
    delays = 1:size(X,2);
end

% Create the spline transform matrix (if needed)
if nargin<4 | isempty(spline_matrix)
    % create the knots
    spline_knots = augknt(linspace(delays(1),delays(end),floor(length(delays)/ds_prop)+1),4);
    % make the matrix
    spline_matrix = spcol(spline_knots,4,delays);
end

% Convert to spline basis (whitening is necessary in order to produce
% components of similar magnitude to those in X)
if nargout>1
    B = (spline_matrix'*spline_matrix)^(-1)*spline_matrix'*X';
    B = B';
end