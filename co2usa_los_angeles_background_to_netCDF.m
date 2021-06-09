% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

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
date_issued = datetime(2020,07,21);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'los_angeles';
city_long_name = 'Los Angeles';
city_url = 'https://megacities.jpl.nasa.gov/';

i=1;
provider(i).name = 'Jooil Kim';
provider(i).address1 = 'Scripps Institution of Oceanography';
provider(i).address2 = '9500 Gilman Dr #0244';
provider(i).address3 = 'La Jolla, CA 92093-0244';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Scripps Institution of Oceanography';
provider(i).email = 'jjkim@ucsd.edu';
provider(i).orcid = 'https://orcid.org/0000-0002-2610-4882';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=i+1;
provider(i).name = 'Kristal R. Verhulst';
provider(i).address1 = 'Jet Propulsion Laboratory M/S 233-300';
provider(i).address2 = '4800 Oak Grove Drive';
provider(i).address3 = 'Pasadena, CA 91109';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Jet Propulsion Laboratory, California Institute of Technology';
provider(i).email = 'Kristal.R.Verhulst@jpl.nasa.gov';
provider(i).orcid = 'https://orcid.org/0000-0001-5678-9678';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=i+1;
provider(i).name = 'Charles E. Miller';
provider(i).address1 = 'Jet Propulsion Laboratory M/S 183-501';
provider(i).address2 = '4800 Oak Grove Drive';
provider(i).address3 = 'Pasadena, CA 91109';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Jet Propulsion Laboratory, California Institute of Technology';
provider(i).email = 'Charles.E.Miller@jpl.nasa.gov';
provider(i).orcid = 'https://orcid.org/0000-0002-9380-4838';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=i+1;
provider(i).name = 'Ray F. Weiss';
provider(i).address1 = 'Scripps Institution of Oceanography';
provider(i).address2 = '9500 Gilman Dr #0244';
provider(i).address3 = 'La Jolla, CA 92093-0244';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Scripps Institution of Oceanography';
provider(i).email = 'rfweiss@uscd.edu';
provider(i).orcid = 'https://orcid.org/0000-0001-9551-7739';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=i+1;
provider(i).name = 'Ralph F. Keeling';
provider(i).address1 = 'Scripps Institution of Oceanography';
provider(i).address2 = '9500 Gilman Dr #0244';
provider(i).address3 = 'La Jolla, CA 92093-0244';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Scripps Institution of Oceanography';
provider(i).email = 'rkeeling@uscd.edu';
provider(i).orcid = 'https://orcid.org/0000-0002-9749-2253';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=i+1;
provider(i).name = 'Steve Prinzivalli';
provider(i).address1 = 'Earth Networks Inc.';
provider(i).address2 = '12410 Milestone Center Dr., Suite 300';
provider(i).address3 = 'Germantown, MD 20876';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Earth Networks Inc.';
provider(i).email = 'sprinzivalli@earthnetworks.com';
provider(i).orcid = '';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.codes = {}; % List of the site "codes"

site.date_issued = date_issued; % This date will be updated with the most recent date in the files below.
site.date_issued_str = date_issued_str; % This date will be updated with the most recent date in the files below.
site.date_created_str = date_created_str;

i = 1;
site.codes{1,i} = 'background';

site.(site.codes{i}).code = upper(site.codes{i});
site.(site.codes{i}).name = 'background';
site.(site.codes{i}).long_name = 'background';

site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'smooth_curve','smooth_curve','smooth_curve'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 34.0522;
site.(site.codes{i}).in_lon = -118.2437;
site.(site.codes{i}).in_elevation = 94;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;

version_folder = 'v20200721';
fn = dir(fullfile(readFolder,city,version_folder,'background_estimates_20200721','SCI_BG_smooth_curve20200721_edit.csv'));

fid = fopen(fullfile(fn.folder,fn.name));
formatSpec = '%s%f%f%f%f%f%f%f';
header_lines = 1;
read_dat = textscan(fid,formatSpec,'HeaderLines',header_lines,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
fclose(fid);

for sp = 1:length(site.(site.codes{i}).species)
    sptxt = site.(site.codes{i}).species{sp};
    inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
    if strcmp(sptxt,'co2'); col.species = 2; col.uncertainty = 3; end
    if strcmp(sptxt,'ch4'); col.species = 4; col.uncertainty = 5; end
    if strcmp(sptxt,'co'); col.species = 6; col.uncertainty = 7; end
    
    site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(read_dat{1,1},'InputFormat','dd-MMM-yyyy HH:mm:ss');
    site.(site.codes{i}).([sptxt,'_',intxt]) = read_dat{1,2}(:,col.species);
    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(read_dat{1,1}),1)*-9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(read_dat{1,1}),1)*-9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = read_dat{1,2}(:,col.uncertainty);
    
    % Removes the leading and trailing NaNs
    data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
    site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(data_range_ind);
    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(data_range_ind);
    site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(data_range_ind);
    site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
    clear data_range_ind
    
    site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_unc']))) = -9999.0;
    
    site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-9999.0;
    
    site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).name]}];
    site.species = [site.species; {sptxt}];
end

site.reference = 'Verhulst, Kristal R., Anna Karion, Jooil Kim, Peter K. Salameh, Ralph F. Keeling, Sally Newman, John Miller, et al. Carbon Dioxide and Methane Measurements from the Los Angeles Megacity Carbon Project – Part 1: Calibration, Urban Enhancements, and Uncertainty Estimates. Atmospheric Chemistry and Physics 17, no. 13 (July 7, 2017): 8313–41. https://doi.org/10.5194/acp-17-8313-2017.';

fprintf('---- %-6s loading complete ----\n\n',site.codes{i})

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


