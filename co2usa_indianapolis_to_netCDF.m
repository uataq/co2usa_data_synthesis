% % clear all
% % close all
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

%% Download new data files:
download_new_data = 'n';
if strcmp(download_new_data,'y')
    
    version_folder = 'v20200928';
    download_location = fullfile(readFolder,city,version_folder);
    if ~isfolder(download_location); mkdir(download_location); end
    
    url = 'http://rflux.psu.edu/nmiles/public/NOAA_flask_comparison/';
    full_page = webread(url);
    hyperlinks = regexpi(full_page,'<a href="(site|PSU_INFLUX).*?.dat">','match'); % search for <a href="site or <a href="PSU_INFLUX that end in .dat.
    hyperlinks = replace(hyperlinks,{'<a href="','">'},'');
    for i = 1:length(hyperlinks)
        fprintf('Downloading %s...\n',hyperlinks{i})
        outfilename = websave(fullfile(download_location,hyperlinks{i}),[url,hyperlinks{i}]);
    end
    fprintf('Done downloading INFLUX data.\n')
    clear('download_location','hyperlinks','full_page','url')
end

%% Site meta data

site_full_names = {
    'Mooresville'; % 01
    'E. 21st St.'; % 02
    'Downtown'; % 03
    'Greenwood'; % 04
    'W. 79th St.'; % 05
    'Lambert'; % 06
    'Wayne Twp Comm'; % 07
    'Noblesville'; % 08
    'Greenfield'; % 09
    'Greenfield Park'; % 10
    'Butler Univ.'; % 11
    'Shortridge Rd.'; % 12
    'Pleasant View'; % 13
    'Crawfordsville'}; % 14

clear site % start fresh

version_folder = 'v20200928';

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"

% Indianapolis has a simple numeric structure for their site names:
for i = 1:14
    site_names(i,:) = ['site',num2str(i,'%02.0f')]; %#ok<SAGROW>
end

site.date_issued = date_issued; % This date will be updated with the most recent date in the files below.
site.date_issued_str = date_issued_str; % This date will be updated with the most recent date in the files below.
site.date_created_str = date_created_str;

for i = 1:length(site_names)

site.codes{1,i} = upper(site_names(i,:));
fprintf('Reading header info for site %s.\n',site.codes{1,i})

site.(site.codes{i}).name = site_names(i,:);
site.(site.codes{i}).code = upper(site_names(i,:));

site.(site.codes{i}).files = dir(fullfile(readFolder,city,version_folder,['*',site.codes{1,i},'*.dat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: there are some duplicate file names in the data folder.
% Instructions from Vanessa Monteiro on 6/24/2020 about which files to use:
% use the files "PSU_xxx" until 2018, and for 2019 and 2020 use the files "sitexxx". 
files_to_skip = regexpi({site.(site.codes{i}).files.name}','site.*(2015|2016|2017|2018)');

% Update 2021-03-30: Natasha Miles sent an updated Site 14 2017 file w/ the site* format, so that site needs a custom file name test.
if i==14; files_to_skip = regexpi({site.(site.codes{i}).files.name}','PSU.*(2017)'); end

files_to_include = true(size(files_to_skip));
for j = 1:length(files_to_skip)
    if files_to_skip{j}==1
        files_to_include(j) = false;
    end
end

site.(site.codes{i}).files = site.(site.codes{i}).files(files_to_include);
clear('files_to_skip','files_to_include')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files_PSU_cell = regexp({site.(site.codes{i}).files.name}','PSU_INFLUX');
count_PSU = 1; count_site = 1;
for j = 1:length(files_PSU_cell)
    if ~isempty(files_PSU_cell{j})
        site.(site.codes{i}).files_PSU(count_PSU) = site.(site.codes{i}).files(j);
        count_PSU = count_PSU+1;
    else
        site.(site.codes{i}).files_site(count_site) = site.(site.codes{i}).files(j);
        count_site = count_site+1;
    end
end
if ~isfield(site.(site.codes{i}),'files_site'); site.(site.codes{i}).files_site.name = ''; end

clear files_PSU_cell

% Find the number of inlet heights.
all_inlets = {};
for j = 1:length(site.(site.codes{i}).files_PSU)
    underscores_ind = regexp(site.(site.codes{i}).files(j).name,'_');
    %dat_ind = regexp(site.(site.codes{i}).files(j).name,'.dat');
    all_inlets{j,1} = site.(site.codes{i}).files(j).name(underscores_ind(end-1)+1:underscores_ind(end)-1);
end
clear dat_ind underscores_ind
site.(site.codes{i}).inlet_height_long_name = unique(all_inlets)';

for j = 1:length(site.(site.codes{i}).inlet_height_long_name)
    site.(site.codes{i}).inlet_height{1,j} = str2double(site.(site.codes{i}).inlet_height_long_name{1,j}(1:end-1));
end

% Open the first file & extract site info from the header
fid = fopen(fullfile(site.(site.codes{i}).files_PSU(1).folder,site.(site.codes{i}).files_PSU(1).name));
header_lines = 0;
readNextLine = true;
while readNextLine==true
    tline = fgets(fid);
    header_lines = header_lines+1;
    if ~isempty(regexp(tline,'DATA VERSION:','once'))
        site.(site.codes{i}).date_issued = datetime(strip(tline(regexp(tline,':')+1:end)),'InputFormat','yyyyMMdd');
        site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
        site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
    end
    if ~isempty(regexp(tline,'STATION NAME:','once'))
        site.(site.codes{i}).long_name = [strip(tline(regexp(tline,':')+1:end)),' - ',site_full_names{i,1}];
    end
    if ~isempty(regexp(tline,'LATITUDE:','once'))
        site.(site.codes{i}).in_lat = str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'LONGITUDE:','once'))
        site.(site.codes{i}).in_lon = -str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'ALTITUDE:','once'))
        site.(site.codes{i}).in_elevation = str2double(tline(regexp(tline,'[0-9.]')));
    end

    if ~isempty(regexp(tline,'PARAMETER:','once'))
        slash_ind = regexp(tline,'/');
        formatSpec = [];
        for j = 1:length(slash_ind)
            formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        end
        formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        
        sp = textscan(strip(tline(regexp(tline,':')+1:end)),formatSpec,'delimiter','/','CollectOutput',1);
        sp = sp{1};
        for j = 1:length(sp)
            sp{1,j} = lower(strip(sp{1,j}));
        end
        site.(site.codes{i}).species = sp;
        
        clear sp formatSpec slash_ind
    end

    if ~isempty(regexp(tline,'MEASUREMENT UNIT:','once'))
        formatSpec = [];
        for j = 1:length(site.(site.codes{i}).species)
            formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        end
        formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        units = textscan(strip(tline(regexp(tline,':')+1:end)),formatSpec,'delimiter',',','CollectOutput',1);
        units = units{1};
        flag = true(size(units));
        for j = 1:length(units) % just keep ppm or ppb
            units{1,j} = units{1,j}(regexp(units{1,j},'[ppmb]'));
            if isempty(units{1,j}); flag(1,j) = false; end
        end
        units = units(flag);
        
        site.(site.codes{i}).species_units_long_name = units;
        site.(site.codes{i}).species_units = cell(size(site.(site.codes{i}).species_units_long_name));
        for j = 1:length(site.(site.codes{i}).species_units_long_name)
            if strcmp(site.(site.codes{i}).species_units_long_name{1,j},'ppb')
                site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
            elseif strcmp(site.(site.codes{i}).species_units_long_name{1,j},'ppm')
                site.(site.codes{i}).species_units{1,j} = 'micromol mol-1';
            end
        end
        for j = 1:length(site.(site.codes{i}).species)
            if strcmp(site.(site.codes{i}).species{1,j},'co2')
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO2 X2007';
                site.(site.codes{i}).species_standard_name{1,j} = 'carbon_dioxide';
            elseif strcmp(site.(site.codes{i}).species{1,j},'ch4')
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CH4 X2004A';
                site.(site.codes{i}).species_standard_name{1,j} = 'methane';
            elseif strcmp(site.(site.codes{i}).species{1,j},'co')
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO X2014A';
                site.(site.codes{i}).species_standard_name{1,j} = 'carbon_monoxide';
            end
        end

        clear units flag formatSpec
    end
    if ~isempty(regexp(tline,'MEAUREMENT METHOD:','once'))
        for j = 1:length(site.(site.codes{i}).species_units)
            site.(site.codes{i}).instrument{1,j} = strip(tline(regexp(tline,':')+1:end));
        end
    end
    
    %if ~isempty(regexp(tline,'PLEASE DO NOT DISTRIBUTE THESE DATA','once')); readNextLine = false; end % This was the end of the first version of the data
    if ~isempty(regexp(tline,'UNCERTAINTY:','once')); readNextLine = false; end
end
fclose(fid);
site.(site.codes{i}).header_lines = header_lines+6; % This doesn't work anymore...will recalculate it for every file.
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Indianapolis'; % use timezones to find out the available time zone designations.
end

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');

site.reference = 'Richardson, Scott J., Natasha L. Miles, Kenneth J. Davis, Thomas Lauvaux, Douglas K. Martins, Jocelyn C. Turnbull, Kathryn McKain, Colm Sweeney, and Maria Obiminda L. Cambaliza. Tower Measurement Network of In-Situ CO2, CH4, and CO in Support of the Indianapolis FLUX (INFLUX) Experiment. Elem Sci Anth 5, no. 0 (October 19, 2017). https://doi.org/10.1525/elementa.140.';

%% Loading the data

for i = 1:length(site.codes)
    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        species_list_index = true(length(site.(site.codes{i}).species),1);
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            site.(site.codes{i}).([sptxt,'_',intxt]) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [];
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
            for fn = 1:length(site.(site.codes{i}).files)
                if any(strcmp(site.(site.codes{i}).files(fn).name,{site.(site.codes{i}).files_site.name})) % Look for files with the new file name format
                    % Read top 2 lines, look for inlet height, compare against site.(site.codes{i}).inlet_height{inlet}
                    fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                    tline = fgets(fid); tline = fgets(fid); % read 2 lines to skip the header line
                    fclose(fid);
                    tline_parts = strsplit(tline);
                    if site.(site.codes{i}).inlet_height{inlet}~=str2double(tline_parts{3})
                        continue
                    end
                elseif ~contains(site.(site.codes{i}).files(fn).name,intxt)
                    continue; % If the file isn't for the correct inlet height, go to the next file.
                end
                
                % All of Indy's sites have columns for CO2, CH4, CO, even if there is no data in those columns!
                % Make formatSpec based on the number of species.
                %                 formatSpec = '%s%s%f%f%f%f%f%f';
                %                 for j = 1:length(site.(site.codes{i}).species)
                %                     formatSpec = [formatSpec,'%f%f%f']; %#ok<AGROW>
                %                 end
                %                 formatSpec = [formatSpec,'%f%f']; %#ok<AGROW>
                formatSpec = '%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
                
                if any(strcmp(site.(site.codes{i}).files(fn).name,{site.(site.codes{i}).files_site.name}))
                    header_lines = 1;
                else
                    % header_lines = site.(site.codes{i}).header_lines; % This doesn't work...some files have different number of header lines. 
                    fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                    header_lines = -1;
                    readNextLine = true;
                    while readNextLine==true
                        tline = fgets(fid); % read a line
                        if regexpi(tline,site.codes{i},'once')==1; readNextLine = false; end % If the site name is the first entry, stop reading the header
                        header_lines = header_lines+1;
                    end
                    fclose(fid);
                end
                
                % Read the data file after skipping the header lines.
                fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
                read_dat = textscan(fid,formatSpec,'HeaderLines',header_lines,'CollectOutput',true,'TreatAsEmpty','NaN');
                fclose(fid);
                
                % All of Indy's sites have columns for CO2, CH4, CO, even if there is no data in those columns!
                %col.species = 7+(sp-1)*3;
                %col.std = 8+(sp-1)*3;
                if strcmp(sptxt,'co2'); col.species = 7; col.std = 8; col.unc = 9; end
                if strcmp(sptxt,'ch4'); col.species = 10; col.std = 11; col.unc = 12; end
                if strcmp(sptxt,'co'); col.species = 13; col.std = 14; col.unc = 15; end
                col.n = 16; % n is common to all of the species.
                
                % Col 17 is the QC flag.  Only use data that has col 17==1.
                site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.species)]; % species
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.std)]; % species std
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.n)]; % species n
                site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_unc']); read_dat{1,2}(read_dat{1,2}(:,17)==1,col.unc)]; % species uncertainty
                
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
                    datetime(read_dat{1,2}(read_dat{1,2}(:,17)==1,4),ones(length(read_dat{1,2}(read_dat{1,2}(:,17)==1,1)),1),read_dat{1,2}(read_dat{1,2}(:,17)==1,5),read_dat{1,2}(read_dat{1,2}(:,17)==1,6),zeros(length(read_dat{1,2}(read_dat{1,2}(:,17)==1,1)),1),zeros(length(read_dat{1,2}(read_dat{1,2}(:,17)==1,1)),1))]; % time
                clear col
                fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files(fn).name)
            end
            
            % Removes the leading and trailing NaNs
            data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
            site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = site.(site.codes{i}).([sptxt,'_',intxt,'_unc'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
            clear data_range_ind
            
            if isempty(site.(site.codes{i}).([sptxt,'_',intxt])) % If there is no data (ie if there is no CH4 data but there is CO2 & CO data), remove the site/inlet/species.
                fprintf('***No data found for %s: %s_%s. Removing that species-inlet from the site.\n',site.codes{i},sptxt,intxt)
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt]);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_std']);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_n']);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_time']);
                site.(site.codes{i}) = rmfield(site.(site.codes{i}),[sptxt,'_',intxt,'_unc']);
                species_list_index(sp) = false;
                continue
            end
            
            % Lat, Lon, Elevation, and Inlet heights do not change, so they are all entered as a constant through the data set.
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = repmat(site.(site.codes{i}).inlet_height{inlet},length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            fields = {'','_std','_n','_unc','_time','_lat','_lon','_elevation','_inlet_height'};
            % Set fill values:
            for j = 1:length(fields)
                if ~strcmp(fields{j},'_time') % don't fill the time
                    site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]))) = -9999.0;
                end
            end
            
            % Update 2021-03-30: Natasha Miles sent an updated Site 14 2017 file w/ the site* format.Since the files are out of order, I need to sort the data. 
            if i == 14
                [site.(site.codes{i}).([sptxt,'_',intxt,'_time']),idx] = sortrows(site.(site.codes{i}).([sptxt,'_',intxt,'_time']));
                for j = 1:length(fields)
                    if ~strcmp(fields{j},'_time') % Time already sorted
                        site.(site.codes{i}).([sptxt,'_',intxt,fields{j}]) = site.(site.codes{i}).([sptxt,'_',intxt,fields{j}])(idx);
                    end
                end
            end
            
            site.groups = [site.groups; {[sptxt,'_',site.(site.codes{i}).code,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
        site.(site.codes{i}).species = site.(site.codes{i}).species(species_list_index); % removes any that don't have data.
    end
    fprintf('---- %-6s complete ----\n\n',site.codes{i})
end

%% Custom QAQC based on discussion with Tasha Aug 2019

% %return
% fprintf('*** Custom QAQC requested by Tasha Miles in Aug 2019***\n')
% fprintf('Remove the 307.3 ppm CO2 point at Site 10 (40m inlet) on Aug 16, 2013\n')
% 
% i = find(strcmp(site.codes,'SITE10')); %site.(site.codes{i})
% inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'40M')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
% sp = find(strcmp(site.(site.codes{i}).species,'co2')); sptxt = site.(site.codes{i}).species{sp};
% tmp_dt = site.(site.codes{i}).([sptxt,'_',intxt,'_time']);
% tmp_dat = site.(site.codes{i}).([sptxt,'_',intxt]);
% tmp_dat(tmp_dat==-9999.0) = nan;
% % figure(99);clf; plot(tmp_dt,tmp_dat);
% mask = find(and(tmp_dat<310,and(tmp_dt>datetime(2013,08,16),tmp_dt<datetime(2013,08,17))));
% site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -9999.0;
% 
% fprintf('Remove the -1008 ppb CO points at Site 03 (54m inlet) on June 8, 2012.\n')
% i = find(strcmp(site.codes,'SITE03')); %site.(site.codes{i})
% inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'54M')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
% sp = find(strcmp(site.(site.codes{i}).species,'co')); sptxt = site.(site.codes{i}).species{sp};
% tmp_dt = site.(site.codes{i}).([sptxt,'_',intxt,'_time']);
% tmp_dat = site.(site.codes{i}).([sptxt,'_',intxt]);
% tmp_dat(tmp_dat==-9999.0) = nan;
% % figure(99);clf; plot(tmp_dt,tmp_dat);
% mask = find(and(tmp_dat<-1000,and(tmp_dt>datetime(2012,06,08),tmp_dt<datetime(2012,06,09))));
% site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -9999.0;
% 

%% Optional plots to spot check the data.

%i = 4;
%site.(site.codes{i}).species
clear('ax')
for i = 14%1:length(site.codes)
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


