function display_stats(stats)
% For a stats structure containing variables with p values ("p_...") and
% stats structures for the corresponding statistics ("st_...") this prints
% out the statistic and its associated p-value. Note that the statistic and
% the p-value variables **must** have the same suffix after the first underscore.
% Nate Zuk (2023)

% Get all of the variables in stats
fields = fieldnames(stats);

% Get each st and p-value pair
p_vals = find(cellfun(@(x) strcmp(x(1:2),'p_'),fields));
for ii = 1:length(p_vals)
    % get the suffix
    p_nm = fields{p_vals(ii)};
    suffix = p_nm(3:end);
    % display the suffix
    fprintf('%s: ',suffix);
    % get the p-value
    p = stats.(p_nm);
    % get the associated st structure
    st = stats.(['st_' suffix]);
    % If there is more then one element in p and st, indicate each element
    % separately
    for n = 1:length(p)
        if length(st)>1
            st_fld = fieldnames(st{n}); % get the variables in st
        else
            st_fld = fieldnames(st);
        end
        for jj = 1:length(st_fld)
            var_nm = sprintf(st_fld{jj});
            if length(p)>1, 
                var_nm = [var_nm sprintf('(%d)',n)]; 
                s = st{n};
            else
                if iscell(st), s = st{1};
                else, s = st;
                end
            end
            fprintf('%s = %.2f, ',var_nm,s.(st_fld{jj}));
        end
        % then display the p-value
        fprintf('p = %.3f\n',p(n));
    end
end