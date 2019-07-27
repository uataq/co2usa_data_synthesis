clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

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
date_issued = datetime(2018,07,01);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');


%% City & provider information:

city = 'san_francisco_baaqmd';
city_long_name = 'San Francisco';
city_url = 'http://www.baaqmd.gov/research-and-data/air-quality-measurement/ghg-measurement/ghg-data';

% http://www.baaqmd.gov/research-and-data/air-quality-measurement/ghg-measurement/ghg-data

provider(1).name = 'Abhinav Guha';
provider(1).address1 = 'BAAQMD Planning and Climate Protection Division';
provider(1).address2 = '375 Beale Street Suite 600';
provider(1).address3 = 'San Francisco, CA 94105';
provider(1).country = 'United States';
provider(1).city = city_long_name;
provider(1).affiliation = 'BAAQMD';
provider(1).email = 'aguha@baaqmd.gov';
provider(1).parameter = 'Provider has contributed measurements for: ';

provider(2).name = 'Sally Newman';
provider(2).address1 = 'BAAQMD Planning and Climate Protection Division';
provider(2).address2 = '375 Beale Street Suite 600';
provider(2).address3 = 'San Francisco, CA 94105';
provider(2).country = 'United States';
provider(2).city = city_long_name;
provider(2).affiliation = 'BAAQMD';
provider(2).email = 'snewman@baaqmd.gov';
provider(2).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'http://www.baaqmd.gov/~/media/files/planning-and-research/ghg-data/readme-files/2017/timeseries_readme_file_spring2017-txt.txt?la=en';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

i = 1;
site.codes{1,i} = 'bby';
site.(site.codes{i}).name = 'BodegaBay';
site.(site.codes{i}).long_name = 'Bodega Bay';
site.(site.codes{i}).code = 'BBY';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {0};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 38.318756;
site.(site.codes{i}).in_lon = -123.072528;
site.(site.codes{i}).in_elevation = 21;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'bis';
site.(site.codes{i}).name = 'BethelIsland';
site.(site.codes{i}).long_name = 'Bethel Island';
site.(site.codes{i}).code = 'BIS';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {0};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 38.006311;
site.(site.codes{i}).in_lon = -121.641918;
site.(site.codes{i}).in_elevation = -2;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'liv';
site.(site.codes{i}).name = 'Livermore';
site.(site.codes{i}).long_name = 'Livermore';
site.(site.codes{i}).code = 'LIV';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {0};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 37.687526;
site.(site.codes{i}).in_lon = -121.784217;
site.(site.codes{i}).in_elevation = 137;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'smt';
site.(site.codes{i}).name = 'SanMartin';
site.(site.codes{i}).long_name = 'San Martin';
site.(site.codes{i}).code = 'SMT';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {0};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 37.079379;
site.(site.codes{i}).in_lon = -121.600031;
site.(site.codes{i}).in_elevation = 86;
site.(site.codes{i}).date_issued = datetime(2018,07,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

% I wasn't able to find any data online from Patterson Pass.
% i = i+1;
% site.codes{1,i} = 'ptp';
% site.(site.codes{i}).name = 'PattersonPass';
% site.(site.codes{i}).long_name = 'Patterson Pass';
% site.(site.codes{i}).code = 'PTP';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {0};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4','co'};
% site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
% site.(site.codes{i}).in_lat = 37.689615;
% site.(site.codes{i}).in_lon = -121.631916;
% site.(site.codes{i}).in_elevation = 526;
% site.(site.codes{i}).date_issued = datetime(2018,07,01);
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');


%% Loading the data

for i = 1:length(site.codes)
    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            
            
            if ~exist(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']),'file')
                fprintf('Computing %s hourly %s averaged data...\n',site.codes{i},sptxt)
                
                site.(site.codes{i}).files = dir(fullfile(readFolder,city,[upper(sptxt),'_*',site.(site.codes{i}).name,'*.csv']));
                site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = [];
                site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = [];
                for fn = 1:length(site.(site.codes{i}).files)
                    formatSpec = '%s%f';
                    
                    % Read the data file
                    fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                    read_dat = textscan(fid,formatSpec,'HeaderLines',0,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                    fclose(fid);
                    
                    site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = [site.(site.codes{i}).(['min_',sptxt,'_',intxt]); read_dat{1,2}(:,1)]; % species
                    site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']); ...
                        datetime(read_dat{1,1},'InputFormat','dd-MMM-yyyy HH:mm:ss')]; % time
                    fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files(fn).name)
                end
                
                % Sort the data in chronological order since it wasn't necessarily loaded that way.
                [site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']),sort_index] = sortrows(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']));
                site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = site.(site.codes{i}).(['min_',sptxt,'_',intxt])(sort_index,1);
                
                % Removes the leading and trailing NaNs
                data_range_ind = find(~isnan(site.(site.codes{i}).(['min_',sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).(['min_',sptxt,'_',intxt])),1,'last');
                site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = site.(site.codes{i}).(['min_',sptxt,'_',intxt])(data_range_ind);
                site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time'])(data_range_ind);
                clear sort_index data_range_ind
                
                % Creating an hourly averaged data set from the minute data.
                qht = (dateshift(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time'])(1),'start','hour'):1/24:dateshift(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time'])(end),'start','hour'))'; % Date numbers of the floored hours.
                qhdata = nan(size(qht,1),1);
                qhdataStd = nan(size(qht,1),1);
                qhdataCount = nan(size(qht,1),1);
                qtFloorHour = dateshift(site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']),'start','hour');
                
                tic
                for j = 1:size(qht,1)
                    qhdataTemp = site.(site.codes{i}).(['min_',sptxt,'_',intxt])(qtFloorHour==qht(j,1),:);
                    if size(qhdataTemp,1)>=2 % Must be at least two data points in order to save an "hourly average"
                        qhdata(j,:) = nanmean(qhdataTemp,1);
                        qhdataStd(j,:) = nanstd(qhdataTemp,1);
                        qhdataCount(j,:) = sum(~isnan(qhdataTemp));
                    end
                end
                toc
                save(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']),'qht','qhdata','qhdataStd','qhdataCount')
            else
                fprintf('Loading previously computed %s hourly %s averaged data.\n',site.codes{i},sptxt)
                load(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']))
            end
            
            site.(site.codes{i}).([sptxt,'_',intxt]) = qhdata;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = qhdataStd;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = qhdataCount;
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = qht;
            
            % No uncertainty data yet.
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Lat, Lon, Elevation, and Inlet heights do not change, so they are all entered as a constant through the data set. 
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
    fprintf('---- %-6s complete ----\n\n',site.codes{i})
end

%% Load background data, or leave it blank if it doesn't exist.

% i = length(site.codes)+1;
% 
% site.codes{1,i} = 'background';
% site.groups = [site.groups; 'background'];
% 
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
% site.(site.codes{i}).in_lat = site.(site.codes{i-1}).in_lat;
% site.(site.codes{i}).in_lon = site.(site.codes{i-1}).in_lon;
% site.(site.codes{i}).in_elevation = 0;
% site.(site.codes{i}).date_issued = site.(site.codes{i-1}).date_issued;
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
% 
% fprintf('---- %-6s complete ----\n\n',site.codes{i})

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

