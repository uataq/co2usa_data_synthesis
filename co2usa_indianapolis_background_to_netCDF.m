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
date_issued = datetime(2019,07,01);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'indianapolis';
city_long_name = 'Indianapolis';
city_url = 'http://sites.psu.edu/influx/';

% http://www.datacommons.psu.edu/commonswizard/MetadataDisplay.aspx?Dataset=6150
% ftp://data1.commons.psu.edu/pub/commons/meteorology/influx/influx-tower-data/

i=1;
provider(i).name = 'Natasha L. Miles';
provider(i).address1 = 'Department of Meteorology and Atmospheric Science';
provider(i).address2 = '412 Walker Building';
provider(i).address3 = 'University Park, PA 16802';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'The Pennsylvania State University';
provider(i).email = 'nmiles@psu.edu';
provider(i).orcid = 'https://orcid.org/0000-0003-4266-2726';
provider(i).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/nlm136

i=2;
provider(i).name = 'Kenneth J. Davis';
provider(i).address1 = 'Department of Meteorology and Atmospheric Science';
provider(i).address2 = '512 Walker Building';
provider(i).address3 = 'University Park, PA 16802';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'The Pennsylvania State University';
provider(i).email = 'kjd10@psu.edu';
provider(i).orcid = 'https://orcid.org/0000-0002-1992-8381';
provider(i).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/kjd10

i=3;
provider(i).name = 'Scott J. Richardson';
provider(i).address1 = 'Department of Meteorology and Atmospheric Science';
provider(i).address2 = '414 Walker Building';
provider(i).address3 = 'University Park, PA 16802';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'The Pennsylvania State University';
provider(i).email = 'srichardson@psu.edu';
provider(i).orcid = '';
provider(i).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/sjr17

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
site.(site.codes{i}).time_zone = 'America/Indianapolis';
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'upwind_tower','upwind_tower','upwind_tower'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 39.7685;
site.(site.codes{i}).in_lon = -86.1581;
site.(site.codes{i}).in_elevation = 223;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;

fn = dir(fullfile(readFolder,city,'background','INFLUX_backgrounds_2013_2017.dat'));

fid = fopen(fullfile(fn.folder,fn.name));
formatSpec = '%f%f%f%f%f%f%f%f'; % Yr,Mn,Dy,Hr,sp
header_lines = 1;
read_dat = textscan(fid,formatSpec,'HeaderLines',header_lines,'Delimiter',',\t','CollectOutput',true,'TreatAsEmpty','NaN');
fclose(fid);

for sp = 1:length(site.(site.codes{i}).species)
    sptxt = site.(site.codes{i}).species{sp};
    inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
    if strcmp(sptxt,'co2'); col.species = 6; end
    if strcmp(sptxt,'ch4'); col.species = 7; end
    if strcmp(sptxt,'co'); col.species = 8; end
                
    site.(site.codes{i}).([sptxt,'_',intxt]) = read_dat{1,1}(:,col.species);
    site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(ones(length(read_dat{1,1}),1)*2013,ones(length(read_dat{1,1}),1),read_dat{1,1}(:,2),read_dat{1,1}(:,5),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1));
    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(read_dat{1,1}),1)*-9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(read_dat{1,1}),1)*-9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(read_dat{1,1}),1)*-9999.0;
    site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(read_dat{1,1}),1)*-9999.0;
    
    site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).name]}];
    site.species = [site.species; {sptxt}];
end

site.reference = 'Richardson, Scott J., Natasha L. Miles, Kenneth J. Davis, Thomas Lauvaux, Douglas K. Martins, Jocelyn C. Turnbull, Kathryn McKain, Colm Sweeney, and Maria Obiminda L. Cambaliza. Tower Measurement Network of In-Situ CO2, CH4, and CO in Support of the Indianapolis FLUX (INFLUX) Experiment. Elem Sci Anth 5, no. 0 (October 19, 2017). https://doi.org/10.1525/elementa.140.';

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


