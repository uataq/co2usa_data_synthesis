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
date_issued = datetime(2019,07,01);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');


%% City & provider information:

city = 'indianapolis';
city_long_name = 'Indianapolis';
city_url = 'http://sites.psu.edu/influx/';

% http://www.datacommons.psu.edu/commonswizard/MetadataDisplay.aspx?Dataset=6150
% ftp://data1.commons.psu.edu/pub/commons/meteorology/influx/influx-tower-data/

provider(1).name = 'Natasha L. Miles';
provider(1).address1 = 'Penn State Department of Meteorology and Atmospheric Science';
provider(1).address2 = '412 Walker Building';
provider(1).address3 = 'University Park, PA 16802';
provider(1).country = 'United States';
provider(1).city = city_long_name;
provider(1).affiliation = 'Penn State Department of Meteorology and Atmospheric Science';
provider(1).email = 'nmiles@psu.edu';
provider(1).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/nlm136

provider(2).name = 'Scott J. Richardson';
provider(2).address1 = 'Penn State Department of Meteorology and Atmospheric Science';
provider(2).address2 = '414 Walker Building';
provider(2).address3 = 'University Park, PA 16802';
provider(2).country = 'United States';
provider(2).city = city_long_name;
provider(2).affiliation = 'Penn State Department of Meteorology and Atmospheric Science';
provider(2).email = 'srichardson@psu.edu';
provider(2).parameter = 'Provider has contributed measurements for: ';
%http://www.met.psu.edu/people/sjr17

%% Site meta data

clear site % start fresh

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.codes = {}; % List of the site "codes"

site.date_issued = date_issued; % This date will be updated with the most recent date in the files below.
site.date_issued_str = date_issued_str; % This date will be updated with the most recent date in the files below.

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
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane','carbon_monoxide'};
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
    site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -1e34;
    site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(ones(length(read_dat{1,1}),1)*2013,ones(length(read_dat{1,1}),1),read_dat{1,1}(:,2),read_dat{1,1}(:,5),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1));
    %site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(read_dat{1,1}),1)*-1e34;
    %site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(read_dat{1,1}),1)*-1e34;
    %site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(read_dat{1,1}),1)*-1e34;
    site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
    %site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(read_dat{1,1}),1)*-1e34;
    
    site.groups = [site.groups; {[site.(site.codes{i}).name,'_',sptxt]}];
    site.species = [site.species; {sptxt}];
end

site.reference = 'Richardson, Scott J., Natasha L. Miles, Kenneth J. Davis, Thomas Lauvaux, Douglas K. Martins, Jocelyn C. Turnbull, Kathryn McKain, Colm Sweeney, and Maria Obiminda L. Cambaliza. “Tower Measurement Network of In-Situ CO2, CH4, and CO in Support of the Indianapolis FLUX (INFLUX) Experiment.” Elem Sci Anth 5, no. 0 (October 19, 2017). https://doi.org/10.1525/elementa.140.';

fprintf('---- %-6s loading complete ----\n\n',site.codes{i})


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


