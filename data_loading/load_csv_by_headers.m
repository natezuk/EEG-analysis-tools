function data = load_csv_by_headers(csv_fl,headers_to_load)
% Load data from a csv file. The user specifies which columns of the CSV 
% to load, based on the headers provided.
% Inputs:
% - csv_fl = filename of csv
% - headers_to_load = cell array of headers (strings) corresponding to
% columns to load in the CSV (case sensitive)
% Outputs:
% - data = cell array containing all of the data, each column for a
% different header
% Nate Zuk

% Open the file
fid = fopen(csv_fl);

% The first line contains the headers for each column in the CSV
all_headers = fgetl(fid);

% Check each header, and find the ones that should be loaded
% get indexes where commas occur, and include the start (0) and the end of
% the all_headers string, for indexing later
%%% Edit 3-3-2023: If there are quotes in the headers, remove them
quotes_in_headers = strfind(all_headers,'"');
all_headers(quotes_in_headers) = [];
comma_delims = [0 strfind(all_headers,',') length(all_headers)+1];
header_idx = NaN(length(headers_to_load),1);
for ii = 2:length(comma_delims)
    h_select = (comma_delims(ii-1)+1):(comma_delims(ii)-1);
    header_cmp = cellfun(@(x) strcmp(all_headers(h_select),x), headers_to_load);
    if any(header_cmp) % if the current header matches any that should be loaded
        header_idx(header_cmp) = ii; % save the comma that occurs after the header
    end
end

% Now go through each line and save the values corresponding to the
% headers to load
data = {};
while 1
    rw = fgetl(fid);
    % check if we've reached the end of the CSV
    if ~ischar(rw) || contains(rw,'END OF FILE'), break, end
    % otherwise, load the values
    d = cell(1,length(header_idx)); % to store values for this row
    commas = [0 strfind(rw,',') length(rw)+1]; % get placement of commas
    %%% (Edit 2-3-2023) If the comma falls between two quotation marks,
    %%% exclude it from the comma separator list
    quotes = strfind(rw,'"');
    for q = 1:2:length(quotes)
        comma_in_quotes = commas>quotes(q) & commas<quotes(q+1);
        commas(comma_in_quotes) = [];
    end
    for n = 1:length(header_idx)
        % get indexes where the value for that column is stored
        try
            val_select = (commas(header_idx(n)-1)+1):(commas(header_idx(n))-1);
        catch err
            keyboard;
        end
        % save the value
        d{n} = rw(val_select);
        % If the value has quotes, remove them
        quotes_in_d = strfind(d{n},'"');
        d{n}(quotes_in_d) = [];
    end
    % add this row of values to the full data array
    data = [data; d];
end

% Close the file
fclose(fid);