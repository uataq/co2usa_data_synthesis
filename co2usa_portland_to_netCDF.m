clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('No outstanding questions as of 2019/07/30:\n')

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
date_created_str = datestr(datenum(2019,07,30),'yyyy-mm-dd');
%date_created_SLC_CO2 = datestr(datenum(2017,07,11),'yyyy-mm-dd');

date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2019,07,30);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');


%% City & provider information:

city = 'portland';
city_long_name = 'Portland';
city_url = 'http://web.pdx.edu/~arice/CO2_PDX.html';

provider(1).name = 'Andrew Rice';
provider(1).address1 = 'Department of Physics';
provider(1).address2 = '472 Science Research & Teaching Center';
provider(1).address3 = 'Portland, OR 97207';
provider(1).country = 'United States';
provider(1).city = city_long_name;
provider(1).affiliation = 'Portland State University';
provider(1).email = 'arice@pdx.edu';
provider(1).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'Rice, Andrew, and Gregory Bostrom. Measurements of Carbon Dioxide in an Oregon Metropolitan Region. Atmospheric Environment 45, no. 5 (February 2011): 1138–44. https://doi.org/10.1016/j.atmosenv.2010.11.026.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = date_issued_str;

i = 1;
site.codes{1,i} = 'psu';
site.(site.codes{i}).name = 'PSU';
site.(site.codes{i}).long_name = 'Portland State University';
site.(site.codes{i}).code = 'PSU';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {21}; 
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCor 840'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 45.5132;
site.(site.codes{i}).in_lon = -122.6864;
site.(site.codes{i}).in_elevation = 63;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'sel';
site.(site.codes{i}).name = 'SEL';
site.(site.codes{i}).long_name = 'SE Lafayette';
site.(site.codes{i}).code = 'SEL';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {9};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCor 840'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 45.4966;
site.(site.codes{i}).in_lon = -122.6029;
site.(site.codes{i}).in_elevation = 75;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'sis';
site.(site.codes{i}).name = 'SIS';
site.(site.codes{i}).long_name = 'Sauvie Island';
site.(site.codes{i}).code = 'SIS';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {7};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCor 840'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 45.7685;
site.(site.codes{i}).in_lon = -122.7721;
site.(site.codes{i}).in_elevation = 6;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');


%% Loading the data

for i = 1:length(site.codes)
    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            
            if ~exist(fullfile(readFolder,city,['hourly_avg_',site.codes{i},'_',sptxt,'_',intxt,'.mat']),'file')
                fprintf('Computing %s hourly %s averaged data...\n',site.codes{i},sptxt)
                
                site.(site.codes{i}).files = dir(fullfile(readFolder,city,[site.(site.codes{i}).name,'.csv']));
                site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = [];
                site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = [];
                for fn = 1:length(site.(site.codes{i}).files)
                    formatSpec = '%f%f%f%f%f%f%f%f';
                    
                    % Read the data file
                    fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                    read_dat = textscan(fid,formatSpec,'HeaderLines',0,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                    fclose(fid);
                    
                    site.(site.codes{i}).(['min_',sptxt,'_',intxt]) = [site.(site.codes{i}).(['min_',sptxt,'_',intxt]); read_dat{1,1}(:,8)]; % species
                    site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).(['min_',sptxt,'_',intxt,'_time']); datetime(read_dat{1,1}(:,2:7))]; % time
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

