function [sbjs_ctrl,sbjs_asd] = load_subjects_from_list(sbj_list_file)
% Load the participant list spreadsheet and separate the subjects into
% control and ASD lists. The table should contain the headers:
% "Subjects" - for the subject ID
% "Group" - specifying if the subject is Control or ASD
% Nate Zuk (2022)

% Get the options for loading this file as a table
opts = detectImportOptions(sbj_list_file);
opts.VariableNamingRule = 'preserve'; % make sure Matlab doesn't overwrite header names

sbj_list = readtable(sbj_list_file,opts);
headers = sbj_list.Properties.VariableNames;

% Get the list of subject groups (Control or ASD)
group_column = strcmp(headers,'Group');
group = table2cell(sbj_list(:,group_column));

% Get the list of subject IDs
id_column = strcmp(headers,'Subjects');
id = table2cell(sbj_list(:,id_column));

% Identify Control subjects
sbjs_ctrl = id(strcmp(group,'Control'));
sbjs_asd = id(strcmp(group,'ASD'));