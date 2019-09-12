clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('Outstanding questions as of 10/23/2018:\n')
fprintf('- Add SUN?\n')

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
date_issued = datetime(2019,07,01);
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
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

i = 1;
site.codes{1,i} = 'uou';
site.(site.codes{i}).name = 'University_of_Utah';
site.(site.codes{i}).long_name = 'University of Utah';
site.(site.codes{i}).code = 'UOU';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {36};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'Los Gatos Research Ultraportable Greenhouse Gas Analyzer','Los Gatos Research Ultraportable Greenhouse Gas Analyzer'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 40.7663;
site.(site.codes{i}).in_lon = -111.8478;
site.(site.codes{i}).in_elevation = 1436;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'dbk';
site.(site.codes{i}).name = 'Daybreak';
site.(site.codes{i}).long_name = 'Daybreak';
site.(site.codes{i}).code = 'DBK';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {5};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCorr 6262'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.5383;
site.(site.codes{i}).in_lon = -112.0697;
site.(site.codes{i}).in_elevation = 1582;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'sug';
site.(site.codes{i}).name = 'Sugarhouse';
site.(site.codes{i}).long_name = 'Sugarhouse';
site.(site.codes{i}).code = 'SUG';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {4};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCorr 6262'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.7398;
site.(site.codes{i}).in_lon = -111.8580;
site.(site.codes{i}).in_elevation = 1328;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'mur';
site.(site.codes{i}).name = 'Murray';
site.(site.codes{i}).long_name = 'Murray';
site.(site.codes{i}).code = 'MUR';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {6};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCorr 6262'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.6539;
site.(site.codes{i}).in_lon = -111.8878;
site.(site.codes{i}).in_elevation = 1322;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'rpk';
site.(site.codes{i}).name = 'Rose_Park';
site.(site.codes{i}).long_name = 'Rose Park';
site.(site.codes{i}).code = 'RPK';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {4};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCorr 6262'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.7944;
site.(site.codes{i}).in_lon = -111.9319;
site.(site.codes{i}).in_elevation = 1289;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'imc';
site.(site.codes{i}).name = 'Intermountain_Medical_Center';
site.(site.codes{i}).long_name = 'Intermountain Medical Center';
site.(site.codes{i}).code = 'IMC';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {66};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCorr 6262'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.6602;
site.(site.codes{i}).in_lon = -111.8911;
site.(site.codes{i}).in_elevation = 1316;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

%% Loading the data

load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'code','SLC CO2','Data','data_slcco2.mat'))
load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'code','SLC CO2','Data','data_slcco2_modern.mat'))

% i = 3;
% figure(1);clf;hold on
% plot(datetime(c.tUTC{i,1},'ConvertFrom','datenum'),c.data{i,1}(:,7))
% plot(datetime(cm.tUTC{i,1},'ConvertFrom','datenum'),cm.data{i,1}(:,7))
% hold off
% grid on
% legend(['Historic ',cm.siteCode{i,1}],['Modern ',cm.siteCode{i,1}])

if length(cm.data)>length(c.data)
    for i = length(c.data)+1:length(cm.data)
        c.data{i,1} = nan(1,9);
        c.tMST{i,1} = 0;
        c.tMDT{i,1} = 0;
        c.tUTC{i,1} = 0;
    end
end

i_slc_all = [1,2,3,4,6,9];
for i = 1:length(i_slc_all)
    i_slc = i_slc_all(i);
    if isempty(cm.data{i_slc,1})
        cm.data{i_slc,1} = nan(1,9);
        cm.tUTC{i_slc,1} = 0;
    end
    
    for sp = 1 %:length(site.(site.codes{i}).species) % only doing CO2 for now.
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            site.(site.codes{i}).([sptxt,'_',intxt]) = [c.data{i_slc,1}(:,7);cm.data{i_slc,1}(:,7)]; % CO2
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [c.data{i_slc,1}(:,8);cm.data{i_slc,1}(:,8)]; % CO2 std
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [c.data{i_slc,1}(:,9);cm.data{i_slc,1}(:,9)]; % CO2 n
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime([c.tUTC{i_slc,1};cm.tUTC{i_slc,1}],'ConvertFrom','datenum'); % time
            
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
            fprintf('Site loaded: %s\n',site.(site.codes{i}).code)
        end
    end
end

%% Currently the only site with CH4 is UOU.
fn = dir(fullfile(readFolder,city,'v20190830','ch4_wbb.csv'));
fid = fopen(fullfile(fn.folder,fn.name));
data = textscan(fid,'%s%f%f%f','HeaderLines',1,'CollectOutput',1,'Delimiter',',');
fclose(fid);

i = find(strcmp(site.codes,'uou'));
sp = find(strcmp(site.(site.codes{i}).species,'ch4'));
inlet = 1;
sptxt = site.(site.codes{i}).species{sp};
intxt = site.(site.codes{i}).inlet_height_long_name{inlet};

% On 2019/08/30
% Prepping data for CO2-USA, we want to trim the data to 2018/08/01 because that is the limit of the QCed data.

site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(data{1,1},'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z'); % time
ind = find(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=datetime(2018,8,1),1,'last');
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(1:ind);

site.(site.codes{i}).([sptxt,'_',intxt]) = data{1,2}(1:ind,1)*1000; % CH4
site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = data{1,2}(1:ind,2)*1000; % CH4 std
site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = data{1,2}(1:ind,3); % CH4 n

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
fprintf('Site loaded: %s for %s\n',site.(site.codes{i}).code,sptxt)

%% Updating site locations based on past site moves:

i = find(strcmp(site.codes,'sug'));
sp = find(strcmp(site.(site.codes{i}).species,'co2'));
inlet = 1;
sptxt = site.(site.codes{i}).species{sp};
intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
t1 = 1; t2 = find(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=datetime(2007,10,12),1,'last');
site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(t1:t2) = 40.7306;
site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(t1:t2) = -111.8700;
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(t1:t2) = 1314;
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(t1:t2) = 6;

i = find(strcmp(site.codes,'uou'));
sp = find(strcmp(site.(site.codes{i}).species,'co2')); % This is only for CO2 since CH4 was added after the move.
inlet = 1;
sptxt = site.(site.codes{i}).species{sp};
intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
t1 = 1;
t2 = find(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=datetime(2013,10,09),1,'last');
site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(t1:t2) = 40.7634;
site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(t1:t2) = -111.8484;
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(t1:t2) = 1427;
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(t1:t2) = 20;

%% Identify the netCDF files to create based on species.

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

