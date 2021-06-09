% clear all
% close all
set(0,'DefaultFigureWindowStyle','docked')

%% Outstanding questions:

fprintf('No Outstanding questions.\n')


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
date_issued = datetime(2020,09,28);
date_issued_str = datestr(date_issued,'yyyy-mm-ddThh:MM:ssZ');

% Working folders
if ~exist('currentFolder','var'); currentFolder = pwd; end
if ~exist('readFolder','var'); readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input'); end
if ~exist('writeFolder','var');  writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output'); end

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
provider(i).affiliation = 'Harvard University';
provider(i).email = 'mracine@fas.harvard.edu';
provider(i).orcid = 'https://orcid.org/0000-0001-9602-3108';
provider(i).parameter = 'Provider has contributed measurements for: ';

i = 2;
provider(i).name = 'Steven C. Wofsy';
provider(i).address1 = 'Harvard University School of Engineering and Applied Sciences';
provider(i).address2 = '20 Oxford St';
provider(i).address3 = 'Cambridge, MA 02138';
provider(i).country = 'United States';
provider(i).city = city_long_name;
provider(i).affiliation = 'Harvard University';
provider(i).email = 'wofsy@g.harvard.edu';
provider(i).orcid = 'https://orcid.org/0000-0002-3133-2089';
provider(i).parameter = 'Provider has contributed measurements for: ';

%% Site meta data

clear site % start fresh

site.groups = {}; % List of the site "code_species_inletHt"
site.species = {}; % List of the "species"
site.codes = {}; % List of the site "codes"
site.date_issued = date_issued; % This date will be updated with the most recent date in the files below.
site.date_issued_str = date_issued_str; % This date will be updated with the most recent date in the files below.
site.date_created_str = date_created_str;

version_folder = 'v20200622';

updated_version_folder = 'v20200928';
updated_files = dir(fullfile(readFolder,city,updated_version_folder,'*.csv'));


% 
% 
% i = 1;
% site.codes{1,i} = 'bu';
% site.(site.codes{i}).name = 'BU';
% site.(site.codes{i}).long_name = 'Boston University, Boston, MA';
% site.(site.codes{i}).code = 'BU';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {29};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4'};
% site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
% site.(site.codes{i}).in_lat = 42.3500;
% site.(site.codes{i}).in_lon = -71.1040;
% site.(site.codes{i}).in_elevation = 4;
% site.(site.codes{i}).date_issued = date_issued;
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
% 
% i = i+1;
% site.codes{1,i} = 'ca';
% site.(site.codes{i}).name = 'CA';
% site.(site.codes{i}).long_name = 'Canaan, NH';
% site.(site.codes{i}).code = 'CA';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {100};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4'};
% site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2301','Picarro G2301'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A'};
% site.(site.codes{i}).in_lat = 43.7089;
% site.(site.codes{i}).in_lon = -72.1541;
% site.(site.codes{i}).in_elevation = 559.0;
% site.(site.codes{i}).date_issued = date_issued;
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
% 
% i = i+1;
% site.codes{1,i} = 'cop';
% site.(site.codes{i}).name = 'COP';
% site.(site.codes{i}).long_name = 'Copley Square, Boston, MA';
% site.(site.codes{i}).code = 'COP';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {215};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4','co'};
% site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
% site.(site.codes{i}).in_lat = 42.3470;
% site.(site.codes{i}).in_lon = -71.0840;
% site.(site.codes{i}).in_elevation = 6;
% site.(site.codes{i}).date_issued = date_issued;
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
% 
% i = i+1;
% site.codes{1,i} = 'hf';
% site.(site.codes{i}).name = 'HF';
% site.(site.codes{i}).long_name = 'Harvard Forest, Petersham, MA';
% site.(site.codes{i}).code = 'HF';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {29};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4','co'};
% site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
% site.(site.codes{i}).in_lat = 42.5380;
% site.(site.codes{i}).in_lon = -72.1710;
% site.(site.codes{i}).in_elevation = 340;
% site.(site.codes{i}).date_issued = date_issued;
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
% 
% 
% i = i+1;
% site.codes{1,i} = 'ma';
% site.(site.codes{i}).name = 'MA';
% site.(site.codes{i}).long_name = 'Mashpee, MA';
% site.(site.codes{i}).code = 'MA';
% site.(site.codes{i}).country = 'United States';
% site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.
% site.(site.codes{i}).inlet_height = {46};
% for j = 1:length(site.(site.codes{i}).inlet_height); site.(site.codes{i}).inlet_height_long_name{1,j} = [num2str(site.(site.codes{i}).inlet_height{1,j}),'m']; end
% site.(site.codes{i}).species = {'co2','ch4','co'};
% site.(site.codes{i}).species_standard_name = {'carbon_dioxide','methane','carbon_monoxide'};
% site.(site.codes{i}).species_units = {'micromol mol-1','nanomol mol-1','nanomol mol-1'};
% site.(site.codes{i}).species_units_long_name = {'ppm','ppb','ppb'};
% site.(site.codes{i}).instrument = {'Picarro G2401','Picarro G2401','Picarro G2401'};
% site.(site.codes{i}).calibration_scale = {'WMO CO2 X2007','WMO CH4 X2004A','WMO CO X2014A'};
% site.(site.codes{i}).in_lat = 41.6567;
% site.(site.codes{i}).in_lon = -70.4975;
% site.(site.codes{i}).in_elevation = 32;
% site.(site.codes{i}).date_issued = date_issued;
% site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
% site.date_issued = max([site.date_issued,site.(site.codes{i}).date_issued]);
% 
% 
% 
% site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');
% 
% site.reference = ['McKain K, Down A, Racit S M, Budney J, Hutyra L R, Floerchinger C, Herndon S C, Nehrkorn T, Zahniser M S, Jackson R B, Phillips N, and Wofsy S. (2015) Methane emissions from natural gas infrastructure and use in the urban region of Boston, Massachusetts. Proc Natl Acad Sci U.S.A. 112(7):1941-6.; ',...
%  'Sargent, Maryann, Yanina Barrera, Thomas Nehrkorn, Lucy R. Hutyra, Conor K. Gately, Taylor Jones, Kathryn McKain, et al. Anthropogenic and Biogenic CO2 Fluxes in the Boston Urban Region. Proceedings of the National Academy of Sciences 115, no. 29 (July 17, 2018): 7491–96. https://doi.org/10.1073/pnas.1803715115.'];
% 
% 






fn = dir(fullfile(readFolder,city,version_folder,'*.obs*.txt')); % Monthly data files

% Determine the site codes from the available data files:
count = 1;
for i = 1:length(fn)
    tmp_site_code = fn(i).name(1:regexp(fn(i).name,'[.]','once')-1);
    if ~any(strcmp(tmp_site_code,site.codes))
        site.codes{1,count} = tmp_site_code;
        count = count+1;
    end
end
clear count tmp_site_code fn


%%

for i = 1:length(site.codes)
fprintf('Reading header info for site %s.\n',site.codes{1,i})

site.(site.codes{i}).code = upper(site.codes{i});
site.(site.codes{i}).name = site.(site.codes{i}).code;
%site.(site.codes{i}).header_lines = header_lines+2; % I think I will have to determine this for every file.
site.(site.codes{i}).country = 'United States';
site.(site.codes{i}).time_zone = 'America/New_York'; % use timezones to find out the available time zone designations.

site.(site.codes{i}).files = dir(fullfile(readFolder,city,version_folder,[site.codes{1,i},'*.txt']));

% Open the first file & extract site info from the header
fid = fopen(fullfile(site.(site.codes{i}).files(1).folder,site.(site.codes{i}).files(1).name));
%header_lines = 0;
readNextLine = true;
tline = '';
while readNextLine==true
    last_line = tline;
    tline = fgets(fid);
    %header_lines = header_lines+1;
    
    if ~isempty(regexp(tline,'date_created :','once'))
        site.(site.codes{i}).date_issued = datetime(strip(tline(regexp(tline,':')+1:end)),'InputFormat','yyyy-MM-dd');
        site.(site.codes{i}).date_issued_str = datestr(site.(site.codes{i}).date_issued,'yyyy-mm-ddThh:MM:ssZ');
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
                site.(site.codes{i}).species_standard_name{1,j} = 'methane';
                site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
                site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CH4 X2004A';
            elseif strcmp(site.(site.codes{i}).species{1,j},'co2')
                site.(site.codes{i}).species_standard_name{1,j} = 'carbon_dioxide';
                site.(site.codes{i}).species_units_long_name{1,j} = 'ppm';
                site.(site.codes{i}).species_units{1,j} = 'micromol mol-1';
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO2 X2007';
            elseif strcmp(site.(site.codes{i}).species{1,j},'co')
                site.(site.codes{i}).species_standard_name{1,j} = 'carbon_monoxide';
                site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
                site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
                site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO X2014A';
            end
        end
    end
    
    if isempty(regexp(tline,'[#]','once'))
        last_line2 = strsplit(last_line(1:end-1),',');
        for k = 1:length(last_line2)
            if any(strcmpi({'co2','ch4','co'},strip(last_line2{k}(1:regexp(last_line2{k},'\.')-1))))
                if ~any(strcmpi(site.(site.codes{i}).species,strip(last_line2{k}(1:regexp(last_line2{k},'\.')-1)))) % if it isn't in the species list, add it
                    site.(site.codes{i}).species{end+1} = lower(strip(last_line2{k}(1:regexp(last_line2{k},'\.')-1)));
                    for j = length(site.(site.codes{i}).species)
                        if strcmp(site.(site.codes{i}).species{1,j},'ch4')
                            site.(site.codes{i}).species_standard_name{1,j} = 'methane';
                            site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
                            site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
                            site.(site.codes{i}).calibration_scale{1,j} = 'WMO CH4 X2004A';
                        elseif strcmp(site.(site.codes{i}).species{1,j},'co2')
                            site.(site.codes{i}).species_standard_name{1,j} = 'carbon_dioxide';
                            site.(site.codes{i}).species_units_long_name{1,j} = 'ppm';
                            site.(site.codes{i}).species_units{1,j} = 'micromol mol-1';
                            site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO2 X2007';
                        elseif strcmp(site.(site.codes{i}).species{1,j},'co')
                            site.(site.codes{i}).species_standard_name{1,j} = 'carbon_monoxide';
                            site.(site.codes{i}).species_units_long_name{1,j} = 'ppb';
                            site.(site.codes{i}).species_units{1,j} = 'nanomol mol-1';
                            site.(site.codes{i}).calibration_scale{1,j} = 'WMO CO X2014A';
                        end
                    end
                end
            end
        end
        clear last_line2
        readNextLine = false;
    end % stop reading the header.
end
fclose(fid);
end

site.date_issued_str = datestr(site.date_issued,'yyyy-mm-ddThh:MM:ssZ');

site.reference = ['McKain K, Down A, Racit S M, Budney J, Hutyra L R, Floerchinger C, Herndon S C, Nehrkorn T, Zahniser M S, Jackson R B, Phillips N, and Wofsy S. (2015) Methane emissions from natural gas infrastructure and use in the urban region of Boston, Massachusetts. Proc Natl Acad Sci U.S.A. 112(7):1941-6.; ',...
 'Sargent, Maryann, Yanina Barrera, Thomas Nehrkorn, Lucy R. Hutyra, Conor K. Gately, Taylor Jones, Kathryn McKain, et al. Anthropogenic and Biogenic CO2 Fluxes in the Boston Urban Region. Proceedings of the National Academy of Sciences 115, no. 29 (July 17, 2018): 7491–96. https://doi.org/10.1073/pnas.1803715115.'];


%%

% Loading the data

% Notes:
% I got updated data for sites BU, CA, COP, HF, & MA on 20200928 in a RData file. I exported them to CSV & below will update those sites. 


for i = 1:length(site.codes)
    site.(site.codes{i}).files_header_lines = nan(1,length(site.(site.codes{i}).files));
    for fn = 1:length(site.(site.codes{i}).files)
        % All of Boston's sites have a different number of columns for measured species!
        % Make formatSpec based on the number of species.
        
        fid = fopen(fullfile(site.(site.codes{i}).files(fn).folder,site.(site.codes{i}).files(fn).name));
        clear col
        col.used_variance = false; % Some files use variance, some std, some none. Need this flag to make sure all data files show the std in the final data format.
        col.used_std = false;
        col.n_present = false; % Site MVY doesn't have n, so this flag addresses that site.
        
        % Read the file until you get to the column header line, which is the last one before the data starts. 
        tline = '';
        readNextLine = true;
        header_lines = 0;
        while readNextLine==true
            last_line = tline(1:end-1);
            tline = fgets(fid);
            header_lines = header_lines+1;
            if isempty(regexp(tline,'[#]','once')); readNextLine = false; end % stop reading the header.
        end
        frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        site.(site.codes{i}).files_header_lines(1,fn) = header_lines-1;
        tlinept = strip(strsplit(last_line,',')); % This is the column header information
        formatSpec = repmat('%f',1,length(tlinept)); % Create this based on the columns
        % Read the data file after skipping the header lines.
        read_dat = textscan(fid,formatSpec,'HeaderLines',site.(site.codes{i}).files_header_lines(1,fn),'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NA');
        fclose(fid);
        
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            col.(['species_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            col.(['n_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            col.(['std_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            col.(['median_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            
            for sp = 1:length(site.(site.codes{i}).species)
                sptxt = site.(site.codes{i}).species{sp};

                if any(strcmpi([sptxt,'.mn'],tlinept))
                    col.(['species_',intxt]){1,sp} = find(strcmpi([sptxt,'.mn'],tlinept));
                end
                if any(strcmpi([sptxt,'.md'],tlinept))
                    col.(['median_',intxt]){1,sp} = find(strcmpi([sptxt,'.md'],tlinept));
                end
                if any(strcmpi([sptxt,'.vr'],tlinept))
                    col.(['std_',intxt]){1,sp} = find(strcmpi([sptxt,'.vr'],tlinept));
                    col.used_variance = true; % set this flag to true so I can convert variance into std.
                end
                if any(strcmpi([sptxt,'.sd'],tlinept))
                    col.(['std_',intxt]){1,sp} = find(strcmpi([sptxt,'.sd'],tlinept));
                    col.used_std = true;
                end
                if any(strcmpi([sptxt,'.n'],tlinept))
                    col.(['n_',intxt]){1,sp} = find(strcmpi([sptxt,'.n'],tlinept));
                    col.n_present = true; % set this flag to true so I know to read the n from the file.
                end
                
                if fn == 1
                    site.(site.codes{i}).([sptxt,'_',intxt]) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = [];
                    site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [];
                end
                
%                 % Check to make sure the length of these are correct
%                 if isfield(col,['n_',intxt])
%                 if length(col.(['species_',intxt]))>length(col.(['n_',intxt]))
%                     col.(['n_',intxt])(length(col.(['n_',intxt]))+1:length(col.(['species_',intxt]))) = {nan};
%                 end
%                 if length(col.(['species_',intxt]))>length(col.(['std_',intxt]))
%                     col.(['std_',intxt])(length(col.(['std_',intxt]))+1:length(col.(['species_',intxt]))) = {nan};
%                 end
%                 if length(col.(['species_',intxt]))>length(col.(['median_',intxt]))
%                     col.(['median_',intxt])(length(col.(['median_',intxt]))+1:length(col.(['species_',intxt]))) = {nan};
%                 end
%                 end
                
                % Species data:
                %if strcmp(sptxt,'co')
                %    site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,col.(['species_',intxt]){sp})*1000]; % species mixing ratio (converts CO from ppm to ppb)
                %else
                    site.(site.codes{i}).([sptxt,'_',intxt]) = [site.(site.codes{i}).([sptxt,'_',intxt]); read_dat{1,1}(:,col.(['species_',intxt]){sp})]; % species mixing ratio
                %end
                
                % Number of measurements in the hour:
                if and(col.n_present,~isnan(col.(['n_',intxt]){sp}))
                    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); read_dat{1,1}(:,col.(['n_',intxt]){sp})]; % species n
                else
                    site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_n']); nan(size(read_dat{1,1},1),1)]; % species n
                end
                
                % Standard deviation.  If the data was reported as a variance, take the square root to get the standard deviation
                if and(col.used_variance,~isnan(col.(['std_',intxt]){sp}))
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); (read_dat{1,1}(:,col.(['std_',intxt]){sp})).^(1/2)]; % species std
                elseif and(col.used_std,~isnan(col.(['std_',intxt]){sp}))
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']); read_dat{1,1}(:,col.(['std_',intxt]){sp})]; % species std
                else
                    site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_std']);  nan(size(read_dat{1,1},1),1)]; % species std
                end
                
                % Time
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = [site.(site.codes{i}).([sptxt,'_',intxt,'_time']); ...
                    datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1))]; % time
                %fprintf('%-3s read from file: %s\n',sptxt,site.(site.codes{i}).files(fn).name)
            end
        end
    end % End of the loop reading all of the data files for a site.
    
    %If a site has updated data, do that here:
    if any(strcmp([lower(site.codes{i}),'.csv'],{updated_files.name}))
        updated_fn = updated_files(strcmp([lower(site.codes{i}),'.csv'],{updated_files.name}));
        fid = fopen(fullfile(updated_fn.folder,updated_fn.name));
        clear col
        col.used_variance = false; % Some files use variance, some std, some none. Need this flag to make sure all data files show the std in the final data format.
        col.used_std = false;
        col.n_present = false; % Site MVY doesn't have n, so this flag addresses that site.
        
        tline = fgets(fid); frewind(fid) % start back at the beginning of the file to look for the next species, or continue on to the next step.
        tlinept = strip(strsplit(replace(tline,'"',''),',')); % This is the column header information
        formatSpec = repmat('%f',1,length(tlinept)); % Create this based on the columns
        read_dat = textscan(fid,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',true,'TreatAsEmpty','NA'); % Read the data file after skipping the header lines.
        fclose(fid);
        
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            col.(['species_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            col.(['n_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            col.(['std_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            col.(['median_',intxt])(1:length(site.(site.codes{i}).species)) = {nan};
            for sp = 1:length(site.(site.codes{i}).species)
                sptxt = site.(site.codes{i}).species{sp};
                
                if any(strcmpi([sptxt,'.mn'],tlinept))
                    col.(['species_',intxt]){1,sp} = find(strcmpi([sptxt,'.mn'],tlinept));
                end
                if any(strcmpi([sptxt,'.md'],tlinept))
                    col.(['median_',intxt]){1,sp} = find(strcmpi([sptxt,'.md'],tlinept));
                end
                if any(strcmpi([sptxt,'.vr'],tlinept))
                    col.(['std_',intxt]){1,sp} = find(strcmpi([sptxt,'.vr'],tlinept));
                    col.used_variance = true; % set this flag to true so I can convert variance into std.
                end
                if any(strcmpi([sptxt,'.sd'],tlinept))
                    col.(['std_',intxt]){1,sp} = find(strcmpi([sptxt,'.sd'],tlinept));
                    col.used_std = true;
                end
                if any(strcmpi([sptxt,'.n'],tlinept))
                    col.(['n_',intxt]){1,sp} = find(strcmpi([sptxt,'.n'],tlinept));
                    col.n_present = true; % set this flag to true so I know to read the n from the file.
                end
                
                boston_update.([sptxt,'_',intxt]) = read_dat{1,1}(:,col.(['species_',intxt]){sp}); % species mixing ratio
                
                % Number of measurements in the hour:
                if and(col.n_present,~isnan(col.(['n_',intxt]){sp}))
                    boston_update.([sptxt,'_',intxt,'_n']) = read_dat{1,1}(:,col.(['n_',intxt]){sp}); % species n
                else
                    boston_update.([sptxt,'_',intxt,'_n']) = nan(size(read_dat{1,1},1),1); % species n
                end
                
                % Standard deviation.  If the data was reported as a variance, take the square root to get the standard deviation
                if and(col.used_variance,~isnan(col.(['std_',intxt]){sp}))
                    boston_update.([sptxt,'_',intxt,'_std']) = (read_dat{1,1}(:,col.(['std_',intxt]){sp})).^(1/2); % species std
                elseif and(col.used_std,~isnan(col.(['std_',intxt]){sp}))
                    boston_update.([sptxt,'_',intxt,'_std']) = read_dat{1,1}(:,col.(['std_',intxt]){sp}); % species std
                else
                    boston_update.([sptxt,'_',intxt,'_std']) = nan(size(read_dat{1,1},1),1); % species std
                end
                
                % Time
                boston_update.([sptxt,'_',intxt,'_time']) = datetime(read_dat{1,1}(:,1),read_dat{1,1}(:,2),read_dat{1,1}(:,3),read_dat{1,1}(:,4),zeros(length(read_dat{1,1}),1),zeros(length(read_dat{1,1}),1)); % time
                
                % Option figure showing the original & updated data.
%                 figure(99); clf; hold on;
%                 plot(boston_update.([sptxt,'_',intxt,'_time']),boston_update.([sptxt,'_',intxt,'_std']))
%                 plot(site.(site.codes{i}).([sptxt,'_',intxt,'_time']),site.(site.codes{i}).([sptxt,'_',intxt,'_std']))
%                 legend(updated_version_folder,version_folder);hold off
                
                site.(site.codes{i}).([sptxt,'_',intxt]) = boston_update.([sptxt,'_',intxt]);
                site.(site.codes{i}).([sptxt,'_',intxt,'_std']) = boston_update.([sptxt,'_',intxt,'_std']);
                site.(site.codes{i}).([sptxt,'_',intxt,'_n']) = boston_update.([sptxt,'_',intxt,'_n']);
                site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = []; % no uncertainty data yet.
                site.(site.codes{i}).([sptxt,'_',intxt,'_time']) = boston_update.([sptxt,'_',intxt,'_time']);
            end
        end
    end
    
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
            
            % No uncertainty data yet.
            site.(site.codes{i}).([sptxt,'_',intxt,'_unc']) = nan(length(site.(site.codes{i}).([sptxt,'_',intxt])),1);
            
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
    fprintf('---- %-0s complete ----\n\n',site.codes{i})
end


%% Custom QAQC no longer needed

%fprintf('*** Custom QAQC discussed with___ on ___***\n')

%i = find(strcmp(site.codes,'HF')); %site.(site.codes{i})
%inlet = find(strcmp(site.(site.codes{i}).inlet_height_long_name,'29m')); intxt = site.(site.codes{i}).inlet_height_long_name{inlet};

% CO2 QC
%sp = find(strcmp(site.(site.codes{i}).species,'co2')); sptxt = site.(site.codes{i}).species{sp};
%mask = false(size(site.(site.codes{i}).([sptxt,'_',intxt])));
%fprintf('Remove short spike of ~___ppm CO2 at __ on ___\n')
%t1 = datetime(date); t2 = datetime(date);
%mask(and(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])>t1,site.(site.codes{i}).([sptxt,'_',intxt,'_time'])<t2)) = true;
%site.(site.codes{i}).([sptxt,'_',intxt])(mask) = -9999.0;

%% Optional plots to spot check the data.

%i = 4;
%site.(site.codes{i}).species
clear('ax')
for i = 1:length(site.codes)
    intxt = site.(site.codes{i}).inlet_height_long_name{1};
    figure(i); clf;
    for j = 1:length(site.(site.codes{i}).species)
        sptxt = site.(site.codes{i}).species{j}; 
        pltxt = [sptxt,'_',intxt];
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

%%

% Identify the netCDF files to create based on species.

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

