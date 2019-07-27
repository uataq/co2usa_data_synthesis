clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    'indianapolis'
    'los_angeles'
    'northeast_corridor'
    'portland'
    'salt_lake_city'
    'san_francisco_beacon'
    'san_francisco_baaqmd'
    };

eval('co2usa_load_netCDF')

year_start = 2000; year_end = 2018;
n_months = (year_end-year_start)*12;
mm = datetime(repmat(year_start,n_months,1),(1:n_months)',ones(n_months,1));

st_count.(city) = zeros(n_months,1);

%% Counts the number of sites for each month

fprintf('Counting the number of sites with %s data...\n',species)

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s...',city)
    unique_site_codes = unique(d.(city).site_codes(~strcmp(d.(city).site_codes,'')));
    for mm_i = 2:length(mm) % scans each month
        site_count_temp = 0;
        for usc_i = 1:length(unique_site_codes) % Loops through each site
            site_inlet_i = regexp(d.(city).site_names,unique_site_codes{usc_i}); % Array of all of the inlets at each site.
            site_inlet_flag = 0;
            for jj = 1:length(d.(city).site_names) % Loop through all of the site/inlet combos
                if isempty(site_inlet_i{jj}); continue; end % Skip if its the wrong site.
                site = d.(city).site_names{jj,1};
                %if ~isempty(regexp(site,'background','once')); continue; end
                i_time = strcmp({d.(city).(site).Variables.Name},'time');
                if any(and(d.(city).(site).Variables(i_time).Data>mm(mm_i-1),d.(city).(site).Variables(i_time).Data<mm(mm_i)))
                    site_inlet_flag = 1; % If there is data at any of the inlets, set this site flag to 1
                end
            end
            site_count_temp = site_count_temp+site_inlet_flag; % Counts the total unique sites that have data in the month.
        end
        st_count.(city)(mm_i,1) = site_count_temp; % Total for the month after looping through all of the unique sites.
    end
    fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))
end


%%

fx = figure(100); fx.Color = [1 1 1]; clf; hold on
for ii = 1:size(cities,1)
    city = cities{ii,1};
    plot(mm,st_count.(city),'LineWidth',6)
end
hold off
grid on
legend(replace(cities,'_',' '),'Location','NorthWest')
ylabel('# of measurement sites')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

export_fig(fullfile(readFolder,['co2usa_station_count_',species,'.jpg']),'-r300','-p0.01',fx)



