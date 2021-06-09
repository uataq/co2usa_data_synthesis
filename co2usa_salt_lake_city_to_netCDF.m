% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('No outstanding questions as of 2020-11-16:\n')

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
date_issued = datetime(2020,11,17);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'salt_lake_city';
city_long_name = 'Salt Lake City';
city_url = 'https://air.utah.edu/';

i = 1;
provider(i).name = 'John C. Lin';
provider(i).address1 = 'Department of Atmospheric Sciences';
provider(i).address2 = '135 S 1460 E, room 819';
provider(i).address3 = 'Salt Lake City, UT 84112';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'University of Utah';
provider(i).email = 'John.Lin@utah.edu';
provider(i).orcid = 'https://orcid.org/0000-0003-2794-184X';
provider(i).parameter = 'Provider has contributed measurements for: ';
i = 2;
provider(i).name = 'David R. Bowling';
provider(i).address1 = 'School of Biological Sciences';
provider(i).address2 = '257 S. 1400 E.';
provider(i).address3 = 'Salt Lake City, UT 84112';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'University of Utah';
provider(i).email = 'David.Bowling@utah.edu';
provider(i).orcid = 'https://orcid.org/0000-0002-3864-4042';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'Mitchell, Logan E., John C. Lin, David R. Bowling, Diane E. Pataki, Courtenay Strong, Andrew J. Schauer, Ryan Bares, et al. Long-Term Urban Carbon Dioxide Observations Reveal Spatial and Temporal Dynamics Related to Urban Characteristics and Growth. Proceedings of the National Academy of Sciences 115, no. 12 (March 20, 2018): 2912–17. https://doi.org/10.1073/pnas.1702393115.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_created_str = date_created_str;

i = 1;
site.codes{1,i} = 'UOU';
site.(site.codes{i}).name = 'University_of_Utah';
site.(site.codes{i}).long_name = 'University of Utah';
site.(site.codes{i}).code = 'UOU';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {36};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane'};
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
site.codes{1,i} = 'DBK';
site.(site.codes{i}).name = 'Daybreak';
site.(site.codes{i}).long_name = 'Daybreak';
site.(site.codes{i}).code = 'DBK';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {5};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
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
site.codes{1,i} = 'SUG';
site.(site.codes{i}).name = 'Sugarhouse';
site.(site.codes{i}).long_name = 'Sugarhouse';
site.(site.codes{i}).code = 'SUG';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {4};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
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
site.codes{1,i} = 'MUR';
site.(site.codes{i}).name = 'Murray';
site.(site.codes{i}).long_name = 'Murray';
site.(site.codes{i}).code = 'MUR';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {6};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
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
site.codes{1,i} = 'RPK';
site.(site.codes{i}).name = 'Rose_Park';
site.(site.codes{i}).long_name = 'Rose Park';
site.(site.codes{i}).code = 'RPK';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {4};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
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
site.codes{1,i} = 'IMC';
site.(site.codes{i}).name = 'Intermountain_Medical_Center';
site.(site.codes{i}).long_name = 'Intermountain Medical Center';
site.(site.codes{i}).code = 'IMC';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {66};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
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

i = i+1;
site.codes{1,i} = 'SUN';
site.(site.codes{i}).name = 'Suncrest';
site.(site.codes{i}).long_name = 'Suncrest';
site.(site.codes{i}).code = 'SUN';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Denver'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {4};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'LiCorr 6262'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = 40.4808;
site.(site.codes{i}).in_lon = -111.8371;
site.(site.codes{i}).in_elevation = 1860;
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

i_slc_all = [1,2,3,4,6,9,10];
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
            
            
            % On 2020/11/16: Trimming end of IMC data to 2020/03/25 because of a step change that is still undetermined. 
            if strcmp(site.codes{i},'IMC')
                fprintf('*** Custom QAQC discussed with the group on Nov 2020***\n')
                fprintf('Remove step change in CO2 at IMC in March-May 2020.\n')
                ind = find(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=datetime(2020,03,25,05,00,00),1,'last');
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(1:ind);
                site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(1:ind);
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(1:ind);
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(1:ind);
            end
            
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
            fprintf('Site loaded: %s\n',site.(site.codes{i}).code)
        end
    end
end

%% Currently the only site with CH4 is UOU.
fn = dir(fullfile(readFolder,city,'v20201116','ch4_wbb.csv'));
fid = fopen(fullfile(fn.folder,fn.name));
data = textscan(fid,'%s%f%f%f','HeaderLines',1,'CollectOutput',1,'Delimiter',',');
fclose(fid);

i = find(strcmp(site.codes,'UOU'));
sp = find(strcmp(site.(site.codes{i}).species,'ch4'));
inlet = 1;
sptxt = site.(site.codes{i}).species{sp};
intxt = site.(site.codes{i}).inlet_height_long_name{inlet};


site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(data{1,1},'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z'); % time
% On 2019/08/30
% Prepping data for CO2-USA, we want to trim the data to 2018/08/01 because that is the limit of the QCed data.
%ind = find(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=datetime(2018,8,1),1,'last');
%site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(1:ind,1);

site.(site.codes{i}).([sptxt,'_',intxt]) = data{1,2}(:,1)*1000; % CH4
site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = data{1,2}(:,2)*1000; % CH4 std
site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = data{1,2}(:,3); % CH4 n

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
fprintf('Site loaded: %s for %s\n',site.(site.codes{i}).code,sptxt)

%% Updating site locations based on past site moves:

i = find(strcmp(site.codes,'SUG'));
sp = find(strcmp(site.(site.codes{i}).species,'co2'));
inlet = 1;
sptxt = site.(site.codes{i}).species{sp};
intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
t1 = 1; t2 = find(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=datetime(2007,10,12),1,'last');
site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(t1:t2) = 40.7306;
site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(t1:t2) = -111.8700;
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(t1:t2) = 1314;
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(t1:t2) = 6;

i = find(strcmp(site.codes,'UOU'));
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

%% Custom QAQC that needs updating before final archive...

% fprintf('*** Custom QAQC discussed with the group on Nov 2020***\n')
% 
% i = find(strcmp(site.codes,'IMC')); %site.(site.codes{i})
% inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'66m')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
% 
% % CO2 QC
% sp = find(strcmp(site.(site.codes{i}).species,'co2')); sptxt = site.(site.codes{i}).species{sp};
% mask = false(size(site.(site.codes{i}).([sptxt,'_',intxt])));
% fprintf('Remove step change in CO2 at IMC in March 2020 through the end of the data.\n')
% t1 = datetime(2020,03,25,05,00,00); t2 = datetime(2020,05,07,00,00,00);
% mask(and(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])>=t1,site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=t2)) = true;
% 
% fprintf('Remove short spike of low CO2 at DBK on Apr 13, 2020\n')
% t1 = datetime(2020,04,13,21,00,00); t2 = datetime(2020,04,13,23,00,00);
% mask(and(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])>=t1,site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<=t2)) = true;

% site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -9999.0;

% Optional plots to spot check the data.

%%
% i = 1;
% site.(site.codes{i}).species
% intxt = site.(site.codes{i}).inlet_height_long_name{1};
% sptxt = site.(site.codes{i}).species{2};
% mask = true(size(site.(site.codes{i}).([sptxt,'_',intxt])));
% mask(site.(site.codes{i}).([sptxt,'_',intxt])==-9999) = false;
% figure(1); clf;
% plot(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(mask),site.(site.codes{i}).([sptxt,'_',intxt])(mask))
% grid on; ylabel(sptxt); title(site.codes{i})

%%
%return

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


