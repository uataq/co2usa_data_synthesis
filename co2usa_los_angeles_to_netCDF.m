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
date_issued = datetime(2021,03,30);
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
provider(i).name = 'Kristal Verhulst';
provider(i).address1 = 'Jet Propulsion Laboratory M/S 233-300';
provider(i).address2 = '4800 Oak Grove Drive';
provider(i).address3 = 'Pasadena, CA 91109';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'NASA Jet Propulsion Laboratory (JPL)';
provider(i).email = 'jjkim@ucsd.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=2;
provider(i).name = 'Kristal Verhulst';
provider(i).address1 = 'Jet Propulsion Laboratory M/S 233-300';
provider(i).address2 = '4800 Oak Grove Drive';
provider(i).address3 = 'Pasadena, CA 91109';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'NASA Jet Propulsion Laboratory (JPL)';
provider(i).email = 'Kristal.R.Verhulst@jpl.nasa.gov';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=3;
provider(i).name = 'Charles Miller';
provider(i).address1 = 'Jet Propulsion Laboratory M/S 183-501';
provider(i).address2 = '4800 Oak Grove Drive';
provider(i).address3 = 'Pasadena, CA 91109';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'NASA Jet Propulsion Laboratory (JPL)';
provider(i).email = 'Charles.E.Miller@jpl.nasa.gov';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=4;
provider(i).name = 'Ray Weiss';
provider(i).address1 = 'Scripps Institution of Oceanography';
provider(i).address2 = '9500 Gilman Dr #0244';
provider(i).address3 = 'La Jolla, CA 92093-0244';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Scripps Institution of Oceanography';
provider(i).email = 'rfweiss@uscd.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=5;
provider(i).name = 'Ralph Keeling';
provider(i).address1 = 'Scripps Institution of Oceanography';
provider(i).address2 = '9500 Gilman Dr #0244';
provider(i).address3 = 'La Jolla, CA 92093-0244';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Scripps Institution of Oceanography';
provider(i).email = 'rkeeling@uscd.edu';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=6;
provider(i).name = 'Steve Prinzivalli';
provider(i).address1 = 'Earth Networks';
provider(i).address2 = '12410 Milestone Center Dr., Suite 300';
provider(i).address3 = 'Germantown, MD 20876';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Earth Networks';
provider(i).email = 'sprinzivalli@earthnetworks.com';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = 'Verhulst, Kristal R., Anna Karion, Jooil Kim, Peter K. Salameh, Ralph F. Keeling, Sally Newman, John Miller, et al. Carbon Dioxide and Methane Measurements from the Los Angeles Megacity Carbon Project – Part 1: Calibration, Urban Enhancements, and Uncertainty Estimates. Atmospheric Chemistry and Physics 17, no. 13 (July 7, 2017): 8313–41. https://doi.org/10.5194/acp-17-8313-2017.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = date_issued_str;
site.date_created_str = date_created_str;

version_folder = 'v20210330';

fn = dir(fullfile(readFolder,city,version_folder,'LAM_sites.csv'));
fid = fopen(fullfile(fn.folder,fn.name));
read_dat = textscan(fid,'%s%s%f%s%s%f%f%f%f%f','HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
fclose(fid);

for i = 1:size(read_dat{1},1)
    site.codes{1,i} = read_dat{1}{i,1};
    site.(site.codes{i}).name = replace(read_dat{1}{i,2},' ','_');
    site.(site.codes{i}).long_name = read_dat{1}{i,2};
    site.(site.codes{i}).code = site.codes{1,i};
    site.(site.codes{i}).country = 'United States';
    site.(site.codes{i}).time_zone = 'America/Los_Angeles'; % use timezones to find out the available time zone designations.
    site.(site.codes{i}).inlet_height = num2cell(unique(read_dat{4}(i,[4,5])));
    for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
    site.(site.codes{i}).files =  dir(fullfile(readFolder,city,version_folder,[site.codes{1,i},'*.csv']));
    site.(site.codes{i}).species = {};
    for k = 1:length(site.(site.codes{i}).files)
        idx = strfind(site.(site.codes{i}).files(k).name,'-');
        site.(site.codes{i}).species = unique([site.(site.codes{i}).species,{site.(site.codes{i}).files(k).name(idx(2)+1:idx(3)-1)}]);
    end
    for j = 1:length(site.(site.codes{i}).species)
        if strcmp(site.(site.codes{i}).species{1,j},'co2')
            site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO2 X2007';
            site.(site.codes{i}).species_standard_name{1,j} = 'carbon_dioxide';
            site.(site.codes{i}).species_units_long_name{1,j} = 'ppm';
            site.(site.codes{i}).species_units{1,j} = 'micromol mol-1';
            site.(site.codes{i}).instrument{1,j} = 'Picarro G2301';
        elseif strcmp(site.(site.codes{i}).species{1,j},'ch4')
            site.(site.codes{i}).calibration_scale{1,j} = 'WMO CH4 X2004A';
            site.(site.codes{i}).species_standard_name{1,j} = 'methane';
            site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
            site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
            site.(site.codes{i}).instrument{1,j} = 'Picarro G2301';
        elseif strcmp(site.(site.codes{i}).species{1,j},'co')
            site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO X2014A';
            site.(site.codes{i}).species_standard_name{1,j} = 'carbon_monoxide';
            site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
            site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
            site.(site.codes{i}).instrument{1,j} = 'Picarro G2301';
        end
    end
    site.(site.codes{i}).date_issued = date_issued;
    site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
    site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
end

%% Loading the data

for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species)
        sptxt = site.(site.codes{i}).species{sp};
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            site.(site.codes{i}).([sptxt,'_',intxt]) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_files']) = dir(fullfile(readFolder,city,version_folder,[site.codes{i},'*',sptxt,'*',intxt,'*.csv']));
            
            if isempty(site.(site.codes{i}).([sptxt,'_',intxt,'_files'])) % The 'rooftop' sites don't include the intxt in the file name.
                site.(site.codes{i}).([sptxt,'_',intxt,'_files']) = dir(fullfile(readFolder,city,version_folder,[site.codes{i},'*',sptxt,'-all-','*.csv']));
            end

            if isempty(site.(site.codes{i}).([sptxt,'_',intxt,'_files']))
                fprintf('*** No file for %s %s.  Continuing onto the next file.\n',site.codes{i},sptxt)
                %keyboard
                continue
            end

            for fni = 1:length(site.(site.codes{i}).([sptxt,'_',intxt,'_files']))
                fn = fullfile(site.(site.codes{i}).([sptxt,'_',intxt,'_files'])(fni).folder,site.(site.codes{i}).([sptxt,'_',intxt,'_files'])(fni).name);
                
                if isempty(fn); fprintf('No file %s.\nContinuing onto the next file.\n',fn); keyboard; end
                in_format = '%{yyyy-MM-dd HH:mm:ss}D%f%f%f%f%f%s%s%f%f%f%f%f%f%f%f%f%f%f%f%s';
                fid = fopen(fn);
                read_dat = textscan(fid,in_format,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{4}(:,5)]; % CO2
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{4}(:,7)]; % CO2 std
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{4}(:,8)]; % CO2 n
                site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_unc']); read_dat{4}(:,6)]; % CO2 uncertainty
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); read_dat{1}]; % time
                site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_lat']); read_dat{4}(:,1)];
                site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_lon']); read_dat{4}(:,2)];
                site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']); read_dat{4}(:,3)];
                site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']); read_dat{4}(:,4)];
                fprintf('File read: %s\n',site.(site.codes{i}).([sptxt,'_',intxt,'_files'])(fni).name)
            end
            
            fields = {'','_std','_n','_unc','_time','_lat','_lon','_elevation','_inlet_height'};
            
            % Removes the leading and trailing NaNs
            data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
            for j = 1:length(fields)
                site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]) = site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(data_range_ind);
            end
            clear data_range_ind
            
            % If there is no data (ie if there is no CH4 data but there is CO2 & CO data), remove the site/inlet/species.
            if isempty(site.(site.codes{i}).([sptxt,'_',intxt])) 
                fprintf('***No data found for %s: %s_%s. Removing that species-inlet from the site.\n',site.codes{i},sptxt,intxt)
                for j = 1:length(fields)
                    site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,fields{j}]);
                end
                continue
            end
            
            % Set fill values:
            for j = 1:length(fields)
                if ~strcmp(fields{j},'_time') % don't fill the time
                    site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]))) = -9999.0;
                end
            end
            
            site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).code,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
    end
end

%% Custom QAQC based on discussion with ??? on MMMM YYYY
% 
% fprintf('*** Custom QAQC implemented in Aug 2020***\n')
% 
% % CO2 QC
% i = find(strcmp(site.codes,'LJO')); %site.(site.codes{i})
% inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'13m')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
% sp = find(strcmp(site.(site.codes{i}).species,'co2')); sptxt = site.(site.codes{i}).species{sp};
% mask = false(size(site.(site.codes{i}).([sptxt,'_',intxt])));
% fprintf('Remove short spike of low CO2 at LJO 13m on Oct 30, 2019\n')
% t1 = datetime(2019,10,30,15,00,00); t2 = datetime(2019,11,04,19,00,00);
% mask(and(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])>t1,site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<t2)) = true;
% site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -9999.0;
% 
% % CO QC:
% i = find(strcmp(site.codes,'CIT')); %site.(site.codes{i})
% inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'48m')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
% sp = find(strcmp(site.(site.codes{i}).species,'co')); sptxt = site.(site.codes{i}).species{sp};
% mask = false(size(site.(site.codes{i}).([sptxt,'_',intxt])));
% fprintf('Remove short spike of CO at CIT 48m on Jun 13, 2020\n')
% t1 = datetime(2020,06,13,01,00,00); t2 = datetime(2020,06,13,04,00,00);
% mask(and(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])>t1,site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<t2)) = true;
% fprintf('Remove short spike of CO at CIT on Jun 17, 2020\n')
% t1 = datetime(2020,06,17,02,00,00); t2 = datetime(2020,06,17,04,00,00);
% mask(and(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])>t1,site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<t2)) = true;
% site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -9999.0;

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

