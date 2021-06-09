clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    'indianapolis'
    'los_angeles'
    'portland'
    'salt_lake_city'
    'san_francisco_beacon'
    'san_francisco_baaqmd'
    'toronto'
    'washington_dc_baltimore'
    };

species_to_load = {'co2'
    %'ch4'
    %'co'
    };

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new','netCDF_formatted_files');

save_overview_image = 'n';
co2_usa = co2usa_load_netCDF(cities,species_to_load,readFolder,save_overview_image);

species = 'co2';

%% Author List

authors = cell(1,4);
count = 1;
for ii = 1:size(cities,1)
    city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
    site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));
    providers_total_listed = str2double(co2_usa.(city).(site_codes{1}).global_attributes.provider_total_listed);
    for j = 1:providers_total_listed
        authors{count,2} = co2_usa.(city).(site_codes{1}).global_attributes.(['provider_',num2str(j),'_name']);
        name_parts = strsplit(authors{count,2});
        authors{count,1} = name_parts{end};
        authors{count,3} = co2_usa.(city).(site_codes{1}).global_attributes.(['provider_',num2str(j),'_affiliation']);
        authors{count,4} = co2_usa.(city).(site_codes{1}).global_attributes.(['provider_',num2str(j),'_email']);
        count = count+1;
    end
end

% List of all CO2-USA authors/affiliation/email alphabetized by last name
authors = sortrows(authors,1); % Sort alphabetically
authors = [{'Mitchell','Logan E. Mitchell','University of Utah','logan.mitchell@utah.edu'};...
    {'Lin','John C. Lin','University of Utah','John.Lin@utah.edu'};...
    {'Hutyra','Lucy R. Hutyra','Boston University','lrhutyra@bu.edu'}; authors]; % Add 3 primary authors
[~,ia,~] = unique(authors(:,1)); % find duplicates
authors = authors(sortrows(ia),:); % remove duplicate while preserving author order (3 primary authors, alphabetically after that)

for ii = 1:length(authors)
    fprintf('%-25s %-70s %s\n',authors{ii,2},authors{ii,3},authors{ii,4})
end

%% Overall dataset start and stop date

city_dataset_start_date = repmat(datetime(2050,1,1),length(cities),1); % Set dummy values that will be replaced.
city_dataset_stop_date = repmat(datetime(1970,1,1),length(cities),1); % Set dummy values that will be replaced.

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s:\n',city)
    site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));

    for usc_i = 1:length(site_codes) % Loops through each site
        site = site_codes{usc_i}; if strcmp(site_codes{usc_i},[species,'_background']); continue; end % Skip the background
        city_dataset_start_date(ii,1) = min([city_dataset_start_date(ii,1),...
            datetime(co2_usa.(city).(site).global_attributes.('dataset_start_date'),'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z')]);
        city_dataset_stop_date(ii,1) = max([city_dataset_stop_date(ii,1),...
            datetime(co2_usa.(city).(site).global_attributes.('dataset_stop_date'),'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z')]);
    end
end
co2usa_dataset_start_date = min(city_dataset_start_date);
co2usa_dataset_stop_date = max(city_dataset_stop_date);

fprintf('Done.\n')
fprintf('Overall dataset start date: %s\n',datestr(co2usa_dataset_start_date,'yyyy-mm-dd'))
fprintf('Overall dataset stop date: %s\n',datestr(co2usa_dataset_stop_date,'yyyy-mm-dd'))

%% Bounding Box

co2usa_dataset_n_limit = nan;
co2usa_dataset_s_limit = nan;
co2usa_dataset_e_limit = nan;
co2usa_dataset_w_limit = nan;

for ii = 1:size(cities,1)
    city = cities{ii,1};
    site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));

    city_lats = nan(size(site_codes,1),1);
    city_lons = nan(size(site_codes,1),1);
    
    for usc_i = 1:length(site_codes) % Loops through each site
        if strcmp(site_codes{usc_i},[species,'_background']); continue; end % Skip the background
        site = site_codes{usc_i}; 
        city_lats(usc_i,1) = str2double(co2_usa.(city).(site).global_attributes.('site_latitude'));
        city_lons(usc_i,1) = str2double(co2_usa.(city).(site).global_attributes.('site_longitude'));
        fprintf('%s-%s: %0.4f %0.4f\n',city,site,city_lats(usc_i,1),city_lons(usc_i,1))
    end
    fprintf('%s overall average: %0.4f %0.4f\n',city,nanmean(city_lats),nanmean(city_lons))
    fprintf('Bounding box: N=%0.4f, S=%0.4f, W=%0.4f, E=%0.4f.\n',nanmax(city_lats),nanmin(city_lats),nanmin(city_lons),nanmax(city_lons))
    co2usa_dataset_n_limit = max([co2usa_dataset_n_limit,nanmax(city_lats)]);
    co2usa_dataset_s_limit = min([co2usa_dataset_s_limit,nanmin(city_lats)]);
    co2usa_dataset_w_limit = min([co2usa_dataset_w_limit,nanmin(city_lons)]);
    co2usa_dataset_e_limit = max([co2usa_dataset_e_limit,nanmax(city_lons)]);
end

fprintf('Done.\n')
fprintf('Overall CO2-USA Bounding box: N=%0.4f, S=%0.4f, W=%0.4f, E=%0.4f.\n',co2usa_dataset_n_limit,co2usa_dataset_s_limit,co2usa_dataset_w_limit,co2usa_dataset_e_limit)

%% File number & size

co2usa_nc_file_size = 0;
co2usa_text_file_size = 0;
co2usa_total_files = 0;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');

for ii = 1:size(cities,1)
    city = cities{ii,1};
    fn_nc = dir(fullfile(readFolder,'netCDF_formatted_files',[city,'*.nc']));
    co2usa_nc_file_size = co2usa_nc_file_size+sum(cell2mat({fn_nc.bytes}));
    
    fn_text = dir(fullfile(readFolder,'txt_formatted_files',[city,'*.txt']));
    co2usa_text_file_size = co2usa_text_file_size+sum(cell2mat({fn_text.bytes}));
    
    co2usa_total_files = co2usa_total_files+length(fn_nc)+length(fn_text);
end
fprintf('Total number of files in the dataset is %0.0f.\n',co2usa_total_files)
fprintf('Total dataset file size is %0.0f MB.\n',(co2usa_nc_file_size+co2usa_text_file_size)/1000000)



