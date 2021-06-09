clear all
close all
set(0,'DefaultFigureWindowStyle','normal')

cities = {
    'boston'
    'indianapolis'
    'los_angeles'
    'portland'
    'salt_lake_city'
    'san_francisco_baaqmd'
    'san_francisco_beacon'
    'toronto'
    'washington_dc_baltimore'
    };

species_to_load = {'co2'
    'ch4'
    'co'
    };

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new','netCDF_formatted_files');
%readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_20191031'); % ORNL Archive
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');

save_overview_image = 'n';
co2_usa = co2usa_load_netCDF(cities,species_to_load,readFolder,save_overview_image);

%%

plt.save_overview_image = 'y';

clear('fx')
%cities = fieldnames(co2_usa);
fx = figure(1); fx.Color = [1 1 1]; clf; axis off
fx.Units = 'Centimeters';
fx.Position(4) = 10.5*2.54;%length(cities)*2.5; % Height
fx.Position(3) = 8*2.54;%size(species_to_load,1)*12; % Width
hold on
p = panel('no-manage-font');
p.pack(size(cities,1),size(species_to_load,1));

%p.de.margin = 0;
p.de.margintop = 0; p.de.marginbottom = 0;
%p(2,2).marginleft = 10;

plt.axis_label = true(size(cities,1),size(species_to_load,1));
plt.axis_label([1,4,9],1) = true;
plt.axis_label([1,4,9],2) = true;
plt.axis_label([2,9],3) = true;

for species_index = 1:length(species_to_load)
species = species_to_load{species_index};

% Make list of cities & remove a city if it doesn't have data from that species.
cities = fieldnames(co2_usa);
% cities_mask = true(size(cities));
% for ii = 1:size(cities,1)
%     city = cities{ii,1}; site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));
%     if isempty(site_codes); cities_mask(ii) = false; end
% end
% cities = cities(cities_mask);
clear('ax','cities_mask')

units_label_abbr = '';
ii=2; site_codes = fieldnames(co2_usa.(cities{ii})); site_codes = site_codes(contains(site_codes,[species,'_']));
units_label = co2_usa.(cities{ii}).(site_codes{1}).attributes.(species).units;
if strcmp(units_label,'nanomol mol-1'); units_label_abbr = 'ppb'; end
if strcmp(units_label,'micromol mol-1'); units_label_abbr = 'ppm'; end

if strcmp(species,'co2')
    plt.ylim = [360,850]; plt.xlim = [datetime(2001,01,01),datetime(2020,01,01)];
    species_display_name = upper(replace(species,species(regexp(species,'[0-9]')),['_',species(regexp(species,'[0-9]'))]));
elseif strcmp(species,'ch4')
    plt.ylim = [1700,9500]; plt.xlim = [datetime(2011,01,01),datetime(2020,01,01)];
    species_display_name = upper(replace(species,species(regexp(species,'[0-9]')),['_',species(regexp(species,'[0-9]'))]));
elseif strcmp(species,'co')
    plt.ylim = [0,2900]; plt.xlim = [datetime(2011,01,01),datetime(2020,01,01)];
    species_display_name = upper(species);
end

for ii = 1:size(cities,1)
    city = cities{ii,1};
    site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));
    if isempty(site_codes); continue; end
    plt.order = 1:9;%[1,2,3,8,9,6,4,5,7];
    %plt.order = [1,2,3,8,9,6,4,5,7];
    
    ax(ii) = p(plt.order(ii),species_index).select(); ax(ii).FontWeight = 'Bold';hold on
    
    % Uppercase city name:
    city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));
    % Custon city long names:
    if strcmp(city,'washington_dc_baltimore'); city_long_name = {'Washington D.C.','& Baltimore'}; end
    if strcmp(city,'san_francisco_baaqmd'); city_long_name = {'San Francisco','BAAQMD'}; end
    if strcmp(city,'san_francisco_beacon'); city_long_name = {'San Francisco','BEACO_2N'}; end
    
    for jj = 1:length(site_codes)
        site = site_codes{jj,1};
        if ~isempty(regexp(site,'background','once'))
            plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species),'k-','LineWidth',2)
        else
            plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species))
        end
    end
    
    ylim(plt.ylim); hold off; grid on;
    
    % Legend is too big for a compliation plot
%     if species_index == 1
%         plt.legend_columns = ceil(length(site_codes)/9); 
%         legend(replace(replace(site_codes,'_',' '),[species,' '],''),'Location','NorthWest','NumColumns',plt.legend_columns,'FontSize',6)
%     end
    
    % City name: Right justified
    %t = annotation('textbox',[sum(ax(ii).Position([1,3]))-0.005,sum(ax(ii).Position([2,4]))-0.019,0,0],'String',city_long_name,'FitBoxToText','on','HorizontalAlignment','right','VerticalAlignment','middle','FontWeight','bold','BackgroundColor',[1,1,1],'Margin',2);
    % City name: Left justified
    t = annotation('textbox',[ax(ii).Position(1)+0.005,sum(ax(ii).Position([2,4]))-0.005,0,0],'String',city_long_name,'FitBoxToText','on','VerticalAlignment','top','FontWeight','bold','BackgroundColor',[1,1,1],'Margin',2);
    
    %if ii>1; ax(ii).YLim = [ax(ii).YLim(1),ax(ii).YLim(2)-1]; end
    if and(species_index<3,and(ii~=size(cities,1),ii~=1))
        ax(ii).XTickLabel = {};
    elseif and(species_index==3,and(ii~=8,ii~=1))
        ax(ii).XTickLabel = {};
    end
    if ii==1 
        ax(ii).XAxisLocation = 'top';
        %ax(ii).XLabel.String = species_display_name;
        ylabel(species_display_name);
    end
    
    %if ii==round(size(cities,1)/2) 
    if plt.axis_label(ii,species_index)
        ylabel([species_display_name,' (',units_label_abbr,')'],'FontWeight','Bold'); 
        % Add a text box of the species on the plot:
        %t2 = annotation('textbox',[sum(ax(ii).Position([1,3]))-0.005,sum(ax(ii).Position([2,4]))-0.019,0,0],'String',[species_display_name,' (',units_label_abbr,')'],'FitBoxToText','on','VerticalAlignment','middle','HorizontalAlignment','right','FontWeight','bold','FontSize',8,'BackgroundColor',[1,1,1],'Margin',2);
    end
    ax(ii).Box = 'on';
end % end of cities loop
linkaxes(ax,'x')
if species_index <3
    ax(ii).XLim = plt.xlim;
else
    ax(8).XLim = plt.xlim;
end

if species_index == 1
    for ii=[1,9]
        ax(ii).XTickLabel = cell(10,1);
        ax(ii).XTickLabel(2:2:10) = num2cell(2004:4:2020)';
    end
end

end % end of species loop

for ii = 1:9
    p(ii,2).marginleft = 14;
    p(ii,3).marginleft = 12;
end

if strcmp(plt.save_overview_image,'y')
    writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
    export_fig(fullfile(writeFolder,['co2usa_all_cities_all_sites_all_species.jpg']),'-r300','-p0.01',fx)
    %    export_fig(fullfile(readFolder,city,[city,'_img_all_sites_',species,'_',[datestr(t1,'yyyymmdd'),'-',datestr(t2,'yyyymmdd')],'.jpg']),'-r300','-p0.01',fx(ii))
end







