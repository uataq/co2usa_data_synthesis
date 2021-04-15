function [co2_usa] = co2usa_load_netCDF(cities,species_to_load,readFolder,save_overview_image)
% co2usa_load_netCDF: Load the CO2-USA Data Synthesis files from netCDF
% 
% USAGE:
%
% The CO2-USA synthesis data is available to download from the ORNL DAAC:
% https://doi.org/10.3334/ORNLDAAC/1743
% 
% To download the data, first sign into your account (or create one if you don't have one). 
% Next, click on "Download Data" to download the entire data set in a zip file. 
% Extract the netCDF files to a folder on your computer.
%
% The CO2-USA synthesis data files should be all saved in a single directory:
% /co2_usa_netCDF_files/[netCDF_files.nc]
%
% For example, for the CO2 data file for Boston it would be:
% /co2_usa_netCDF_files/boston_all_sites_co2_1_hour_R0_2019-07-09.nc
%
% The function has 4 inputs:
% cities: Cell with one or more CO2-USA cities.  Example:
%     cities = {
%         %'boston'
%         'indianapolis'
%         %'los_angeles'
%         %'northeast_corridor'
%         %'portland'
%         'salt_lake_city'
%         %'san_francisco_baaqmd'
%         %'san_francisco_beacon'
%         %'toronto'
%         };
%
% species_to_load: Cell with one or more target species. Example:
%     species_to_load = {
%         'co2'
%         'ch4'
%         %'co'
%         };
%
% readFolder: Path to the directory where you saved the data files. Example:
%     currentFolder = pwd;
%     readFolder = fullfile(currentFolder,'co2_usa_netCDF_files');
%
% save_overview_image: Flag to save a figure of the loaded data. 
%   NOTE: this requires the export_fig package availabe on the Matlab file exchange:
%   https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig
%   Example: 
%     save_overview_image = 'n'; % options: 'y' or 'n'
%
% The function returns the CO2_USA greenhouse gas data in the 'co2_usa' variable.
%
% For more information, visit the CO2-USA GitHub repository:
% https://github.com/loganemitchell/co2usa_data_synthesis
%
% Written by Logan Mitchell (logan.mitchell@utah.edu)
% University of Utah
% Last updated: 2021-03-12

%clear all; close all; set(0,'DefaultFigureWindowStyle','docked')
t_overall = tic;

if ~exist('cities','var')
    cities = {
        %'boston'
        %'indianapolis'
        %'los_angeles'
        %'northeast_corridor'
        %'portland'
        'salt_lake_city'
        %'san_francisco_baaqmd'
        %'san_francisco_beacon'
        %'toronto'
        };
end

if ~exist('species_to_load','var')
    species_to_load = {
        'co2'
        'ch4'
        %'co'
        };
end

if ~exist('readFolder','var')
    currentFolder = pwd;
    readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output','netCDF_formatted_files');
end

% Do you want to save the summary figures?
if ~exist('save_overview_image','var')
    save_overview_image = 'n'; % options: 'y' or 'n'
end

for species_index = 1:length(species_to_load)
species = species_to_load{species_index};
fprintf('Loading the %s city data...\n',species)

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('------Working on %s: ------\n',city)
    
    %all_files = dir(fullfile(readFolder,city,'netCDF_formatted_files',[city,'*',species,'_','*.nc']));
    all_files = dir(fullfile(readFolder,[city,'*',species,'_','*.nc']));
    
    if isempty(all_files); fprintf('\n*** Data files for %s were not found! Check the path name and try again.***\nTime elapsed: %4.0f seconds.\n',city,toc(t_city)); continue; end % Skip it if the file doesn't exist.
    
    for fni = 1:length(all_files)
        
        fn = all_files(fni);
        fprintf('Working on %s.\n',fn.name)
        
        %ncdisp(fullfile(fn.folder,fn.name))
        info = ncinfo(fullfile(fn.folder,fn.name));
        
        fn_parts = strsplit(fn.name,{'_','.'});
        
        site_code = fn.name(length(city)+2:regexp(fn.name,'_1_hour')-1);
        
        % Loading Attributes:
        for jj = 1:length(info.Attributes)
            attribute_name = info.Attributes(jj).Name;
            if strcmp(attribute_name(1),'_'); attribute_name = attribute_name(2:end); end
            co2_usa.(city).(site_code).global_attributes.(attribute_name) = info.Attributes(jj).Value;
        end
        
        % Loading Variables
        for var = 1:length(info.Variables)
            variable_name = info.Variables(var).Name;
            for jj = 1:length(info.Variables(var).Attributes)
                attribute_name = info.Variables(var).Attributes(jj).Name;
                % names can't start with an underscore
                if strcmp(attribute_name(1),'_'); attribute_name = attribute_name(2:end); end
                co2_usa.(city).(site_code).attributes.(variable_name).(attribute_name) = info.Variables(var).Attributes(jj).Value;
            end
            co2_usa.(city).(site_code).(variable_name) = ncread(fullfile(fn.folder,fn.name),[info.Name,info.Variables(var).Name]);
            if strcmp('time',variable_name)
                co2_usa.(city).(site_code).(variable_name) = datetime(co2_usa.(city).(site_code).(variable_name),'ConvertFrom','posixtime');
            end
        end
    end
    %co2_usa.(city).site_codes = fieldnames(co2_usa.(city)); co2_usa.(city).site_codes = co2_usa.(city).site_codes(~strcmp(co2_usa.(city).site_codes,'site_codes'));
    clear info
    fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))
end
fprintf('Done loading city %s data. Overall time elapsed: %4.0f seconds.\n',species,toc(t_overall))

% city = 'indianapolis';
% %site = 'SITE02_co2_136M';
% %site = 'SITE10_co2_40M';
% site = 'SITE09_co2_130M';
% 
% foo = co2_usa.(city).(site).time(cursor_info.DataIndex)
% days(duration(foo-datetime(year(foo),1,1)))
% If there are duplicate times, this finds the index of the duplicate times:
%[ia,ib,ic] = unique(co2_usa.(city).(site).time);
%id = setdiff(ic,ib);

%% Plot of the city data:

clear('t1','t2')
for ii = 1:size(cities,1)
city = cities{ii,1}; if ~isfield(co2_usa,city); continue; end
site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));
if isempty(site_codes); continue; end

% Uppercase city name:
city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));

fx(ii+species_index*100) = figure(ii+species_index*100); fx(ii+species_index*100).Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' - All sites'],'FontSize',35,'FontWeight','Bold')
for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once'))
        plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species),'k-','LineWidth',2)
    else
        plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species))
    end
end
units_label_abbr = '';
units_label = co2_usa.(city).(site_codes{1}).attributes.(species).units;
if strcmp(units_label,'nanomol mol-1'); units_label_abbr = 'ppb'; end
if strcmp(units_label,'micromol mol-1'); units_label_abbr = 'ppm'; end

ylabel([upper(species),' (',units_label_abbr,')'],'FontWeight','Bold')
%ylim([350,750])
hold off; grid on;
legend(replace(site_codes,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold';

% Plot of 2 years of data:
%t1 = datetime(2014,1,1);  % SLC, Boston, Indy
%t1 = datetime(2015,1,1);  % LA
%t1 = datetime(2010,1,1);  % Portland
%t2 = t1+calyears(2);
%ax = gca; ax.XLim = [t1,t2]; ax.XTick = t1:calmonths(6):t2; datetick('x','yyyy-mm','keepticks')

% Plot all of the data:
%ax = gca; t1 = ax.XLim(1); t2 = ax.XLim(2); datetick('x','yyyy')

if strcmp(save_overview_image,'y')
    %writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output',city);
    writeFolder = '';
    export_fig(fullfile(writeFolder,[city,'_img_all_sites_',species,'.jpg']),'-r200','-p0.01',fx(ii+species_index*100))
%    export_fig(fullfile(readFolder,city,[city,'_img_all_sites_',species,'_',[datestr(t1,'yyyymmdd'),'-',datestr(t2,'yyyymmdd')],'.jpg']),'-r300','-p0.01',fx(ii))
end

end % end of cities loop

end % end of species_to_load



end

