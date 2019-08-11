clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('Outstanding Issues: Need site inlet heights.  Can this be integrated into the latest node file?.\n')

%% Data access notes:

% Latest node file is found here:
% https://cohen-research.appspot.com/get_latest_nodes/csv/

% Download the data with this call (in this example, this is from node 11)
% http://beacon.berkeley.edu/node/11/measurements/csv/?interval=60&start=2012-01-01%2000:00:00&end=2019-05-14%2000:00:00&quality_level=2

%% netCDF creation documentation

% Following the Climate Forecasting conventions for netCDF files documented here:
% http://cfconventions.org/
% http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html
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

date_created_now = datestr(now,'yyyy-mm-dd');
date_created_str = datestr(datenum(2018,02,01),'yyyy-mm-dd');
%date_created_SLC_CO2 = datestr(datenum(2017,07,11),'yyyy-mm-dd');

date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2017,05,17);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');

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

site.reference = 'Shusterman, A. A., V. E. Teige, A. J. Turner, C. Newman, J. Kim, and R. C. Cohen. “The BErkeley Atmospheric CO2 Observation Network: Initial Evaluation.” Atmos. Chem. Phys. 16, no. 21 (October 31, 2016): 13449–63. https://doi.org/10.5194/acp-16-13449-2016.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');


% Latest node file is found here:
% https://cohen-research.appspot.com/get_latest_nodes/csv/

% Read the latest node file and loop through it:
[latest_nodes_num,latest_nodes_txt] = xlsread(fullfile(readFolder,city,'v_20190809','get_latest_nodes.csv'));
latest_nodes_txt = latest_nodes_txt(2:end,:); % Removes the header line

% Download the data with (in this example, this is from node 10)
% http://beacon.berkeley.edu/node/10/measurements/csv/?interval=60&start=2012-01-01%2000:00:00&end=2019-05-14%2000:00:00&quality_level=2

for i = 1:size(latest_nodes_num,1)
    site.codes{1,i} = ['node',num2str(latest_nodes_num(i,1),'%03.0f')];
    site.(site.codes{i}).name = ['node',num2str(latest_nodes_num(i,1),'%03.0f')];
    site.(site.codes{i}).long_name = latest_nodes_txt{i,2};
    site.(site.codes{i}).code = ['node',num2str(latest_nodes_num(i,1),'%03.0f')];
    site.(site.codes{i}).inlet_height = {1}; % I don't actually know the inlet height for any of these sites
    site.(site.codes{i}).in_lat = latest_nodes_num(i,4);
    site.(site.codes{i}).in_lon = latest_nodes_num(i,5);
    site.(site.codes{i}).in_elevation = latest_nodes_num(i,6);
end

% The rest of the site info is the same across the sites.
for i = 1:length(site.codes)
    for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
    site.(site.codes{i}).species = {'co2'};
    site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
    site.(site.codes{i}).species_units = {'micromol mol-1'};
    site.(site.codes{i}).species_units_long_name = {'ppm'};
    site.(site.codes{i}).instrument = {'Vaisala CarboCap GMP343'};
    site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
    site.(site.codes{i}).country = 'United States';
    site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
    site.(site.codes{i}).date_issued = datetime(2017,05,17);
    site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
    site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
end

% i = 1;
% site.codes{1,i} = 'node001';
% site.(site.codes{i}).name = 'node001';
% site.(site.codes{i}).long_name = 'Stone Edge Farms (Vineyard)';
% site.(site.codes{i}).code = 'node001';
% site.(site.codes{i}).inlet_height = {1}; % I don't actually know the inlet height for beale
% site.(site.codes{i}).in_lat = 38.29069;
% site.(site.codes{i}).in_lon = -122.50575;
% site.(site.codes{i}).in_elevation = 1;
% 


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
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
            site.(site.codes{i}).files = dir(fullfile(readFolder,city,'v_20190515',[site.(site.codes{i}).name,'*.csv']));
            
            for fn = 1:length(site.(site.codes{i}).files)
                %formatSpec = '%q%q%f%f%{M/d/yyyy HH:mm:ss a}D%f';
                formatSpec = '%{yyyy-MM-dd HH:mm:ss}D%{yyyy-MM-dd HH:mm:ss}D%f%f%f%f%f%f';
                fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                read_dat = textscan(fid,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,3}(:,6)]; % CO2
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); nan(length(read_dat{1,1}),1)]; % CO2 std
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); nan(length(read_dat{1,1}),1)]; % CO2 n
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); read_dat{1,2}]; % time
                fprintf('File read: %s\n',site.(site.codes{i}).files(fn).name)
            end
            
            % Change -999 values to NaNs.
            site.(site.codes{i}).([sptxt,'_',intxt])(site.(site.codes{i}).([sptxt,'_',intxt])==-999) = nan;
           
            % No uncertainty data yet.
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
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
            site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_std']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_n']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_unc']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lat']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lon']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']))) = -1e34;
            
            site.groups = [site.groups; {[site.(site.codes{i}).code,'_',sptxt,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
    end
end


%%

% If there is no QCed data from this site, remove it from the list of sites.
% Loop through.
site_group_index = true(length(site.groups),1);
for i = 1:length(site.codes)
    any_site_data = [];
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            % If there is no data, or if its all NaNs, remove that species/inlet.
            if or(sum(isnan(site.(site.codes{i}).([sptxt,'_',intxt])))==length(site.(site.codes{i}).([sptxt,'_',intxt])),isempty(site.(site.codes{i}).([sptxt,'_',intxt])))
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),{[sptxt,'_',intxt],[sptxt,'_',intxt,'_std'],[sptxt,'_',intxt,'_n'],[sptxt,'_',intxt,'_unc'],...
                    [sptxt,'_',intxt,'_time'],[sptxt,'_',intxt,'_lat'],[sptxt,'_',intxt,'_lon'],[sptxt,'_',intxt,'_elevation'],[sptxt,'_',intxt,'_inlet_height']});
            else
                any_site_data = [any_site_data,true];
            end
        end
    end
    if ~any(any_site_data) % If there is no data, remove the site, species, groups using the logical index.
        site = rmfield(site,site.codes{i});
        site_group_index(i) = false;
    end
end

site.groups = site.groups(site_group_index);
site.codes = site.codes(site_group_index);
site.species = site.species(site_group_index);

clear('any_site_data','site_group_index')


%% Load background data, or leave it blank if it doesn't exist.

% site.codes = [site.codes,'background'];
% site.groups = [site.groups; 'background'];
% 
% i = length(site.codes);
% site.(site.codes{i}).name = 'background';
% site.(site.codes{i}).long_name = 'background';
% site.(site.codes{i}).code = '';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/Los_Angeles';
% site.(site.codes{i}).inlet_height_long_name = {'background'};
% site.(site.codes{i}).inlet_height = {0};
% site.(site.codes{i}).species = {'co2'};
% site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
% site.(site.codes{i}).species_units = {'micromol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm'};
% site.(site.codes{i}).instrument = {'modeled'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
% site.(site.codes{i}).in_lat = 32.87;
% site.(site.codes{i}).in_lon = -117.25;
% site.(site.codes{i}).in_elevation = 0;
% site.(site.codes{i}).date_issued = datetime(2017,05,17);
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
% 
% sp = 1; sptxt = site.(site.codes{i}).species{sp};
% inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
% 
% site.(site.codes{i}).([sptxt,'_',intxt]) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [datetime(2016,01,01);datetime(2016,01,02)];
% site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = [-1e34;-1e34];
% site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = [-1e34;-1e34];

% Identify the netCDF files to create based on species.

site.unique_species = unique(site.species);
site.species_list = [];
for species_ind = 1:length(site.unique_species)
    site.species_list = [site.species_list, site.unique_species{species_ind},' '];
end
site.species_list = strip(site.species_list); % Removes the last space

for j = 1:length(site.unique_species)
    if strcmp(site.unique_species{j,1},'co2')
        site.unique_species_long_name{j,1} = 'carbon dioxide';
    elseif strcmp(site.unique_species{j,1},'ch4')
        site.unique_species_long_name{j,1} = 'methane';
    elseif strcmp(site.unique_species{j,1},'co')
        site.unique_species_long_name{j,1} = 'carbon monoxide';
    end
end

%% Creating the netCDF file

eval('co2usa_create_netCDF')

%% Convert the netCDF data to text files.

fprintf('Now creating the text files from the netCDF files.\n')
netCDF2txt_group = 'all_sites'; % 'all_sites' or 'background'
eval('co2usa_netCDF2txt')

