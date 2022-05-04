function dpr = calc_dpr(corr,resp)
% calculate d-prime
% corr = array of the correct answers (0 or 1)
% resp = array of the subject's responses (0 or 1)

% checks %
% make sure corr and resp have the same number of indexes
if length(corr) ~= length(resp)
    error('Correct answer and response arrays must have same number of indexes');
end
% make ure corr and resp only contain 1s or 0s
if sum((corr~=1 & corr~=0))>0
    error('Correct answer array must contain only 1s and 0s');
end
if sum((resp~=1 & resp~=0))>0
    error('Response array must contain only 1s and 0s');
end

ntargets = sum(corr); % get the number of targets (calculate hits)
hr = sum(resp(corr==1))/ntargets;
% get the false alarm rate
npass = sum(corr==0); % number of pass trials (non-targets)
fa = sum(resp(corr==0))/npass;
% compute d-prime (z(hr) - z(fa))
% (The norminv of 0 or 1 is -Inf and Inf respectively. So if hr or fa
% is 0, use: 1/(2*trials) for the rate. If hr or fa is 1, use:
% (2*trials-1)/(2*trials).
if hr == 0, zh = norminv(1/(2*ntargets),0,1);
elseif hr == 1, zh = norminv((2*ntargets-1)/(2*ntargets),0,1);
else, zh = norminv(hr,0,1);
end
if fa == 0, za = norminv(1/(2*npass),0,1);
elseif fa >= 1, za = norminv((2*npass-1)/(2*npass),0,1);
    % I'm using >= here because the false alarm rate would be > 1 if
    % the subject responded on trials without targets and missed trials
    % with targets
else, za = norminv(fa,0,1);
end
dpr = zh-za;