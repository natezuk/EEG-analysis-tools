function rt_erp = realign_erp_to_rt(erp,dly,eFs,rt,rt_erp_range,sound_delay,rebaseline)
% Realign the evoked responses to the subject's response time (skip missing
% responses)
% (sound_delay is the amount of time between the trial start and the first
% sound. If RT is relative to the trial start, this will change the RT to
% be relative to the sound or stimulus onset)

if nargin<7, rebaseline = []; end % use if the ERPs should be baselined again relative to RT

ntr = size(erp,3);
nchan = size(erp,2);

rt_dly_idx = floor(rt_erp_range(1)/1000*eFs):ceil(rt_erp_range(2)/1000*eFs);
rt_erp = NaN(length(rt_dly_idx),nchan,ntr);
% interpolate
for ii = 1:ntr
    % get the reaction time for this trial, and identify appropriate
    % delays
    if ~isnan(rt(ii))
        rt_idx = round(rt(ii)-sound_delay)/1000*eFs;
        rt_dly = (rt_dly_idx+rt_idx)/eFs*1000;
        for c = 1:nchan
            rt_erp(:,c,ii) = interp1(dly,erp(:,c,ii),rt_dly,'pchip');
            if ~isempty(rebaseline)
                baseline_idx = rt_dly>=rebaseline(1)+rt(ii) & rt_dly<rebaseline(2)+rt(ii);
                rt_erp(:,c,ii) = rt_erp(:,c,ii)-mean(rt_erp(baseline_idx,c,ii));
            end
        end
    end
end