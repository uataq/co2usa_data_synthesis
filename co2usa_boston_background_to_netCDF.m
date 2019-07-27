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
date_created_str = datestr(datenum(2019,07,09),'yyyy-mm-dd');
%date_created_SLC_CO2 = datestr(datenum(2017,07,11),'yyyy-mm-dd');

date_issued_now = datestr(now,'yyyy-mm-dd');
date_issued = datetime(2019,07,09);
date_issued_str = datestr(date_issued,'yyyy-mm-dd');

% Working folders
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');


%% City & provider information:

city = 'boston';
city_long_name = 'Boston';
city_url = 'http://atmos.seas.harvard.edu/lab/index.html';

i = 1;
provider(i).name = 'Maryann Sargent';
provider(i).address1 = 'Harvard University School of Engineering and Applied Sciences';
provider(i).address2 = '20 Oxford St';
provider(i).address3 = 'Cambridge, MA 02138';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Harvard University School of Engineering and Applied Sciences';
provider(i).email = 'mracine@fas.harvard.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

i = 2;
provider(i).name = 'Steven Wofsy';
provider(i).address1 = 'Harvard University School of Engineering and Applied Sciences';
provider(i).address2 = '20 Oxford St';
provider(i).address3 = 'Cambridge, MA 02138';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Harvard University School of Engineering and Applied Sciences';
provider(i).email = 'wofsy@g.harvard.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';


%% Site meta data

clear site % start fresh

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.codes = {}; % List of the site "codes"

i = 1;
site.codes{1,i} = 'background';

site.(site.codes{i}).code = upper(site.codes{i});
site.(site.codes{i}).name = 'background';
site.(site.codes{i}).long_name = 'background';

site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York';
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
site.(site.codes{i}).species = {'co2','ch4'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide','methane'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
site.(site.codes{i}).instrument = {'modeled','modeled'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
site.(site.codes{i}).in_lat = 42.3601;
site.(site.codes{i}).in_lon = -71.0589;
site.(site.codes{i}).in_elevation = 10;
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = date_issued_str;

% CO2 background:
sp = 1; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
site.groups = [site.groups; {[site.(site.codes{i}).name,'_',sptxt]}];
site.species = [site.species; {sptxt}];
site.(site.codes{i}).files = dir(fullfile(readFolder,city,'background','bound_*.txt'));
site.(site.codes{i}).files_header_lines = nan(1,length(site.(site.codes{i}).files));
site.(site.codes{i}).([sptxt,'_',intxt]) = [];
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
for fn = 1:length(site.(site.codes{i}).files)
        fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
        formatSpec = '%f%f%f%f%f'; % Yr,Mn,Dy,Hr,sp
        header_lines = 0;
        readNextLine = true;
        while readNextLine==true
            tline = fgets(fid);
            header_lines = header_lines+1;
            if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
        end
        frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        site.(site.codes{i}).files_header_lines(1,fn) = header_lines-1;
        
        % Read the data file after skipping the header lines.
        read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).files_header_lines(1,fn),'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NA');
        fclose(fid);
        
        site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,5)]; % species mixing ratio
        
        site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
            datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1))]; % time
end
% Removes the leading and trailing NaNs
data_range_ind = find(site.(site.codes{i}).([sptxt,'_',intxt])~=-1e34,1,'first'):find(site.(site.codes{i}).([sptxt,'_',intxt])~=-1e34,1,'last');
site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
clear data_range_ind
%site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;
%site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;
%site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;
site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
%site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;

% CH4 background:
sp = 2; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
site.groups = [site.groups; {[site.(site.codes{i}).name,'_',sptxt]}];
site.species = [site.species; {sptxt}];
site.(site.codes{i}).files = dir(fullfile(readFolder,city,'background','ch4_bg.txt'));
site.(site.codes{i}).files_header_lines = nan(1,length(site.(site.codes{i}).files));
site.(site.codes{i}).([sptxt,'_',intxt]) = [];
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
for fn = 1:length(site.(site.codes{i}).files)
        fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
        formatSpec = '%f%f%f%f%f'; % Yr,Mn,Dy,Hr,sp
        header_lines = 0;
        readNextLine = true;
        while readNextLine==true
            tline = fgets(fid);
            header_lines = header_lines+1;
            if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
        end
        frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        site.(site.codes{i}).files_header_lines(1,fn) = header_lines-1;
        
        % Read the data file after skipping the header lines.
        read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).files_header_lines(1,fn),'Delimiter',', ','CollectOutput',true,'TreatAsEmpty','NA');
        fclose(fid);
        
        site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,5)]; % species mixing ratio
        
        site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
            datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1))]; % time
end
% Removes the leading and trailing NaNs
data_range_ind = find(site.(site.codes{i}).([sptxt,'_',intxt])~=-1e34,1,'first'):find(site.(site.codes{i}).([sptxt,'_',intxt])~=-1e34,1,'last');
site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
clear data_range_ind
%site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;
%site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;
%site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;
site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
%site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = ones(length(site.(site.codes{i}).([sptxt,'_',intxt])),1)*-1e34;


site.date_issued = date_issued;
site.date_issued_str = date_issued_str;

site.reference = ['McKain K, Down A, Racit S M, Budney J, Hutyra L R, Floerchinger C, Herndon S C, Nehrkorn T, Zahniser M S, Jackson R B, Phillips N, and Wofsy S. (2015) Methane emissions from natural gas infrastructure and use in the urban region of Boston, Massachusetts. Proc Natl Acad Sci U.S.A. 112(7):1941-6.; ',...
 'Sargent M, Barrera Y, Nehrkorn T, Lucy R. Hutyra L R, Gately C, Jones T, Kathryn McKain K, Sweeney C, Hegarty J, Hardiman B, and Wofsy S (2018) Anthropogenic and biogenic CO2 fluxes in the Boston urban region, Proc Natl Acad Sci USA, submitted.'];

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


