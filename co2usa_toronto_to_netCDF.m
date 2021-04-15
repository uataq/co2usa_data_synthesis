% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('Questions as of 2020/08/04:\n')
fprintf('- City URL\n')
fprintf('- Reference paper\n')

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
date_issued = datetime(2020,10,01);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'toronto';
city_long_name = 'Toronto';
city_url = '';

provider(1).name = 'Felix Vogel';
provider(1).address1 = 'Environment and Climate Change Canada';
provider(1).address2 = '4905 Dufferin St.';
provider(1).address3 = 'Toronto, ON, Canada, M3H 5T4';
provider(1).country = 'Canada';
provider(1).city = city_long_name;
provider(1).affiliation = 'Environment and Climate Change Canada';
provider(1).email = 'felix.vogel@canada.ca';
provider(1).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.reference = '';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = date_issued_str;
site.date_created_str = date_created_str;

i = 1;
site.codes{1,i} = 'DOW';
site.(site.codes{i}).name = 'DOW';
site.(site.codes{i}).long_name = 'Downsview';
site.(site.codes{i}).code = 'DOW';
site.(site.codes{i}).country = 'Canada';
site.(site.codes{i}).time_zone = 'America/Toronto'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {20};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','LGR EP-30'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 43.7804;
site.(site.codes{i}).in_lon = -79.4681;
site.(site.codes{i}).in_elevation = 198;
site.(site.codes{i}).file = 'Downsview-GHG-Hourly-for-CO2-USA-database.CSV';
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'EGB';
site.(site.codes{i}).name = 'EGB';
site.(site.codes{i}).long_name = 'Egbert';
site.(site.codes{i}).code = 'EGB';
site.(site.codes{i}).country = 'Canada';
site.(site.codes{i}).time_zone = 'America/Toronto'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {25};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','LGR EP-30'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 44.2310;
site.(site.codes{i}).in_lon = -79.7838;
site.(site.codes{i}).in_elevation = 251;
site.(site.codes{i}).file = 'Egbert-GHG-Hourly-for-CO2-USA-database.CSV';
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'HNP';
site.(site.codes{i}).name = 'HNP';
site.(site.codes{i}).long_name = 'Hanlan''s Point';
site.(site.codes{i}).code = 'HNP';
site.(site.codes{i}).country = 'Canada';
site.(site.codes{i}).time_zone = 'America/Toronto'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {15};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','LGR EP-30'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 43.6122;
site.(site.codes{i}).in_lon = -79.3887;
site.(site.codes{i}).in_elevation = 87;
site.(site.codes{i}).file = 'Hanlans_Point-GHG-Hourly-for-CO2-USA-database.CSV';
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

i = i+1;
site.codes{1,i} = 'TKP';
site.(site.codes{i}).name = 'TKP';
site.(site.codes{i}).long_name = 'Turkey Point';
site.(site.codes{i}).code = 'TKP';
site.(site.codes{i}).country = 'Canada';
site.(site.codes{i}).time_zone = 'America/Toronto'; % use timezones to find out the available time zone designations.
site.(site.codes{i}).inlet_height = {35};
for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
site.(site.codes{i}).species = {'co2','ch4','co'};
site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301','LGR EP-30'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
site.(site.codes{i}).in_lat = 42.6354;
site.(site.codes{i}).in_lon = -80.5577;
site.(site.codes{i}).in_elevation = 231;
site.(site.codes{i}).file = 'Turkey_Point-GHG-Hourly-for-CO2-USA-database.CSV';
site.(site.codes{i}).date_issued = date_issued;
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');


%% Loading the data

version_folder = 'v20201001';

for i = 1:length(site.codes)
    fn = dir(fullfile(readFolder,city,version_folder,site.(site.codes{i}).file));
    
    fid = fopen(fullfile(fn.folder,fn.name));
    formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    header_lines = 1;
    read_dat = textscan(fid,formatSpec,'HeaderLines',header_lines,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
    fclose(fid);
    
    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            
            if strcmp(sptxt,'co2'); col.species = 8; col.std = 9; end
            if strcmp(sptxt,'ch4'); col.species = 6; col.std = 7; end
            if strcmp(sptxt,'co'); col.species = 10; col.std = 11; end
            
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = datetime(read_dat{1,1}(:,3),ones(size(read_dat{1,1}(:,3),1),1),read_dat{1,1}(:,4),read_dat{1,1}(:,5),zeros(size(read_dat{1,1}(:,3),1),1),zeros(size(read_dat{1,1}(:,3),1),1));
            site.(site.codes{i}).([sptxt,'_',intxt]) = read_dat{1,1}(:,col.species);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = read_dat{1,1}(:,col.std);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = ones(length(read_dat{1,1}),1)*-9999.0;
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = ones(length(read_dat{1,1}),1)*-9999.0;
            
            site.(site.codes{i}).([sptxt,'_',intxt])(site.(site.codes{i}).([sptxt,'_',intxt])==-999.99) = nan;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(site.(site.codes{i}).([sptxt,'_',intxt,'_std'])==-999.99) = nan;
            
            % Removes the leading and trailing NaNs
            data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
            site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
            clear data_range_ind
            
            % Lat, Lon, Elevation, and Inlet heights do not change, so they are all entered as a constant through the data set. 
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
        end
    end
    fprintf('---- %-6s complete ----\n\n',site.codes{i})
end


%% Optional plots to spot check the data.

%i = 4;
%site.(site.codes{i}).species
clear('ax')
for i = 1:length(site.codes)
    intxt = site.(site.codes{i}).inlet_height_long_name{1};
    figure(i); clf;
    for j = 1:length(site.(site.codes{i}).species)
        sptxt = site.(site.codes{i}).species{j}; pltxt = [sptxt,'_',intxt];
        mask = true(size(site.(site.codes{i}).(pltxt))); mask(site.(site.codes{i}).(pltxt)==-9999) = false;
        if sum(mask)==0; mask(mask==false) = true; end % if they're all false, make them true so the plotting works. Will show up as -9999 line.
        ax(i,j) = subplot(length(site.(site.codes{i}).species),1,j);
        plot(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(mask),site.(site.codes{i}).(pltxt)(mask))
        grid on; ylabel(replace(pltxt,'_',' ')); title(site.codes{i})
    end
    linkaxes(ax(i,:),'x')
end

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

