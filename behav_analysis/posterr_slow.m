function diffrt = posterr_slow(rt,acc)
% Calculate post-error response time slowing
% Nate Zuk (2023)

rt_relprevacc = NaN(2,1);

% Identify trials that follow and errorr
prevcorr = acc(1:end-1,:)==1;
preverr = acc(1:end-1,:)==0;
% only include RT for correct responses
currcorr = acc(2:end,:)==1;
rt = rt(2:end,:); % skip the first trial
allrt_corr = []; allrt_err = [];
for b = 1:size(rt,2)
    allrt_corr = [allrt_corr; rt(prevcorr(:,b)&currcorr(:,b),b)];
    allrt_err = [allrt_err; rt(preverr(:,b)&currcorr(:,b),b)];
end
% rt_relprevacc(1) = median(rt(prevcorr&currcorr),'omitnan'); % follows correct
% rt_relprevacc(2) = median(rt(preverr&currcorr),'omitnan'); % follows error
rt_relprevacc(1) = median(allrt_corr,'omitnan');
rt_relprevacc(2) = median(allrt_err,'omitnan');

diffrt = rt_relprevacc(2)-rt_relprevacc(1);