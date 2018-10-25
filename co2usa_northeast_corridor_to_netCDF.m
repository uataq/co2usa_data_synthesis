clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('Outstanding questions as of 10/11/2018:\n')
fprintf('-City URL?\n')
fprintf('-address?\n')
fprintf('-One site (MSH) has CO, but readme doesnt. Do you want to include CO?\n')

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

city = 'northeast_corridor';
city_long_name = 'North-East Corridor Baltimore-Washington DC';
city_url = '';

i = 1;
provider(i).name = 'Anna Karion';
provider(i).address1 = 'National Institute of Standards and Technology';
provider(i).address2 = '100 Bureau Drive';
provider(i).address3 = 'Gaithersburg, MD 20899';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'National Institute of Standards and Technology (NIST)';
provider(i).email = 'anna.karion@nist.gov';
provider(i).parameter = 'Provider has contributed measurements for: ';

i = 2;
provider(i).name = 'James Whetstone';
provider(i).address1 = 'National Institute of Standards and Technology';
provider(i).address2 = '100 Bureau Drive';
provider(i).address3 = 'Gaithersburg, MD 20899';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'National Institute of Standards and Technology (NIST)';
provider(i).email = 'james.whetstone@nist.gov';
provider(i).parameter = 'Provider has contributed measurements for: ';


%% Site meta data

clear site % start fresh

site.reference = 'A. Karion, J. Whetstone, In Situ Carbon Dioxide and Methane Measurements from a Tower Network in the North-East Corridor Baltimore/Washington, D.C. Urban Area. (in prep). DATA RELEASE VERSION: 2018-10-01.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

i = 1;
site.codes{1,i} = 'arl';
site.(site.codes{i}).name = 'Arlington_VA';
site.(site.codes{i}).long_name = 'Arlington VA';
site.(site.codes{i}).code = 'ARL';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {50,92};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 38.891667;
site.(site.codes{i}).in_lon = -77.131667;
site.(site.codes{i}).in_elevation = 111;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'buc';
site.(site.codes{i}).name = 'Bucktown_MD';
site.(site.codes{i}).long_name = 'Bucktown MD';
site.(site.codes{i}).code = 'BUC';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {46,75};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 38.459699;
site.(site.codes{i}).in_lon = -76.042970;
site.(site.codes{i}).in_elevation = 3;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'hal';
site.(site.codes{i}).name = 'Halethorpe_MD';
site.(site.codes{i}).long_name = 'Halethorpe MD';
site.(site.codes{i}).code = 'HAL';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {29,58};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 39.255194;
site.(site.codes{i}).in_lon = -76.675278;
site.(site.codes{i}).in_elevation = 70;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'jes';
site.(site.codes{i}).name = 'Jessup_MD';
site.(site.codes{i}).long_name = 'Jessup MD';
site.(site.codes{i}).code = 'JES';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {49,91};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 39.172300;
site.(site.codes{i}).in_lon = -76.776500;
site.(site.codes{i}).in_elevation = 67;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'msh';
site.(site.codes{i}).name = 'Mashpee_MA';
site.(site.codes{i}).long_name = 'Mashpee MA';
site.(site.codes{i}).code = 'MSH';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {25,46};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 41.656694;
site.(site.codes{i}).in_lon = -70.497500;
site.(site.codes{i}).in_elevation = 32;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'ndc';
site.(site.codes{i}).name = 'Washington_DC';
site.(site.codes{i}).long_name = 'Washington DC';
site.(site.codes{i}).code = 'NDC';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {45,91};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 38.949944;
site.(site.codes{i}).in_lon = -77.079639;
site.(site.codes{i}).in_elevation = 128;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'neb';
site.(site.codes{i}).name = 'NE_Baltimore_MD';
site.(site.codes{i}).long_name = 'Northeast Baltimore MD';
site.(site.codes{i}).code = 'NEB';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {50,67};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 39.315417;
site.(site.codes{i}).in_lon = -76.583000;
site.(site.codes{i}).in_elevation = 44;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'nwb';
site.(site.codes{i}).name = 'NW_Baltimore_MD';
site.(site.codes{i}).long_name = 'Northwest Baltimore MD';
site.(site.codes{i}).code = 'NWB';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {27,55};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 39.344541;
site.(site.codes{i}).in_lon = -76.685071;
site.(site.codes{i}).in_elevation = 135;
site.(site.codes{i}).date_issued = datetime(2018,10,01);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

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
            for yy = 1:length(site.(site.codes{i}).years)
                yytxt = site.(site.codes{i}).years{yy};
                file = dir([fullfile(readFolder,city),'\',site.(site.codes{i}).code,'-',yytxt,'*',sptxt,'-',intxt,'*.csv']);
                if isempty(file)
                    fprintf('No file for %s in %s.\nContinuing onto the next file.\n',yytxt,folder)
                    keyboard
%                    continue
                end
                in_format = '%s%f%f%f%f%f%f%f%f%f%f%f%s';
                fn = fullfile(file.folder,file.name);
                fid = fopen(fn);
                read_dat = textscan(fid,in_format,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,2}(:,6)]; % CO2
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{1,2}(:,7)]; % CO2 std
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,2}(:,8)]; % CO2 n
                site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_unc']); read_dat{1,2}(:,11)]; % CO2 uncertainty
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); datetime(read_dat{1,1},'InputFormat','yyyy-MM-dd HH:mm:ss')]; % time
                fprintf('File read: %s\n',file.name)
            end
            
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

% Load background data, or leave it blank if it doesn't exist.

site.codes = [site.codes,'background'];
site.groups = [site.groups; 'background'];

i = length(site.codes);
site.(site.codes{i}).name = 'background';
site.(site.codes{i}).long_name = 'background';
site.(site.codes{i}).code = '';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles';
%site.(site.codes{i}).url = 'https://megacities.jpl.nasa.gov/public/Los_Angeles/In_Situ/La_Jolla/';
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
%site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'modeled'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 32.87;
site.(site.codes{i}).in_lon = -117.25;
site.(site.codes{i}).in_elevation = 0;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');

sp = 1; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};

site.(site.codes{i}).([sptxt,'_',intxt]) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [datetime(2016,01,01);datetime(2016,01,02)];
site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = [-1e34;-1e34];

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
eval('co2usa_netCDF2txt')

