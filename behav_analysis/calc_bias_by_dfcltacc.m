function [dpr_bias,pc_bias,ntr_bias] = calc_bias_by_dfcltacc(corr,resp,s1,s2,fd_thres,varargin)
% Calculate bias conditioned on previously easy/hard trials and
% correct/incorrct trials. If there are multiple columns to each of the
% input variables, they are treated as separate blocks of the same
% condition, and the bias is calculated on all trials.
% Inputs: Note that 'resp' should be either 1 or 0.
% In the output vectors, conditions are ordered as follows:
% - Index 1) hard & correct
% - Index 2) easy & correct
% - Index 3) hard & incorrect
% - Index 4) easy & incorrect
% Nate Zuk (2023)

% Set of conditions. If any of these is NaN, this condition is ignored when
% identifying trials (which can be used to look only at easy/hard or
% correct/incorrect separately).
conditions = [1 1; 0 1; 1 0; 0 0]; % indicates the conditions for easy/hard (1st coumn) and correct/incorrect (2nd column)

% Parse varargin
if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

ntr = size(corr,1);
nblocks = size(corr,2);
ncond = size(conditions,1);

% Identify previously correct/incorrect responses
% prevacc = NaN(ntr-1,nblocks);
prevacc = corr(1:end-1,:);
% Identify previous difficulty
prevdfclt = NaN(ntr-1,nblocks);
for b = 1:nblocks
    % Identify the difficulty of the trial ("hard" = <fd_thres, "easy" =
    % >=fd_thres), determined using semitones
    fd_size = abs((log2(s2(:,b)) - log2(s1(:,b)))*12);
    prevdfclt(fd_size(1:end-1)<fd_thres,b) = true; % hard trials
    prevdfclt(fd_size(1:end-1)>=fd_thres,b) = false; % easy trials
end

% Calculate the short-term bias condition (bias+, bias-) on each trial
stbias = calc_st_bias(s1,s2);

% Indicate the correct answer for each trial (f2>f1 = 1, f2<f1 = 0)
freqdir = NaN(ntr,nblocks);
for b = 1:nblocks
    freqdir(s2(:,b)>s1(:,b),b) = 1; % f2>f1
    freqdir(s2(:,b)<s1(:,b),b) = 0; % f1<f2
end

%% Calculate bias
% Rearrange all arrays into column vectors (to calculate bias across
% blocks)
prevacc = reshape(prevacc,[(ntr-1)*nblocks 1]);
prevdfclt = reshape(prevdfclt,[(ntr-1)*nblocks 1]);
stbias = reshape(stbias,[(ntr-1)*nblocks 1]);
currresp = reshape(resp(2:end,:),[(ntr-1)*nblocks 1]);
freqdir = reshape(freqdir(2:end,:),[(ntr-1)*nblocks 1]);

% Set up bias arrays
dpr_bias = NaN(ncond,1); % d-prime bias
pc_bias = NaN(ncond,1);
ntr_bias = NaN(ncond,2); % number of trials for each bias+/bias- condition

% Iterate through conditions
for c = 1:size(conditions,1)
    % make sure the trials are not misses
    notmiss = ~isnan(currresp);
    % get each bias type (bias+/bias-)
    if isnan(conditions(c,1)), dfclt_chk = true(nblocks*(ntr-1),1);
    else, dfclt_chk = prevdfclt==conditions(c,1);
    end
    if isnan(conditions(c,2)), acc_chk = true(nblocks*(ntr-1),1);
    else, acc_chk = prevacc==conditions(c,2);
    end
    idx_p = dfclt_chk & acc_chk & stbias==1; % bias+
%     idx_p = prevdfclt==conditions(c,1) & prevacc==conditions(c,2) & stbias==1; % bias+
    dpr_bp = calc_dpr(freqdir(idx_p&notmiss),currresp(idx_p&notmiss));
    pc_bp = sum(freqdir(idx_p)==currresp(idx_p))/sum(idx_p);
    idx_m = dfclt_chk & acc_chk & stbias==0; % bias-
%     idx_m = prevdfclt==conditions(c,1) & prevacc==conditions(c,2) & stbias==0; % bias-
    dpr_bm = calc_dpr(freqdir(idx_m&notmiss),currresp(idx_m&notmiss));
    pc_bm = sum(freqdir(idx_m)==currresp(idx_m))/sum(idx_m);
    % calculate bias
    dpr_bias(c) = dpr_bp - dpr_bm;
    pc_bias(c) = pc_bp - pc_bm;
    % calculate the number of trials in bias+ / bias-
    ntr_bias(c,1) = sum(idx_p);
    ntr_bias(c,2) = sum(idx_m);
end