clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    'indianapolis'
    'los_angeles'
    %'northeast_corridor'
    'portland'
    'salt_lake_city'
    'san_francisco_beacon'
    'san_francisco_baaqmd'
    };

eval('co2usa_load_netCDF')

%% Contributor List

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s:\n',city)
    for provider_number = 1:str2double(co2_usa.(city).Attributes(strcmp({co2_usa.(city).Attributes.Name},'provider_total_listed')).Value)
        fprintf('%s,%s,%s\n',...
            co2_usa.(city).Attributes(strcmp({co2_usa.(city).Attributes.Name},['provider_',num2str(provider_number),'_name'])).Value,...
            co2_usa.(city).Attributes(strcmp({co2_usa.(city).Attributes.Name},['provider_',num2str(provider_number),'_affiliation'])).Value,...
            co2_usa.(city).Attributes(strcmp({co2_usa.(city).Attributes.Name},['provider_',num2str(provider_number),'_email'])).Value)
    end
end

%% Overall dataset start and stop date

city_dataset_start_date = repmat(datetime(2050,1,1),length(cities),1); % Set dummy values that will be replaced.
city_dataset_stop_date = repmat(datetime(1970,1,1),length(cities),1); % Set dummy values that will be replaced.

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s:\n',city)
    
    unique_site_codes = unique(co2_usa.(city).site_codes(~strcmp(co2_usa.(city).site_codes,'')));
    
    for usc_i = 1:length(unique_site_codes) % Loops through each site
        if strcmp(unique_site_codes{usc_i},'BACKGROUND'); continue; end % Skip the background
        site_i = regexpi(co2_usa.(city).site_names,unique_site_codes{usc_i}); % Array of all of the inlets at each site.
        for jj = 1:length(site_i); if isempty(site_i{jj}); site_i{jj} = 0; end; end % Replaces all the empty values with 0.
        site_i = logical(cell2mat(site_i));
        % For this application, I only care about unique sites, so I'm just going to use the first site/inlet. 
        site_i = find(site_i,1,'first');
        
        city_dataset_start_date(ii,1) = min([city_dataset_start_date(ii,1),...
            datetime(co2_usa.(city).(co2_usa.(city).site_names{site_i}).Attributes(strcmp({co2_usa.(city).(co2_usa.(city).site_names{site_i}).Attributes.Name},'dataset_start_date')).Value,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z')]);
        city_dataset_stop_date(ii,1) = max([city_dataset_stop_date(ii,1),...
            datetime(co2_usa.(city).(co2_usa.(city).site_names{site_i}).Attributes(strcmp({co2_usa.(city).(co2_usa.(city).site_names{site_i}).Attributes.Name},'dataset_stop_date')).Value,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z')]);
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
    unique_site_codes = unique(co2_usa.(city).site_codes(~strcmp(co2_usa.(city).site_codes,'')));
    city_lats = nan(size(unique_site_codes,1),1);
    city_lons = nan(size(unique_site_codes,1),1);
    
    for usc_i = 1:length(unique_site_codes) % Loops through each site
        if strcmp(unique_site_codes{usc_i},'BACKGROUND'); continue; end % Skip the background
        site_i = regexpi(co2_usa.(city).site_names,unique_site_codes{usc_i}); % Array of all of the inlets at each site.
        for jj = 1:length(site_i); if isempty(site_i{jj}); site_i{jj} = 0; end; end % Replaces all the empty values with 0.
        site_i = logical(cell2mat(site_i));
        
        % For this application, I only care about unique sites, so I'm just going to use the first site/inlet. 
        site_i = find(site_i,1,'first');
        
        % Location of city sites
        site = co2_usa.(city).site_names{site_i,1};
        i_lat = strcmp({co2_usa.(city).(site).Attributes.Name},'site_latitude');
        i_lon = strcmp({co2_usa.(city).(site).Attributes.Name},'site_longitude');
        
        city_lats(usc_i,1) = str2double(co2_usa.(city).(site).Attributes(i_lat).Value);
        city_lons(usc_i,1) = str2double(co2_usa.(city).(site).Attributes(i_lon).Value);
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
co2usa_zip_file_size = 0;
co2usa_total_files = 0;

for ii = 1:size(cities,1)
    city = cities{ii,1};
    fn_nc = dir(fullfile(readFolder,city,[city,'*.nc']));
    co2usa_nc_file_size = co2usa_nc_file_size+sum(cell2mat({fn_nc.bytes}));
    
    fn_zip = dir(fullfile(readFolder,city,'txt_formatted_files',[city,'*.zip']));
    co2usa_zip_file_size = co2usa_zip_file_size+sum(cell2mat({fn_zip.bytes}));
    
    co2usa_total_files = co2usa_total_files+length(fn_nc)+length(fn_zip);
end
fprintf('Total number of files in the dataset is %0.0f.\n',co2usa_total_files)
fprintf('Total dataset file size is %0.0f MB.\n',(co2usa_nc_file_size+co2usa_zip_file_size)/1000000)



