clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    %'indianapolis'
    %'los_angeles'
    %'northeast_corridor'
    %'portland'
    %'salt_lake_city'
    %'san_francisco_beacon'
    %'san_francisco_baaqmd'
    };

species = 'co2';
eval('co2usa_load_netCDF')

%% Geographic mean of the city lat/lon:

for ii = 1:size(cities,1)
    city = cities{ii,1};
    
    % Uppercase city name:
    city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));
    
    unique_site_codes = unique(d.(city).site_codes(~strcmp(d.(city).site_codes,'')));
    city_lats = nan(size(unique_site_codes,1),1);
    city_lons = nan(size(unique_site_codes,1),1);
    
    for usc_i = 1:length(unique_site_codes) % Loops through each site
        site_i = regexpi(d.(city).site_names,unique_site_codes{usc_i}); % Array of all of the inlets at each site.
        for jj = 1:length(site_i); if isempty(site_i{jj}); site_i{jj} = 0; end; end % Replaces all the empty values with 0.
        site_i = logical(cell2mat(site_i));
        
        % For this application, I only care about unique sites, so I'm just going to use the first site/inlet. 
        site_i = find(site_i,1,'first');
        
        % Location of city sites
        site = d.(city).site_names{site_i,1};
        i_lat = strcmp({d.(city).(site).Attributes.Name},'site_latitude');
        i_lon = strcmp({d.(city).(site).Attributes.Name},'site_longitude');
        
        city_lats(usc_i,1) = str2double(d.(city).(site).Attributes(i_lat).Value);
        city_lons(usc_i,1) = str2double(d.(city).(site).Attributes(i_lon).Value);
        fprintf('%s-%s: %0.4f %0.4f\n',city,site,city_lats(usc_i,1),city_lons(usc_i,1))
    end
    fprintf('%s overall average:\n%0.4f %0.4f\n',city,mean(city_lats),mean(city_lons))
    
    plt.station_map = 'y';
    if strcmp(plt.station_map,'y')
        basemap_fn = dir(fullfile(readFolder,'maps',[city,'_basemap*.jpg']));
        if isempty(basemap_fn)
            fx(ii) = figure(ii); fx(ii).WindowStyle = 'normal';  fx(ii).Color = [1 1 1]; fx(ii).Units = 'centimeters'; fx(ii).Position = [fx(ii).Position(1:2),15,15];clf;hold on
            mapLim = [min(city_lons)-0.1,max(city_lons)+0.1,min(city_lats)-0.1,max(city_lats)+0.1];
            ax(1) = axesm('MapProjection','mercator','MapLatLimit',mapLim(3:4),'MapLonLimit',mapLim(1:2),'Grid','on','MeridianLabel','on','ParallelLabel','on');
            ax(1).Position = [.01,.01,.98,.98]; box('on'); hold('all');
            set(gca,'XLim',mapLim(1:2)); set(gca,'YLim',mapLim(3:4))
            key = get_lem_google_apikey;
            plot_google_map('MapType','terrain','Scale',2,'showlabels',0,'APIKey',key) % redrawing the map to make sure it has the correct axes ratio.
            set(gca,'XLim',mapLim(1:2)); set(gca,'YLim',mapLim(3:4))
            set(gcf,'renderer','zbuffer')
            export_fig(fullfile(readFolder,'maps',[city,'_basemap_',num2str(mapLim(1)),'_',num2str(mapLim(2)),'_',num2str(mapLim(3)),'_',num2str(mapLim(4)),'.jpg']),'-r300','-p0.01',fx(ii))
            basemap_fn = dir(fullfile(readFolder,'maps',[city,'_basemap*.jpg']));
        end
        % Extract map lat/lon from the file name:
        basemap_i = regexp(basemap_fn(1).name,'basemap'); ui = regexp(basemap_fn(1).name,'_'); ui = ui(ui>basemap_i); ui = [ui,regexp(basemap_fn(1).name,'.jpg')];
        mapLim = [str2double(basemap_fn(1).name(ui(1)+1:ui(2)-1)),str2double(basemap_fn(1).name(ui(2)+1:ui(3)-1)),...
            str2double(basemap_fn(1).name(ui(3)+1:ui(4)-1)),str2double(basemap_fn(1).name(ui(4)+1:ui(5)-1))];
        
        fx(ii) = figure(ii); clf; fx(ii).WindowStyle = 'normal';  fx(ii).Color = [1 1 1]; fx(ii).Units = 'centimeters'; fx(ii).Position = [fx(ii).Position(1:2),15,15];
        ax = axes; ax.Position = [.01,.01,.98,.98]; hold on
        usamap(mapLim(3:4)',mapLim(1:2)'); setm(ax,'MapProjection','mercator');
        cityMap = imread(fullfile(basemap_fn(1).folder,basemap_fn(1).name));
        R = georasterref('RasterSize',size(cityMap), ...
            'RasterInterpretation', 'cells', 'ColumnsStartFrom', 'north', ...
            'LatitudeLimits', mapLim(3:4), 'LongitudeLimits', mapLim(1:2));
        geoshow(ax,cityMap,R,'facealpha',0.8);
        tightmap; mlabel; plabel; gridm;% Togle off
        for usc_i = 1:length(unique_site_codes)
            plotm(city_lats(usc_i),city_lons(usc_i),'^','MarkerFaceColor',[.5 .5 1],'MarkerEdgeColor','k','MarkerSize',10) % Site markers.
        end
        plt.save_overview_map = 'n';
        if strcmp(plt.save_overview_map,'y')
            %set(gcf,'renderer','zbuffer')
            export_fig(fullfile(readFolder,city,[city,'_overview_map.jpg']),'-r300','-p0.01',fx(ii))
        end
    end
    
end

