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
date_created_str = datestr(datenum(2018,07,01),'yyyy-mm-dd');
%date_created_SLC_CO2 = datestr(datenum(2017,07,11),'yyyy-mm-dd');

date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2018,07,01);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');


%% City & provider information:

city = 'salt_lake_city';
city_long_name = 'Salt Lake City';
city_url = 'https://air.utah.edu/';

i = 1;
provider(i).name = 'John Lin';
provider(i).address1 = 'Department of Atmospheric Sciences';
provider(i).address2 = '135 S 1460 E, room 819';
provider(i).address3 = 'Salt Lake City, UT 84112';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'University of Utah';
provider(i).email = 'John.Lin@utah.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';
i = 2;
provider(i).name = 'Logan Mitchell';
provider(i).address1 = 'Department of Atmospheric Sciences';
provider(i).address2 = '135 S 1460 E, room 819';
provider(i).address3 = 'Salt Lake City, UT 84112';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'University of Utah';
provider(i).email = 'Logan.Mitchell@utah.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh
site.reference = 'Mitchell, Logan E., John C. Lin, David R. Bowling, Diane E. Pataki, Courtenay Strong, Andrew J. Schauer, Ryan Bares, et al. Long-Term Urban Carbon Dioxide Observations Reveal Spatial and Temporal Dynamics Related to Urban Characteristics and Growth. Proceedings of the National Academy of Sciences 115, no. 12 (March 20, 2018): 2912–17. https://doi.org/10.1073/pnas.1702393115.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.codes = {}; % List of the site "codes"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');


i = 1;
site.codes{1,i} = 'background';

site.(site.codes{i}).code = upper(site.codes{i});
site.(site.codes{i}).name = 'background';
site.(site.codes{i}).long_name = 'background';

site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver';
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'modeled'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.7607;
site.(site.codes{i}).in_lon = -111.8911;
site.(site.codes{i}).in_elevation = 1301;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;

sp = 1; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};

site.groups = [site.groups; {[site.(site.codes{i}).name,'_',sptxt]}];
site.species = [site.species; {sptxt}];

load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'code','SLC CO2','Data','data_background.mat'))

site.(site.codes{i}).([sptxt,'_',intxt]) = bg.co2; % species mixing ratio
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(bg.t,'ConvertFrom','datenum'); ...

% Removes the leading and trailing NaNs
data_range_ind = find(site.(site.codes{i}).([sptxt,'_',intxt])~=-1e34,1,'first'):find(site.(site.codes{i}).([sptxt,'_',intxt])~=-1e34,1,'last');
site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
clear data_range_ind

site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);



site.date_issued = datetime(1970,1,1); % This date will be updated with the most recent date in the files below.
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

fprintf('---- %-6s complete ----\n\n',site.codes{i})

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

eval('co2usa_create_background_netCDF')

%% Convert the netCDF data to text files.

fprintf('Now creating the text files from the netCDF files.\n')

netCDF2txt_group = 'background'; % 'all_sites' or 'background'

eval('co2usa_netCDF2txt')


