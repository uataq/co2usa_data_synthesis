% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:


%% netCDF creation documentation

% Following the Climate Forecasting conventions for netCDF files documented here:
% http://cfconventions.org/
% http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html
% 
% Also following the Attribute Convention for Data Discovery version 1.3
% https://wiki.esipfed.org/Attribute_Convention_for_Data_Discovery_1-3
% 
% Variables must have a standard_name, a long_name, or both.
% A standard_name is the name used to identify the physical quantity. A standard name contains no whitespace and is case sensitive.
% A long_name has an ad hoc, human readable format.
% A comment can be used to add further detail, but is not required.
% 
% Time and date formating follow this convention:
% https://www.edf.org/health/data-standards-date-and-timestamp-guidelines
% 
% Data will be archived at the ORNL DAAC:
% https://daac.ornl.gov/PI/
% 
%% Creation date

% date_created: The date on which this version of the data was created. Recommended. 
date_created_now = datetime(now,'ConvertFrom','datenum','TimeZone','America/Denver'); date_created_now.TimeZone = 'UTC';
date_created_str = datestr(date_created_now,'yyyy-mm-ddThh:MM:ssZ');

% date_issued: The date on which this data (including all modifications) was formally issued (i.e., made available to a wider audience). Suggested.
date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2021,04,02);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'san_francisco_beacon';
city_long_name = 'San Francisco Beacon';
city_url = 'http://beacon.berkeley.edu/';

i = 1;
provider(i).name = 'Ronald Cohen';
provider(i).address1 = 'Berkeley College of Chemistry';
provider(i).address2 = '420 Latimer Hall';
provider(i).address3 = 'Berkeley, CA 94720-1460';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Berkeley College of Chemistry';
provider(i).email = 'rccohen@berkeley.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

i = 2;
provider(i).name = 'Alexis Shusterman';
provider(i).address1 = 'Berkeley College of Chemistry';
provider(i).address2 = '420 Latimer Hall';
provider(i).address3 = 'Berkeley, CA 94720-1460';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Berkeley College of Chemistry';
provider(i).email = 'shusterman.alexis@berkeley.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'Shusterman, A. A., V. E. Teige, A. J. Turner, C. Newman, J. Kim, and R. C. Cohen. The BErkeley Atmospheric CO2 Observation Network: Initial Evaluation. Atmos. Chem. Phys. 16, no. 21 (October 31, 2016): 13449-63. https://doi.org/10.5194/acp-16-13449-2016.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_created_str = date_created_str;

version_folder = 'v20210329';

% Latest node file is found here:
% https://cohen-research.appspot.com/get_latest_nodes/csv/

% Read the latest node file and loop through it:
[latest_nodes_num,latest_nodes_txt] = xlsread(fullfile(readFolder,city,version_folder,'get_latest_nodes.csv'));
latest_nodes_txt = latest_nodes_txt(2:end,:); % Removes the header line


%% Download data:

download_new_data = 'n';
if strcmp(download_new_data,'y')
    % Download the data with (in this example, this is from node 10)
    % http://beacon.berkeley.edu/node/93/measurements/csv/?interval=60&start=2012-01-01%2000:00:00&end=2019-05-14%2000:00:00&quality_level=2
    
    % This is an automated way to download all of the data at once:
    for i = 1:size(latest_nodes_num,1)
        %web(['http://beacon.berkeley.edu/node/',num2str(latest_nodes_num(i,1)),'/measurements/csv/?interval=60&start=2012-01-01%2000:00:00&end=2019-05-14%2000:00:00&quality_level=2'],'-browser')
        %url = ['http://beacon.berkeley.edu/node/',num2str(latest_nodes_num(i,1)),'/measurements/csv/?interval=60&start=2012-01-01%2000:00:00&end=2019-05-14%2000:00:00&quality_level=2'];
        t_start = datetime(latest_nodes_txt{i,8},'InputFormat','MM/dd/yyyy');
        if isnat(t_start); t_start = datetime(2010,1,1); end
        t_end = datetime(latest_nodes_txt{i,9},'InputFormat','MM/dd/yyyy hh:mm:ss a');
        t_end = t_end+days(1); % Make sure I'm 1 day past the end date to capture the last data points
        url = ['http://beacon.berkeley.edu/node/',num2str(latest_nodes_num(i,1)),'/measurements_all/csv?name=&interval=60&variables=co2_corrected_avg_t_drift_applied-level-2&start=',datestr(t_start,'yyyy-mm-dd'),'%2000:00:00&end=',datestr(t_end,'yyyy-mm-dd'),'%2000:00:00'];
        filename = fullfile(readFolder,city,version_folder,['node_id_',num2str(latest_nodes_num(i,1)),'_start_',datestr(t_start,'yyyy-mm-dd'),'_end_',datestr(t_end,'yyyy-mm-dd'),'_measurements.csv']);
        options = weboptions('Timeout',20);
        % Note: Sometimes there is an Internal Server Error in the downloading and you just need to start again.
        % This try/catch statement allows it to try 2x if it encounters an error, and that seems to work well.
        % Otherwise re-start the loop on the failed node (i).
        try
            outfilename = websave(filename,url,options);
        catch
            fprintf('Had a download error on node %s, trying again...',num2str(latest_nodes_num(i,1)))
            outfilename = websave(filename,url,options);
            fprintf('and it worked!\n')
        end
    end
    fprintf('Finished downloading data!\n')
end

%%


for i = 1:size(latest_nodes_num,1)
    site.codes{1,i} = ['node',num2str(latest_nodes_num(i,1),'%03.0f')];
    site.(site.codes{i}).name = ['node',num2str(latest_nodes_num(i,1),'%03.0f')];
    site.(site.codes{i}).long_name = latest_nodes_txt{i,2};
    site.(site.codes{i}).code = ['node',num2str(latest_nodes_num(i,1),'%03.0f')];
    if isnan(latest_nodes_num(i,6))
        site.(site.codes{i}).inlet_height = {3}; % For sites w/o a known inlet ht, current best estimate is 3m (2019-08-18)
    else
        site.(site.codes{i}).inlet_height = {round(latest_nodes_num(i,6))}; % For sites w/o a known inlet ht, current best estimate is 3m (2019-08-18)
    end
    site.(site.codes{i}).in_lat = latest_nodes_num(i,4);
    site.(site.codes{i}).in_lon = latest_nodes_num(i,5);
    site.(site.codes{i}).in_elevation = latest_nodes_num(i,7);
end

% The rest of the site info is the same across the sites.
for i = 1:length(site.codes)
    for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
    site.(site.codes{i}).species = {'co2'};
    site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
    site.(site.codes{i}).species_units = {'micromol mol-1'};
    site.(site.codes{i}).species_units_long_name = {'ppm'};
    site.(site.codes{i}).instrument = {'Vaisala CarboCap GMP343'};
    site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
    site.(site.codes{i}).country = 'United States';
    site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
    site.(site.codes{i}).date_issued = date_issued;
    site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
    site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
end

%% Loading the data

for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            site.(site.codes{i}).([sptxt,'_',intxt]) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = NaT(0); % empty datetime array
            site.(site.codes{i}).files = dir(fullfile(readFolder,city,version_folder,[['node_id_',num2str(str2double(site.(site.codes{i}).name(5:end))),'_'],'*.csv']));
            
            for fn = 1:length(site.(site.codes{i}).files)
                %formatSpec = '%q%q%f%f%{M/d/yyyy HH:mm:ss a}D%f';
                fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                tline = fgetl(fid); frewind(fid);
                if tline==-1; fprintf('No data in %s, skipping it\n',site.codes{i}); continue; end % If there is no data, skip that node.
                column_co2 = find(strcmp(strsplit(tline,','),'co2_corrected_avg_t_drift_applied-level-2'));
%                 if isempty(column_co2)
%                     column_co2 = find(strcmp(strsplit(tline,','),'co2_corrected_avg_drift_applied'));
%                 end
                if isempty(column_co2); warning('Cannot determine the column of the CO2 data in %s',site.codes{i}); end
                column_co2 = column_co2-3; % There are three datetime arrays.
                %formatSpec = '%{yyyy-MM-dd HH:mm:ss}D%{yyyy-MM-dd HH:mm:ss}D%f%f%f%f%f%f';
                formatSpec = '%{yyyy-MM-dd HH:mm:ss}D%f%{yyyy-MM-dd HH:mm:ss}D';
                for jj = 1:length(strsplit(tline,','))-3
                    formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                end
                read_dat = textscan(fid,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,4}(:,column_co2)]; % CO2
                %site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); nan(length(read_dat{1,1}),1)]; % CO2 std
                %site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); nan(length(read_dat{1,1}),1)]; % CO2 n
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); read_dat{1,3}]; % UTC time
                fprintf('File read: %s\n',site.(site.codes{i}).files(fn).name)
            end
            
            % Change -999 values to NaNs.
            site.(site.codes{i}).([sptxt,'_',intxt])(site.(site.codes{i}).([sptxt,'_',intxt])==-999) = nan;
           
            % No uncertainty, std, or n data yet.
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Removes the leading and trailing NaNs
            data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
            site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
            clear data_range_ind
            
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = repmat(site.(site.codes{i}).inlet_height{inlet},length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Set fill values:
            site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_std']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_n']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_unc']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lat']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lon']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']))) = -9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']))) = -9999.0;
            
            site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).code,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
    end
end

%% Temporary code to truncate all sites to Dec 31, 2019 for the 4/21 ORNL DAAC archive

for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            mask = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<datetime(2020,1,1); % Mask for data before 2020-01-01
            fields = {'','_std','_n','_unc','_time','_lat','_lon','_elevation','_inlet_height'};
            for j = 1:length(fields)
                site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]) = site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(mask); % Apply the mask
            end
        end
    end
end

%% Remove sites if there is no data or it is in another city

fprintf('***nodes being removed:***\n')
site_group_index = true(length(site.groups),1);
for i = 1:length(site.codes)
    msg = [];
    any_site_data = [];
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            % If there is no data, or if its all NaNs, remove that species/inlet.
            if or(sum(isnan(site.(site.codes{i}).([sptxt,'_',intxt])))==length(site.(site.codes{i}).([sptxt,'_',intxt])),isempty(site.(site.codes{i}).([sptxt,'_',intxt])))
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),{[sptxt,'_',intxt],[sptxt,'_',intxt,'_std'],[sptxt,'_',intxt,'_n'],[sptxt,'_',intxt,'_unc'],...
                    [sptxt,'_',intxt,'_time'],[sptxt,'_',intxt,'_lat'],[sptxt,'_',intxt,'_lon'],[sptxt,'_',intxt,'_elevation'],[sptxt,'_',intxt,'_inlet_height']});
                msg = '-no data';
            % Or if the site is outside of San Francisco
            elseif any([site.(site.codes{i}).in_lat>39,site.(site.codes{i}).in_lat<36,site.(site.codes{i}).in_lon<-125,site.(site.codes{i}).in_lon>-120])
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),{[sptxt,'_',intxt],[sptxt,'_',intxt,'_std'],[sptxt,'_',intxt,'_n'],[sptxt,'_',intxt,'_unc'],...
                    [sptxt,'_',intxt,'_time'],[sptxt,'_',intxt,'_lat'],[sptxt,'_',intxt,'_lon'],[sptxt,'_',intxt,'_elevation'],[sptxt,'_',intxt,'_inlet_height']});
                msg = '-outside SF';
            else
                any_site_data = [any_site_data,true];
            end
        end
    end
    if ~any(any_site_data) % If there is no data, remove the site, species, groups using the logical index.
        site = rmfield(site,site.codes{i});
        site_group_index(i) = false;
        fprintf('%s%s \n',site.codes{i},msg)
    end
end

site.groups = site.groups(site_group_index);
site.codes = site.codes(site_group_index);
site.species = site.species(site_group_index);

clear('any_site_data','site_group_index')

%% Temporary code to truncate all sites to Dec 31, 2019 for the 4/21 ORNL DAAC archive

for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            mask = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<datetime(2020,1,1); % Mask for data before 2020-01-01
            fields = {'','_std','_n','_unc','_time','_lat','_lon','_elevation','_inlet_height'};
            for j = 1:length(fields)
                site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]) = site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(mask); % Apply the mask
            end
        end
    end
end

%% Identify the netCDF files to create based on species.

site.unique_species = unique(site.species);
site.species_list = [];
for species_ind = 1:length(site.unique_species)
    site.species_list = [site.species_list, site.unique_species{species_ind},' '];
end
site.species_list = strip(site.species_list); % Removes the last space

for j = 1:length(site.species)
    if strcmp(site.species{j,1},'co2')
        site.species_standard_name{j,1} = 'carbon dioxide';
    elseif strcmp(site.species{j,1},'ch4')
        site.species_standard_name{j,1} = 'methane';
    elseif strcmp(site.species{j,1},'co')
        site.species_standard_name{j,1} = 'carbon monoxide';
    end
end

%% Creating the netCDF file

fprintf('Now creating the netCDF files.\n')
eval('co2usa_create_netCDF')

