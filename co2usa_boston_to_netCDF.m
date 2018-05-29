clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('Outstanding questions as of 5/27/2018:\n')
fprintf('-Site CA: should I use the EN 1 point calibration or the Harvard 2 point calibration?\n')


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
date_issued = datetime(2018,07,01);
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

site_names = dir(fullfile(readFolder,city,'*.obs*.txt')); % Monthly data files

% Determine the site codes from the available data files:
count = 1;
for i = 1:length(site_names)
    tmp_site_code = site_names(i).name(1:regexp(site_names(i).name,'[.]','once')-1);
    if ~any(strcmp(tmp_site_code,site.codes))
        site.codes{1,count} = tmp_site_code;
        count = count+1;
    end
end
clear count tmp_site_code

site.date_issued = datetime(1970,1,1); % This date will be updated with the most recent date in the files below.
site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd'); % This date will be updated with the most recent date in the files below.

for i = 1:length(site.codes)
fprintf('Reading header info for site %s.\n',site.codes{1,i})

site.(site.codes{i}).code = upper(site.codes{i});
site.(site.codes{i}).name = site.(site.codes{i}).code;
%site.(site.codes{i}).header_lines = header_lines+2; % I think I will have to determine this for every file.
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.

site.(site.codes{i}).files = dir(fullfile(readFolder,city,[site.codes{1,i},'*.txt']));

% Open the first file & extract site info from the header
fid = fopen(fullfile(site.(site.codes{i}).files(1).folder,site.(site.codes{i}).files(1).name));
%header_lines = 0;
readNextLine = true;
while readNextLine==true
    tline = fgets(fid);
    %header_lines = header_lines+1;
    
    if ~isempty(regexp(tline,'date_created :','once'))
        site.(site.codes{i}).date_issued = datetime(strip(tline(regexp(tline,':')+1:end)),'InputFormat','yyyy-MM-dd');
        site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
        site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
    end
    if ~isempty(regexp(tline,'site_name :','once'))
        site.(site.codes{i}).long_name = strip(tline(regexp(tline,':')+1:end));
    end
    if ~isempty(regexp(tline,'site_latitude :','once'))
        site.(site.codes{i}).in_lat = str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'site_longitude :','once'))
        site.(site.codes{i}).in_lon = -str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'site_elevation :','once'))
        site.(site.codes{i}).in_elevation = str2double(tline(regexp(tline,'[0-9.]')));
    end
    if ~isempty(regexp(tline,'site_inlet_height :','once'))
        comma_ind = regexp(tline,',');
        formatSpec = [];
        for j = 1:length(comma_ind)
            formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        end
        formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        
        intxt = textscan(strip(tline(regexp(tline,':')+1:end)),formatSpec,'delimiter',',','CollectOutput',1);
        intxt = intxt{1};
        for j = 1:length(intxt)
            intxt{1,j} = str2double(strip(intxt{1,j}));
        end
        site.(site.codes{i}).inlet_height = intxt;
        for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
        clear intxt formatSpec comma_ind
    end
    if ~isempty(regexp(tline,'dataset_parameters :','once'))
        comma_ind = regexp(tline,',');
        formatSpec = [];
        for j = 1:length(comma_ind)
            formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        end
        formatSpec = [formatSpec,'%s']; %#ok<AGROW>
        
        sp = textscan(strip(tline(regexp(tline,':')+1:end)),formatSpec,'delimiter',',','CollectOutput',1);
        sp = sp{1};
        for j = 1:length(sp)
            sp{1,j} = lower(strip(sp{1,j}));
        end
        site.(site.codes{i}).species = sp;
        clear sp formatSpec comma_ind
        
        for j = 1:length(site.(site.codes{i}).species)
            if strcmp(site.(site.codes{i}).species{1,j},'ch4')
                site.(site.codes{i}).species_long_name{1,j} = 'methane';
                site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
                site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CH4 X2004A';
            elseif strcmp(site.(site.codes{i}).species{1,j},'co2')
                site.(site.codes{i}).species_long_name{1,j} = 'carbon_dioxide';
                site.(site.codes{i}).species_units_long_name{1,j} = 'ppm';
                site.(site.codes{i}).species_units{1,j} = 'micromol mol-1';
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO2 X2007';
            elseif strcmp(site.(site.codes{i}).species{1,j},'co')
                site.(site.codes{i}).species_long_name{1,j} = 'carbon_monoxide';
                site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
                site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO X2014A';
            end
        end
    end
    
    if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
end
fclose(fid);
end

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-dd');

site.reference = ['McKain K, Down A, Racit S M, Budney J, Hutyra L R, Floerchinger C, Herndon S C, Nehrkorn T, Zahniser M S, Jackson R B, Phillips N, and Wofsy S. (2015) Methane emissions from natural gas infrastructure and use in the urban region of Boston, Massachusetts. Proc Natl Acad Sci U.S.A. 112(7):1941-6.; ',...
 'Sargent M, Barrera Y, Nehrkorn T, Lucy R. Hutyra L R, Gately C, Jones T, Kathryn McKain K, Sweeney C, Hegarty J, Hardiman B, and Wofsy S (2018) Anthropogenic and biogenic CO2 fluxes in the Boston urban region, Proc Natl Acad Sci USA, submitted.'];

% Loading the data


% Notes:
% site CA has two inlet heights, 100m and 50m.  As far as I can tell that
% is the only site with two inlet heights.

% Most sites have 4 cols per species, but MVY only has 2.


for i = 1:length(site.codes)
    for fn = 1:length(site.(site.codes{i}).files)
        % All of Boston's sites have a different number of columns for measured species!
        % Make formatSpec based on the number of species.
        
        fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
        site.(site.codes{i}).files_header_lines = nan(1,length(site.(site.codes{i}).files));
        clear col
        col.used_variance = false; % Some files use variance, some used std. Need this flag to make sure all data files show the std in the final data format.
        col.n_present = false; % Site MVY doesn't have n, so this flag addresses that site.
        formatSpec = '%f%f%f%f'; % Yr,Mn,Dy,Hr
        tmp_column = 5;
        header_lines = 0;
        readNextLine = true;
        while readNextLine==true
            tline = fgets(fid);
            header_lines = header_lines+1;
            
            sp_search = regexp(tline,upper(site.(site.codes{i}).species),'once'); % Searches for any match with any of the species.
            if any(cell2mat(sp_search)) % If any matches are detected, go through and find the data column for that species.
                for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
                    intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
                    innum = num2str(site.(site.codes{i}).inlet_height{inlet});
                    for sp = 1:length(site.(site.codes{i}).species)
                        sptxt = site.(site.codes{i}).species{sp};
                        if and(or(~isempty(regexp(tline,['# ',upper(sptxt),'.mn:'],'once')),~isempty(regexp(tline,['# ',upper(sptxt),'_',innum,'.mn:'],'once'))),...
                                isempty(regexp(tline,'_FillValue','once')))
                            col.(['species_',intxt]){1,sp} = tmp_column;
                            formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                            tmp_column = tmp_column+1;
                        end
                        if and(or(~isempty(regexp(tline,['# ',upper(sptxt),'.HvdCal.mn:'],'once')),~isempty(regexp(tline,['# ',upper(sptxt),'_',innum,'.HvdCal.mn:'],'once'))),...
                                isempty(regexp(tline,'_FillValue','once'))) 
                            % This only exists for the CO2 100m CA site!!!!  I'm currently ignoring it, but I need to count the column it for an accurate column number
                            %col.(['species_',intxt]){1,sp} = tmp_column;
                            formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                            tmp_column = tmp_column+1;
                        end
                        if and(or(~isempty(regexp(tline,['# ',upper(sptxt),'.md:'],'once')),~isempty(regexp(tline,['# ',upper(sptxt),'_',innum,'.md:'],'once'))),...
                                isempty(regexp(tline,'_FillValue','once')))
                            col.(['median_',intxt]){1,sp} = tmp_column;
                            formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                            tmp_column = tmp_column+1;
                        end
                        if and(or(~isempty(regexp(tline,['# ',upper(sptxt),'.vr:'],'once')),~isempty(regexp(tline,['# ',upper(sptxt),'_',innum,'.vr:'],'once'))),...
                                isempty(regexp(tline,'_FillValue','once')))
                            col.(['std_',intxt]){1,sp} = tmp_column;
                            formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                            tmp_column = tmp_column+1;
                            col.used_variance = true; % set this flag to true so I can convert variance into std.
                        end
                        if and(or(~isempty(regexp(tline,['# ',upper(sptxt),'.sd:'],'once')),~isempty(regexp(tline,['# ',upper(sptxt),'_',innum,'.sd:'],'once'))),...
                                isempty(regexp(tline,'_FillValue','once')))
                            col.(['std_',intxt]){1,sp} = tmp_column;
                            formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                            tmp_column = tmp_column+1;
                        end
                        if and(or(~isempty(regexp(tline,['# ',upper(sptxt),'.n:'],'once')),~isempty(regexp(tline,['# ',upper(sptxt),'_',innum,'.n:'],'once')))...
                                ,isempty(regexp(tline,'_FillValue','once')))
                            col.(['n_',intxt]){1,sp} = tmp_column;
                            formatSpec = [formatSpec,'%f']; %#ok<AGROW>
                            tmp_column = tmp_column+1;
                            col.n_present = true; % set this flag to true so I know to read the n from the file.
                       end
                    end
                end
            end
            if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
        end
        frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        
        % At this point the variable "col" has all of the column information for all of the species/inlets at the site. 
        
        site.(site.codes{i}).files_header_lines(1,fn) = header_lines-1;
        
        % Read the data file after skipping the header lines.
        read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).files_header_lines(1,fn),'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NA');
        fclose(fid);
        
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            for sp = 1:length(site.(site.codes{i}).species)
                sptxt = site.(site.codes{i}).species{sp};
                if fn == 1
                    site.(site.codes{i}).([sptxt,'_',intxt]) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
                end
                
                % Species data:
                if strcmp(sptxt,'co')
                    site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,col.(['species_',intxt]){sp})*1000]; % species mixing ratio (converts CO from ppm to ppb)
                else
                    site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,col.(['species_',intxt]){sp})]; % species mixing ratio
                end
                
                % Number of measurements in the hour:
                if col.n_present
                    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,1}(:,col.(['n_',intxt]){sp})]; % species n
                else
                    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); nan(size(read_dat{1,1},1),1)]; % species n
                end
                
                % Standard deviation.  If the data was reported as a variance, take the square root to get the standard deviation
                if col.used_variance
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); (read_dat{1,1}(:,col.(['std_',intxt]){sp})).^(1/2)]; % species std
                else
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{1,1}(:,col.(['std_',intxt]){sp})]; % species std
                end
                
                % Time
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
                    datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1))]; % time
                %fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files(fn).name)
            end
        end
    end % End of the loop reading all of the data files for a site.
    %fprintf('%-3s files read from %s to %s\n',sptxt,site.(site.codes{i}).files(1).name,site.(site.codes{i}).files(fn).name)
    fprintf('%-3s files read from %s to %s\n',cell2mat(site.(site.codes{i}).species),site.(site.codes{i}).files(1).name,site.(site.codes{i}).files(fn).name)

    for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
        intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
        for sp = 1:length(site.(site.codes{i}).species)
            sptxt = site.(site.codes{i}).species{sp};
            
            % Removes the leading and trailing NaNs
            data_range_ind = find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'first'):find(~isnan(site.(site.codes{i}).([sptxt,'_',intxt])),1,'last');
            site.(site.codes{i}).([sptxt,'_',intxt]) = site.(site.codes{i}).([sptxt,'_',intxt])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(data_range_ind);
            site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(data_range_ind);
            clear data_range_ind
            
            % Lat, Lon, Elevation, and Inlet heights do not change, so they are all entered as a constant through the data set.
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = repmat(site.(site.codes{i}).in_lat,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = repmat(site.(site.codes{i}).in_lon,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = repmat(site.(site.codes{i}).in_elevation,length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = repmat(site.(site.codes{i}).inlet_height{inlet},length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
            % Set fill values:
            site.(site.codes{i}).([sptxt,'_',intxt])(isnan(site.(site.codes{i}).([sptxt,'_',intxt]))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_std'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_std']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_n'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_n']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lat']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_lon']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']))) = -1e34;
            site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(isnan(site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']))) = -1e34;
            
            site.groups = [site.groups; {[site.(site.codes{i}).code,'_',sptxt,'_',intxt]}];
            site.species = [site.species; {sptxt}];
        end
    end
    fprintf('---- %-0s complete ----\n\n',site.codes{i})
    
end

%%
% Load background data, or leave it blank if it doesn't exist.

i = length(site.codes)+1;

site.codes{1,i} = 'background';
site.groups = [site.groups; 'background'];

site.(site.codes{i}).name = 'background';
site.(site.codes{i}).long_name = 'background';
site.(site.codes{i}).code = '';
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/Indianapolis';
site.(site.codes{i}).inlet_height_long_name = {'background'};
site.(site.codes{i}).inlet_height = {0};
site.(site.codes{i}).species = {'co2'};
site.(site.codes{i}).species_long_name = {'carbon_dioxide'};
site.(site.codes{i}).species_units = {'micromol mol-1'};
site.(site.codes{i}).species_units_long_name = {'ppm'};
site.(site.codes{i}).instrument = {'modeled'};
site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007'};
site.(site.codes{i}).in_lat = site.(site.codes{i-1}).in_lat;
site.(site.codes{i}).in_lon = site.(site.codes{i-1}).in_lon;
site.(site.codes{i}).in_elevation = 0;
site.(site.codes{i}).date_issued = site.(site.codes{i-1}).date_issued;
site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-dd');
sp = 1; sptxt = site.(site.codes{i}).species{sp};
inlet = 1; intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
site.(site.codes{i}).([sptxt,'_',intxt]) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [datetime(2016,01,01);datetime(2016,01,02)];
site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_lat']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_lon']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']) = [-1e34;-1e34];
site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']) = [-1e34;-1e34];

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

eval('co2usa_create_netCDF')

%% Convert the netCDF data to text files.

fprintf('Now creating the text files from the netCDF files.\n')
eval('co2usa_netCDF2txt')


