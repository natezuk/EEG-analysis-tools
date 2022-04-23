function [allerp,alltrig,allsbjs] = cat_over_sbjs(erp,trig,dim)
% Concatenate subject ERPs along third dimension of each array (trials)
% If triggers per trial are provided, concatenate those too.
if nargin<3 || isempty(dim), dim = 3; end % use the third dimension by default

alltrs = cellfun(@(x) size(x,dim),erp);
tottrs = [0; cumsum(alltrs)];
% get the size of allerp
size_all = size(erp{1});
size_all(dim) = tottrs(end);
% ndly = size(erp{1},1);
% nchan = size(erp{1},2);
% allerp = NaN(ndly,nchan,tottrs(end));
allerp = NaN(size_all);
allsbjs = NaN(length(tottrs)-1,1); % to label the individual subject data
for t = 1:length(tottrs)-1
    idx = tottrs(t)+1:tottrs(t+1);
    % create the indexing string
    index_char = [repmat(':,',1,dim-1) 'idx' repmat(',:',length(size_all)-dim)];
%     allerp(:,:,idx) = erp{t};
    eval(['allerp(' index_char ') = erp{t};']);
    allsbjs(idx) = t;
end

% concatenate triggers
if nargin==2 && ~isempty(trig)
    alltrig = NaN(tottrs(end),1);
    for t = 1:length(tottrs)-1
        idx = tottrs(t)+1:tottrs(t+1);
        alltrig(idx) = trig{t};
    end
end