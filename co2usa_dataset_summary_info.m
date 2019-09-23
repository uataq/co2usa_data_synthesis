clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    'indianapolis'
    %'los_angeles'
    %'northeast_corridor'
    %'portland'
    'salt_lake_city'
    %'san_francisco_beacon'
    %'san_francisco_baaqmd'
    };

eval('co2usa_load_netCDF')

%% Contributor List

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s:\n',city)
    site = co2_usa.(city).site_codes{1};
    for provider_number = 1:str2double(co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},'provider_total_listed')).Value)
        fprintf('%s,%s,%s\n',...
            co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},['provider_',num2str(provider_number),'_name'])).Value,...
            co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},['provider_',num2str(provider_number),'_affiliation'])).Value,...
            co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},['provider_',num2str(provider_number),'_email'])).Value)
    end
end

%% Overall dataset start and stop date

city_dataset_start_date = repmat(datetime(2050,1,1),length(cities),1); % Set dummy values that will be replaced.
city_dataset_stop_date = repmat(datetime(1970,1,1),length(cities),1); % Set dummy values that will be replaced.

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s:\n',city)
    
    for usc_i = 1:length(co2_usa.(city).site_codes) % Loops through each site
        if any(regexpi(co2_usa.(city).site_codes{usc_i},'background')); continue; end % Skip the background
        site = co2_usa.(city).site_codes{usc_i};
        
        city_dataset_start_date(ii,1) = min([city_dataset_start_date(ii,1),...
            datetime(co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},'dataset_start_date')).Value,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z')]);
        city_dataset_stop_date(ii,1) = max([city_dataset_stop_date(ii,1),...
            datetime(co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},'dataset_stop_date')).Value,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z')]);
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
    
    city_lats = nan(size(co2_usa.(city).site_codes,1),1);
    city_lons = nan(size(co2_usa.(city).site_codes,1),1);
    
    for usc_i = 1:length(co2_usa.(city).site_codes) % Loops through each site
        if any(regexpi(co2_usa.(city).site_codes{usc_i},'background')); continue; end % Skip the background
        site = co2_usa.(city).site_codes{usc_i};
        city_lats(usc_i,1) = str2double(co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},'site_latitude')).Value);
        city_lons(usc_i,1) = str2double(co2_usa.(city).(site).Attributes(strcmp({co2_usa.(city).(site).Attributes.Name},'site_longitude')).Value);
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
    fn_nc = dir(fullfile(readFolder,city,'netCDF_formatted_files',[city,'*.nc']));
    co2usa_nc_file_size = co2usa_nc_file_size+sum(cell2mat({fn_nc.bytes}));
    
    fn_zip = dir(fullfile(readFolder,city,'txt_formatted_files',[city,'*.zip']));
    co2usa_zip_file_size = co2usa_zip_file_size+sum(cell2mat({fn_zip.bytes}));
    
    co2usa_total_files = co2usa_total_files+length(fn_nc)+length(fn_zip);
end
fprintf('Total number of files in the dataset is %0.0f.\n',co2usa_total_files)
fprintf('Total dataset file size is %0.0f MB.\n',(co2usa_nc_file_size+co2usa_zip_file_size)/1000000)



