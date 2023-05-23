function stbias = calc_st_bias(s1,s2)
% Calculate the short-term bias of each trial (bias+ = 1, bias- = 0, bias0
% = NaN), based on the relation of the tones is the current trial to the
% average of the previous one
% Nate Zuk (2023)

nblocks = size(s1,2);
ntr = size(s1,1);

% Calculate the bias on each trial
fmean = (log2(s1) + log2(s2))/2; % the mean (in log2) of the two tone frequencies
stbias = NaN(ntr-1,nblocks);
for b = 1:nblocks
    for t = 2:ntr
        mn_prev = fmean(t-1,b);
        % if both tones are above the mean of the previous trial
        if log2(s1(t,b))>mn_prev && log2(s2(t,b))>mn_prev
            if log2(s1(t,b))<log2(s2(t,b)), stbias(t-1,b) = 1; % bias+
            elseif log2(s1(t,b))>log2(s2(t,b)), stbias(t-1,b) = 0; % bias-
            end
        % if both tones are below the mean of the previous trial
        elseif log2(s1(t,b))<mn_prev && log2(s2(t,b))<mn_prev
            if log2(s1(t,b))>log2(s2(t,b)), stbias(t-1,b) = 1; % bias+
            elseif log2(s1(t,b))<log2(s2(t,b)), stbias(t-1,b) = 0; % bias-
            end
        end
    end
end