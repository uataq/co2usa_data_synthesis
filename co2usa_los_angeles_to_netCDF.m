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
date_issued = datetime(2017,05,17);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Output folder
writeFolder = [pwd,'\synthesis_output\'];

%% City & provider information:

city = 'los_angeles';
city_long_name = 'Los Angeles';
city_url = 'https://megacities.jpl.nasa.gov/';

provider(1).name = 'Kristal Verhulst';
provider(1).address1 = 'Jet Propulsion Laboratory M/S 233-300';
provider(1).address2 = '4800 Oak Grove Drive';
provider(1).address3 = 'Pasadena, CA 91109';
provider(1).country = 'United States';
provider(1).city = city_long_name;
provider(1).affiliation = 'NASA Jet Propulsion Laboratory (JPL)';
provider(1).email = 'Kristal.R.Verhulst@jpl.nasa.gov';
provider(1).parameter = 'Provider has contributed measurements for: ';

provider(2).name = 'Riley Duren';
provider(2).address1 = 'Jet Propulsion Laboratory';
provider(2).address2 = '4800 Oak Grove Drive';
provider(2).address3 = 'Pasadena, CA 91109';
provider(2).country = 'United States';
provider(2).city = city_long_name;
provider(2).affiliation = 'NASA Jet Propulsion Laboratory (JPL)';
provider(2).email = 'Riley.M.Duren@jpl.nasa.gov';
provider(2).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'Verhulst, Kristal R., Anna Karion, Jooil Kim, Peter K. Salameh, Ralph F. Keeling, Sally Newman, John Miller, et al. “Carbon Dioxide and Methane Measurements from the Los Angeles Megacity Carbon Project – Part 1: Calibration, Urban Enhancements, and Uncertainty Estimates.” Atmospheric Chemistry and Physics 17, no. 13 (July 7, 2017): 8313–41. https://doi.org/10.5194/acp-17-8313-2017.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

i = 1;
site.codes{1,i} = 'cit';
site.(site.codes{i}).name = 'Caltech';
site.(site.codes{i}).long_name = 'Caltech';
site.(site.codes{i}).code = 'CIT';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {48};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 34.14;
site.(site.codes{i}).in_lon = -118.13;
site.(site.codes{i}).in_elevation = 230;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'cnp';
site.(site.codes{i}).name = 'Canoga_Park';
site.(site.codes{i}).long_name = 'Canoga Park';
site.(site.codes{i}).code = 'CNP';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {15};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 34.19;
site.(site.codes{i}).in_lon = -118.60;
site.(site.codes{i}).in_elevation = 245;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'com';
site.(site.codes{i}).name = 'Compton';
site.(site.codes{i}).long_name = 'Compton';
site.(site.codes{i}).code = 'COM';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {25,45};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 33.87;
site.(site.codes{i}).in_lon = -118.28;
site.(site.codes{i}).in_elevation = 9;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'ful';
site.(site.codes{i}).name = 'CSU_Fullerton';
site.(site.codes{i}).long_name = 'CSU Fullerton';
site.(site.codes{i}).code = 'FUL';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {50};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 33.88;
site.(site.codes{i}).in_lon = -117.88;
site.(site.codes{i}).in_elevation = 75;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'gra';
site.(site.codes{i}).name = 'Granada_Hills';
site.(site.codes{i}).long_name = 'Granada Hills';
site.(site.codes{i}).code = 'GRA';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {31,51};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 34.28;
site.(site.codes{i}).in_lon = -118.47;
site.(site.codes{i}).in_elevation = 391;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'ljo';
site.(site.codes{i}).name = 'La_Jolla';
site.(site.codes{i}).long_name = 'La Jolla';
site.(site.codes{i}).code = 'LJO';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles';
site.(site.codes{i}).inlet_height = {13};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 32.87;
site.(site.codes{i}).in_lon = -117.25;
site.(site.codes{i}).in_elevation = 0;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'ont';
site.(site.codes{i}).name = 'Ontario';
site.(site.codes{i}).long_name = 'Ontario';
site.(site.codes{i}).code = 'ONT';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles';
site.(site.codes{i}).inlet_height = {25,41};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 34.06;
site.(site.codes{i}).in_lon = -117.58;
site.(site.codes{i}).in_elevation = 260;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'sci';
site.(site.codes{i}).name = 'San_Clemente_Island';
site.(site.codes{i}).long_name = 'San Clemente Islan';
site.(site.codes{i}).code = 'SCI';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {27};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 32.92;
site.(site.codes{i}).in_lon = -118.49;
site.(site.codes{i}).in_elevation = 489;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'irv';
site.(site.codes{i}).name = 'UC_Irvine';
site.(site.codes{i}).long_name = 'UC Irvine';
site.(site.codes{i}).code = 'IRV';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles';
site.(site.codes{i}).inlet_height = {20};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 33.64;
site.(site.codes{i}).in_lon = -117.84;
site.(site.codes{i}).in_elevation = 10;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'usc1';
site.(site.codes{i}).name = 'USC1';
site.(site.codes{i}).long_name = 'University of Southern California (downtown LA) 1';
site.(site.codes{i}).code = 'USC1';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles';
site.(site.codes{i}).inlet_height = {50};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 34.02;
site.(site.codes{i}).in_lon = -118.29;
site.(site.codes{i}).in_elevation = 55;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'usc2';
site.(site.codes{i}).name = 'USC2';
site.(site.codes{i}).long_name = 'University of Southern California (downtown LA) 2';
site.(site.codes{i}).code = 'USC2';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {50};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 34.02;
site.(site.codes{i}).in_lon = -118.29;
site.(site.codes{i}).in_elevation = 55;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'vic';
site.(site.codes{i}).name = 'Victorville';
site.(site.codes{i}).long_name = 'Victorville';
site.(site.codes{i}).code = 'VIC';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles';
site.(site.codes{i}).inlet_height = {50,100};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).years = {'2015','2016'};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','Picarro G2301'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 34.61;
site.(site.codes{i}).in_lon = -117.29;
site.(site.codes{i}).in_elevation = 1370;
site.(site.codes{i}).date_issued = datetime(2017,05,17);
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

% Loading the data

readFolder = [pwd,'\data_input\'];

for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            site.(site.codes{i}).([sptxt,'_',intxt]) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
            for yy = 1:length(site.(site.codes{i}).years)
                yytxt = site.(site.codes{i}).years{yy};
                folder = fullfile(readFolder,city,'in_situ',site.(site.codes{i}).name,[yytxt,'_Measurements']);
                file = dir([folder,'\',site.(site.codes{i}).code,'-',yytxt,'*',sptxt,'-',intxt,'*.csv']);
                if isempty(file) % The 'rooftop' sites don't include the intxt in the file name.
                    file = dir([folder,'\',site.(site.codes{i}).code,'-',yytxt,'*',sptxt,'-','*.csv']);
                end
                
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
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,2}(:,9)]; % CO2 n
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); datetime(read_dat{1,1},'InputFormat','dd-MMM-yyyy HH:mm:ss')]; % time
                fprintf('File read: %s\n',file.name)
            end
            
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = repmat(site.(site.codes{i}).inlet_height{inlet},length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Set fill values:
            site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_std']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_n']))) = -1e34;
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

