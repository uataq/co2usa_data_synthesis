
if exist('city','var')
    % If this script is being executed immediately after a city processing
    % script, remove all the variables except for 'city'.
    vars = whos;
    for j = 1:length(vars)
        if ~strcmp(vars(j).name,'city')
            clear(vars(j).name)
        end
    end
    clear('vars','j')
else
    % If this script is being executed by itself, clear the workspace and
    % start fresh.  Manually select which city you would like to process.
    clear all
    %city = 'los_angeles';
    %city = 'indianapolis';
    city = 'san_francisco_baaqmd';
end

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output',city);
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output',city,'txt_formatted_files');

if ~exist(writeFolder,'dir'); mkdir(writeFolder); end

fn = dir(fullfile(readFolder,'*.nc'));

for fni = 1:length(fn)

finfo = ncinfo(fullfile(fn(fni).folder,fn(fni).name));

underscore_ind = regexp(fn(fni).name,'_');

date_issued_str = fn(fni).name(underscore_ind(end)+1:regexp(fn(fni).name,'[.]nc')-1);

% for i = [1,2,3,4,6];
%     fooLat = ncread([fn.folder,'\',fn.name],[siteCode{i},'/lat']);
%     fooLon = ncread([fn.folder,'\',fn.name],[siteCode{i},'/lon']);
%     fprintf('%s %7.4f %9.4f\n',siteCode{i},fooLat,fooLon)
% end
separator = '# ------------------------------------------------------------->>>>';

for group = 1:length(finfo.Groups)

% The fair use policy is embedded in the netCDF file, so a separate entry is not needed. 
% fair_use_policy{1,1} = separator;
% fair_use_policy{2,1} = '# FAIR USE POLICY';
% fair_use_policy{3,1} = '# ';
% fair_use_policy{4,1} = '# These cooperative data products are made freely available to the public and scientific community to advance the study of urban carbon cycling and associated air pollutants.';
% fair_use_policy{5,1} = '# Fair credit should be given to data contributors and will depend on the nature of your work.  When you start data analysis that may result in a publication, it is your responsibility to contact the data contributors directly, such that, if it is appropriate, they have the opportunity to contribute substantively and become a co-author.';
% fair_use_policy{6,1} = '# Data contributors reserve the right to make corrections to the data based on scientific grounds (e.g. recalibration or operational issues).';
% fair_use_policy{7,1} = '# Use of the data implies an agreement to reciprocate by making your research efforts (e.g. measurements as well as model tools, data products, and code) publicly available in a timely manner to the best of your ability.';
% fair_use_policy{8,1} = '# ';

% Global attributes (city specific)
global_attributes = cell(length(finfo.Attributes)+4,1);
global_attributes{1,1} = separator;
global_attributes{2,1} = '# GLOBAL ATTRIBUTES';
global_attributes{3,1} = '# ';
% Global attributes (for all of the city sites)
for j = 1:length(finfo.Attributes)
    global_attributes{j+3,1} = ['# ',finfo.Attributes(j).Name,' : ',finfo.Attributes(j).Value];
end
global_attributes{end,1} = '# ';

% Group attributes (site specific)
site_attributes = cell(length(finfo.Groups(group).Attributes)+4,1);
site_attributes{1,1} = separator;
site_attributes{2,1} = '# SITE ATTRIBUTES';
site_attributes{3,1} = '# ';
for j = 1:length(finfo.Groups(group).Attributes)
    site_attributes{j+3,1} = ['# ',finfo.Groups(group).Attributes(j).Name,' : ',finfo.Groups(group).Attributes(j).Value];
end
site_attributes{end,1} = '# ';

% Variables and variable attributes (for all of the variables listed in the file) 
variable_attributes = cell(length(finfo.Groups(group).Variables),1); % Not the full size, but that is fine, it will grow to be the correct size.
variable_attributes{1,1} = separator;
variable_attributes{2,1} = '# VARIABLE ATTRIBUTES';
variable_attributes{3,1} = '# ';
row = 4; 
varIndToWrite = []; % Indicies of the variables to put in the netCDF data below.
time_ind = nan; % Index of the time variable used in the netCDF data below.
for j = 1:length(finfo.Groups(group).Variables)
    for k = 1:length(finfo.Groups(group).Variables(j).Attributes)
        if isnumeric(finfo.Groups(group).Variables(j).Attributes(k).Value)
            variable_attributes{row,1} = ['# ',finfo.Groups(group).Variables(j).Name,' : ',finfo.Groups(group).Variables(j).Attributes(k).Name,' : ',num2str(finfo.Groups(group).Variables(j).Attributes(k).Value)];
        else
            variable_attributes{row,1} = ['# ',finfo.Groups(group).Variables(j).Name,' : ',finfo.Groups(group).Variables(j).Attributes(k).Name,' : ',finfo.Groups(group).Variables(j).Attributes(k).Value];
        end
        row = row+1;
    end
    % If the variable has a length of 1, put that information in the header, otherwise it will go in the output.
    if finfo.Groups(group).Variables(j).Size==1
        variable_attributes{row,1} = ['# ',finfo.Groups(group).Variables(j).Name,' : Value : ',num2str(ncread([fn.folder,'\',fn.name],[finfo.Groups(group).Name,'/',finfo.Groups(group).Variables(j).Name]))];
        row = row+1;
    else
        varIndToWrite = [varIndToWrite,j]; %#ok<AGROW>
    end
    if strcmp(finfo.Groups(group).Variables(j).Name,'time'); time_ind = j; end
end
variable_attributes{end+1,1} = '# '; %#ok<SAGROW>

% Convert the time variable into a datetime format.
time1 = ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/',finfo.Groups(group).Variables(time_ind).Name]);
time = datetime(time1,'ConvertFrom','datenum','TimeZone','UTC');

% Assemble the data output and the variable order line
variable_order{1,1} = separator;
variable_order{2,1} = '# VARIABLE ORDER';
variable_order{3,1} = '# ';
variable_order{4,1} = '# ';
for j = varIndToWrite
    variable_order{4,1} = [variable_order{4,1},finfo.Groups(group).Variables(j).Name,', '];
end
variable_order{4,1} = variable_order{4,1}(1:end-2); % removes the last comma.

% Structure containing all of the data to write.
output = {ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/time']),...
    cellstr(ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/time_string'])),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/',finfo.Groups(group).Attributes(strcmp({finfo.Groups(group).Attributes.Name},'dataset_parameter')).Value]),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/std_dev']),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/n']),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/uncertainty']),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/lat']),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/lon']),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/elevation']),...
    ncread(fullfile(fn(fni).folder,fn(fni).name),[finfo.Groups(group).Name,'/inlet_height'])};

% Sets the fill value for all of the nan values. Note that the time in the first 2 columns (time, time_string) should not have any nan values. 
for j = 3:length(output)
   output{1,j}(isnan(output{1,j}),1) = -1e34;
end

% Writing the file
filename    = [city,'_',finfo.Groups(group).Name,'_1_hour_R0_',date_issued_str,'.txt'];
filepath    = fullfile(writeFolder,filename);

% Create the header consisting of the individual pieces:
full_header = [
    %fair_use_policy;
    global_attributes;
    site_attributes;
    variable_attributes;
    variable_order];

% Append the number of header lines at the top of the header:
full_header = [{['# Number of header lines : ',num2str(length(full_header)+2)]}; {'# '}; full_header]; %#ok<AGROW> % +2 for header line number & a blank line.

[fid,message] = fopen(filepath,'w'); %open file and overwrite if it exists
if fid==-1
    error('Cannot open the output file.')
end

% Write the header:
for j = 1:length(full_header)
    fprintf(fid, [full_header{j,1},'\r\n']);
end

% Write the data:
for j = 1:finfo.Groups(group).Dimensions.Length
    fprintf(fid,'%d, %s, %0.6g, %0.6g, %1g, %0.6g, %0.6g, %0.6g, %0.4g, %0.4g\r\n',...
        output{1,1}(j,1),...
        output{1,2}{j,1},...
        output{1,3}(j,1),...
        output{1,4}(j,1),...
        output{1,5}(j,1),...
        output{1,6}(j,1),...
        output{1,7}(j,1),...
        output{1,8}(j,1),...
        output{1,9}(j,1),...
        output{1,10}(j,1));
end

status = fclose(fid);
if status
    disp('Problem closing file.');
end
fprintf('netCDF file converted to text and saved to: %s\n',filepath);

end

end

fprintf('Zipping the text files...')
txtfn = dir(fullfile(writeFolder,'*.txt'));
zip(fullfile(writeFolder,[city,'_all_sites_1_hour_R0_txt_formatted_files_',date_issued_str,'.zip']),{txtfn.name},txtfn(1).folder)
fprintf('Done.\n')

fprintf('<--- Finished creating text files from the netCDF parent files --->\n')





