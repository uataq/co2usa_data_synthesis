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

% This station count script is set up to only process one species at a time.
species_to_load = {
    'co2'
    %'ch4'
    %'co'
    };

species = species_to_load{1};

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new','netCDF_formatted_files');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');

save_overview_image = 'n';
co2_usa = co2usa_load_netCDF(cities,species_to_load,readFolder,save_overview_image);

% Update the cities structure so that it only includes the cities with data.
cities = fieldnames(co2_usa);

%% Counts the number of sites for each month

year_start = 2000; year_end = 2020;
n_months = (year_end-year_start)*12;
mm = datetime(repmat(year_start,n_months,1),(1:n_months)',ones(n_months,1));

fprintf('Counting the number of sites with %s data...\n',species)

for ii = 1:size(cities,1)
    city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
    t_city = tic;
    fprintf('Working on %s...',city)
    
    st_count.(city) = zeros(n_months,1); % station count
    in_count.(city) = zeros(n_months,1); % inlet count
    site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));

    unique_site_codes = unique(site_codes);
    unique_site_codes = unique_site_codes(~strcmp(unique_site_codes,[species,'_background'])); % Don't include the "background"
    str_parts = split(unique_site_codes,'_',2);
    [~,ia,ib] = unique(str_parts(:,2)); % ia is the indicies of each unique site and ib is the index of the 
    for mm_i = 2:length(mm) % scans each month
        site_count_temp = 0; % Start with 0 stations in the month.
        for usc_i = 1:length(ia) % Loops through each unique site
            site_inlet_flag = 0;
            usc_j_all = find(usc_i==ib);
            for jj = 1:length(usc_j_all) % Loops through the inlets at the site
                usc_j = usc_j_all(jj);
                site = site_codes{usc_j,1};
                if any(and(co2_usa.(city).(site).time>mm(mm_i-1),co2_usa.(city).(site).time<mm(mm_i)))
                    % If there is data at ANY of the inlets, set this flag to 1.  This counts the number of sites. Multiple inlets at a site don't increas the number.
                    site_inlet_flag = 1;
                    in_count.(city)(mm_i,1) = in_count.(city)(mm_i,1)+1;
                end
            end
            site_count_temp = site_count_temp+site_inlet_flag; % Counts the total unique sites that have data in the month.
        end
        st_count.(city)(mm_i,1) = site_count_temp; % Total for the month after looping through all of the unique sites.
    end
    st_count.(city)(isnan(st_count.(city))) = 0; % If any are nans for some reason, set to 0.
    %st_count.(city)(1:find(st_count.(city)~=0,1,'first')-1) = nan;
    %st_count.(city)(st_count.(city)==0) = nan;
    fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))
end
fprintf('All cities complete.\n')

st_count_backup = st_count;
in_count_backup = in_count;

%%

st_count = st_count_backup;
in_count = in_count_backup;

% Take care of the start/end
for ii = 1:size(cities,1)
    city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
    t1 = find(st_count.(city)~=0,1,'first');
    t2 = find(st_count.(city)~=0,1,'last');
    st_count.(city)(1:t1-2) = nan; % Time before measurements start.
    in_count.(city)(1:t1-2) = nan; % Time before measurements start.
    if t2<length(st_count.(city)) % Time after measurements end.
        st_count.(city)(t2+2:end) = nan;
        in_count.(city)(t2+2:end) = nan;
    end
end

% if strcmp(species,'co2')
% % Fix the tail ends so it's clear they are ongoing.  If I update the data, remove it from the list or comment it out. 
% ii = strcmp(cities,'san_francisco_beacon'); if any(ii); city = cities{ii,1}; st_count.(city)(end-4:end) = nan; in_count.(city)(end-4:end) = nan; end
% %ii = strcmp(cities,'salt_lake_city'); if any(ii); city = cities{ii,1}; st_count.(city)(end-8:end) = nan; end
% ii = strcmp(cities,'salt_lake_city'); if any(ii); city = cities{ii,1}; jj=find(st_count.(city)==0,1,'last'); st_count.(city)(jj) = nan; in_count.(city)(jj) = nan; end
% %ii = strcmp(cities,'los_angeles'); if any(ii); city = cities{ii,1}; jj=find(st_count.(city)==0,1,'last'); st_count.(city)(jj) = nan; in_count.(city)(jj) = nan; end
% elseif strcmp(species,'ch4')
% ii = strcmp(cities,'salt_lake_city'); if any(ii); city = cities{ii,1}; jj=find(st_count.(city)==0,1,'last'); st_count.(city)(jj) = nan; in_count.(city)(jj) = nan; end
% %ii = strcmp(cities,'los_angeles'); if any(ii); city = cities{ii,1}; jj=find(st_count.(city)==0,1,'last'); st_count.(city)(jj) = nan; in_count.(city)(jj) = nan; end
% elseif strcmp(species,'co')
% %ii = strcmp(cities,'los_angeles'); if any(ii); city = cities{ii,1}; jj=find(st_count.(city)==0,1,'last'); st_count.(city)(jj) = nan; in_count.(city)(jj) = nan; end
% end
% 
%% 

export_station_count = 'y';
if strcmp(export_station_count,'y')
    fprintf('Exporting the station count data to an xls.\n')
    flat = nan(n_months,size(cities,1)*2);
    col = 1;
    for ii = 1:size(cities,1)
        city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
        flat(:,col) = st_count.(city); 
        flat(:,col+size(cities,1)) = in_count.(city); 
        col = col+1;
    end
    xlswrite(fullfile(writeFolder,['co2usa_station_count_',datestr(today,'yyyy-mm-dd'),'_',species,'.xlsx']),[[{'Month'},fieldnames(co2_usa)',join([fieldnames(co2_usa),cellstr(repmat('-inlets',size(cities,1),1))],'',2)'];...
        [cellstr(datestr(mm,'yyyy-mm-dd')),num2cell(flat)]]);
    % copy data file manually to the directory with the paper in it where the Grapher figure files are. 
    clear flat col
end

%%

cities_display_names = regexprep(replace(fieldnames(co2_usa),'_',' '),'(\<[a-z])','${upper($1)}');
cities_display_names = replace(cities_display_names,'Beacon','BEACO2N');
cities_display_names = replace(cities_display_names,'Baaqmd','BAAQMD');

fx = figure(100); fx.Color = [1 1 1]; clf; hold on
for ii = 1:size(cities,1)
    city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
    plt.l(ii) = plot(mm,st_count.(city),'LineWidth',6);
end
for ii = 1:size(cities,1)
    city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
    plot(mm,in_count.(city),'--','LineWidth',3,'Color',plt.l(ii).Color)
end
hold off; grid on

legend(cities_display_names,'Location','NorthWest','FontWeight','Bold','FontSize',20)
ylabel('Number of Measurement Sites')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 25; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

%export_fig(fullfile(writeFolder,['co2usa_station_count_',species,'_',datestr(today,'yyyy-mm-dd'),'.jpg']),'-r300','-p0.01',fx)

%% Find the total sample time & total number of sites.

total_number_of_sites = 0;
total_number_of_inlets = 0;
total_sample_time = 0;
for ii = 1:size(cities,1)
    city = cities{ii,1}; %if ~isfield(co2_usa,city); continue; end
    site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));
    unique_site_codes = unique(site_codes);
    unique_site_codes = unique_site_codes(~strcmp(unique_site_codes,[species,'_background'])); % Don't include the "background"
    str_parts = split(unique_site_codes,'_',2);
    [~,ia,ib] = unique(str_parts(:,2)); % ia is the indicies of each unique site and ib is the index of the 
    number_of_sites.(city) = size(ia,1);
    number_of_inlets.(city) = size(ib,1);
    total_number_of_sites = total_number_of_sites+number_of_sites.(city);
    total_number_of_inlets = total_number_of_inlets+number_of_inlets.(city);
    sample_time.(city) = 0;
    for jj = 1:length(unique_site_codes)
%        sample_time.(city) = sample_time.(city)+size(co2_usa.(city).(unique_site_codes{1}).time,1); % counts all hours-even if measurement is nan;
        sample_time.(city) = sample_time.(city)+sum(~isnan(co2_usa.(city).(unique_site_codes{1}).(species)));
    end
    total_sample_time = total_sample_time+sample_time.(city);
    fprintf('%s: %0.0f years from %0.0f sites with %0.0f inlets.\n',city,round(sample_time.(city)/(24*365)),number_of_sites.(city),number_of_inlets.(city))
end

% total_sample_time = 0;
% for ii = 1:size(cities,1)
%     city = cities{ii,1}; if ~isfield(co2_usa,city); continue; end
%     total_sample_time = total_sample_time+nansum(st_count.(city));
% end

%round(total_sample_time2/(24*365))

fprintf('Total sample time in the CO2-USA data set for %s are: %0.0f years from %0.0f sites with %0.0f inlets.\n',...
    species,round(total_sample_time/(24*365)),total_number_of_sites,total_number_of_inlets)

%%




