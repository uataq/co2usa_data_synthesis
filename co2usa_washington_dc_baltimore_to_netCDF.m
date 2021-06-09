% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('No outstanding questions as of 2021-04-12:\n')

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
date_issued = datetime(2020,09,21);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

%% City & provider information:

city = 'washington_dc_baltimore';
city_long_name = 'Washington D.C. - Baltimore (Northeast Corridor)';
city_url = 'https://www.nist.gov/topics/northeast-corridor-urban-test-bed';

i = 1;
provider(i).name = 'Anna Karion';
provider(i).address1 = 'National Institute of Standards and Technology';
provider(i).address2 = '100 Bureau Drive';
provider(i).address3 = 'Gaithersburg, MD 20899';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'National Institute of Standards and Technology (NIST)';
provider(i).email = 'anna.karion@nist.gov';
provider(i).orcid = 'https://orcid.org/0000-0002-6304-3513';
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
provider(i).orcid = 'https://orcid.org/0000-0002-5139-9176';
provider(i).parameter = 'Provider has contributed measurements for: ';

i=3;
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

site.reference = 'Karion, Anna, William Callahan, Michael Stock, Steve Prinzivalli, Kristal R. Verhulst, Jooil Kim, Peter K. Salameh, Israel Lopez-Coto, and James Whetstone. “Greenhouse Gas Observations from the Northeast Corridor Tower Network.” Earth System Science Data 12, no. 1 (March 25, 2020): 699–717. https://doi.org/10.5194/essd-12-699-2020.';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.date_issued = date_issued;
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');
site.date_created_str = date_created_str;

version_folder = 'v20200921';

% Read the latest site info file and loop through it:
[NEC_sites_num,NEC_sites_txt] = xlsread(fullfile(readFolder,city,version_folder,'NEC_sites.csv'));
NEC_sites_txt = NEC_sites_txt(2:end,:); % Removes the header line
NEC_sites_num = NEC_sites_num(1:end,:); % This excludes the header already

i = 1;
for k = 1:size(NEC_sites_num,1)
    fns = dir(fullfile(readFolder,city,version_folder,[NEC_sites_txt{k,1},'*.csv']));
    if isempty(fns); continue; end % No data for that site
    clear('fns_part'); 
    for j = 1:length(fns); fns_part(j,:) = strsplit(fns(j).name,'-'); end
    site.codes{1,i} = NEC_sites_txt{k,1};
    site.(site.codes{i}).name = NEC_sites_txt{k,1};
    site.(site.codes{i}).long_name = NEC_sites_txt{k,4};
    site.(site.codes{i}).code = NEC_sites_txt{k,1};
    site.(site.codes{i}).inlet_height_long_name = unique(fns_part(:,4))';
    for j = 1:length(site.(site.codes{i}).inlet_height_long_name); site.(site.codes{i}).inlet_height{1,j} = ...
            str2double(site.(site.codes{i}).inlet_height_long_name{1,j}(regexp(site.(site.codes{i}).inlet_height_long_name{1,j},'[0-9]'))); end
    site.(site.codes{i}).in_lat = NEC_sites_num(k,5);
    site.(site.codes{i}).in_lon = NEC_sites_num(k,4);
    site.(site.codes{i}).in_elevation = NEC_sites_num(k,6);
    site.(site.codes{i}).species = unique(fns_part(:,3))';
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
    site.(site.codes{i}).country = 'United States';
    site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
    site.(site.codes{i}).date_issued = date_issued;
    site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
    site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
    i = i+1;
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
            site.(site.codes{i}).([sptxt,'_',intxt,'_files']) = dir(fullfile(readFolder,city,version_folder,[site.codes{i},'*',sptxt,'-',intxt,'*.csv']));
            for fni = 1:length(site.(site.codes{i}).([sptxt,'_',intxt,'_files']))
                fn = fullfile(site.(site.codes{i}).([sptxt,'_',intxt,'_files'])(fni).folder,site.(site.codes{i}).([sptxt,'_',intxt,'_files'])(fni).name);
                if isempty(fn); fprintf('No file %s.\nContinuing onto the next file.\n',fn); keyboard; end
                in_format = '%s%f%f%f%f%f%f%f%f%f%f%f%s';
                fid = fopen(fn);
                read_dat = textscan(fid,in_format,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,2}(:,6)]; % CO2
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{1,2}(:,7)]; % CO2 std
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,2}(:,8)]; % CO2 n
                site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_unc']); read_dat{1,2}(:,11)]; % CO2 uncertainty
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); datetime(read_dat{1,1},'InputFormat','yyyy-MM-dd HH:mm:ss')]; % time
                fprintf('File read: %s\n',site.(site.codes{i}).([sptxt,'_',intxt,'_files'])(fni).name)
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
end


%% Optional plots to spot check the data.

%i = 4;
%site.(site.codes{i}).species
% clear('ax')
% for i = 1:length(site.codes)
%     intxt = site.(site.codes{i}).inlet_height_long_name{1};
%     figure(i); clf;
%     for j = 1:length(site.(site.codes{i}).species)
%         sptxt = site.(site.codes{i}).species{j}; pltxt = [sptxt,'_',intxt];
%         mask = true(size(site.(site.codes{i}).(pltxt))); mask(site.(site.codes{i}).(pltxt)==-9999) = false;
%         if sum(mask)==0; mask(mask==false) = true; end % if they're all false, make them true so the plotting works. Will show up as -9999 line.
%         ax(i,j) = subplot(length(site.(site.codes{i}).species),1,j);
%         plot(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(mask),site.(site.codes{i}).(pltxt)(mask))
%         grid on; ylabel(replace(pltxt,'_',' ')); title(site.codes{i})
%     end
%     linkaxes(ax(i,:),'x')
% end

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


