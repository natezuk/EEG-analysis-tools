function v = calc_v_pk(erps,dly,dir,dly_range,chans_to_avg)
% For a set of ERPs for one subject (delay x channels x trials) calculate
% the maximum voltage within a particular delay range and/or over a set of
% channels.
% Inputs:
% - erps = set of ERPs (delay x channels x trials). The number of delays in
%       ERPs must match the number of delays in the 'dly' array
% - dir = if dir is -1, calculate the minimum. if dir is 1, calculate the
%       maximum
% - dly = array of delay values
% - dly_range = array of two values specifying the minimum and maximum
%       delay of the range to be averaged (default: empty)
% - chans_to_avg = array of channel indexes that should be included in the
%       average (default: empty)
% * If dly_range or chans_to_avg are empty arrays or not specified, then
% the output voltages will retain the delay or channel dimension of the
% ERPs respectively
% Outputs:
% - v = peak voltages, has the dimensions:
%   * channels x trials, if delays are used
%   * delays x trials, if channels are used
%   * trials x 1, if delays and channels are used
% Nate Zuk (2022)

if nargin < 3 || isempty(dly_range)
    % if a delay range isn't specified, use an empty dly_idx array
    dly_idx = [];
else
    dly_idx = dly>=dly_range(1) & dly<=dly_range(2);
end
if nargin < 4 || isempty(chans_to_avg)
    % if the channels to average are not specified, use an empty chan_idx
    % array
    chan_idx = [];
else
    chan_idx = chans_to_avg;
end

% Now get the peak of the erps, depending upon if dly or chan values were specified
% If dir is negative, then we are calculating the minimum, because min(erp)
% = -max(-erp)
if ~isempty(dly_idx) && ~isempty(chan_idx)
    v = squeeze(max(max(erps(dly_idx,chan_idx,:)*dir,[],2)))*dir;
elseif ~isempty(dly_idx)
    v = squeeze(max(erps(dly_idx,:,:)*dir))*dir;
elseif ~isempty(chan_idx)
    v = squeeze(max(erps(:,chan_idx,:)*dir,[],2))*dir;
else
    v = erps;
end