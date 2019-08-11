% Load the CO2-USA Data Synthesis files from netCDF
%
% USAGE:
%
% The CO2-USA data should be saved in a directory structure as follows:
% /synthesis_output/[city]/[netCDF_file.nc]
%
% For example, for the CO2 data file for Boston it would be:
% /synthesis_output/boston/boston_all_sites_co2_1_hour_R0_2019-07-09.nc
%
% Update the cities you want to extract, the species, and choose if you want to save plots.
% After running the script, the CO2_USA greenhouse gas data will all be contained within the
% 'co2_usa' list variable.
%
% Written by Logan Mitchell (logan.mitchell@utah.edu)
% University of Utah
% Last updated: 2019-07-29

% clear all
% close all
% set(0,'DefaultFigureWindowStyle','docked')

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
t_overall = tic;
if ~exist('species','var')
    species = 'co2';
end
fprintf('Loading the %s city data...\n',species)

if ~exist('cities','var')
    cities = {
        %'boston'
        %'indianapolis'
        %'los_angeles'
        %'northeast_corridor'
        %'portland'
        %'salt_lake_city'
        %'san_francisco_baaqmd'
        'san_francisco_beacon'
        };
    
%    cities = {'indianapolis'}; fprintf('*** Only loading %s.\n',cities{1,1})
end

% Do you want to save the summary figures?
plt.save_overview_image = 'n'; % options: 'y' or 'n'

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s...',city)
    
    fn = dir(fullfile(readFolder,city,[city,'_all_sites_',species,'_','*.nc']));
    if isempty(fn);     fprintf('\n*** Data files for %s were not found! Check the path name and try again.***\nTime elapsed: %4.0f seconds.\n',city,toc(t_city)); continue; end % Skip it if the file doesn't exist.
    
    %ncdisp(fullfile(fn.folder,fn.name))
    info = ncinfo(fullfile(fn.folder,fn.name));
    
    for jj = 1:length(info.Attributes)
        co2_usa.(city).Attributes(jj).Name = info.Attributes(jj).Name;
        co2_usa.(city).Attributes(jj).Value = info.Attributes(jj).Value;
    end
    co2_usa.(city).site_codes = cell(length(info.Groups),1);
    co2_usa.(city).site_names = cell(length(info.Groups),1);
    for group = 1:length(info.Groups)
        co2_usa.(city).site_names{group,1} = info.Groups(group).Name;
        for jj = 1:length(info.Groups(group).Attributes)
            co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Name = info.Groups(group).Attributes(jj).Name;
            co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Value = info.Groups(group).Attributes(jj).Value;
            if strcmp(co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Name,'site_code')
                co2_usa.(city).site_codes{group,1} = co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Value;
            end
        end
        for var = 1:length(info.Groups(group).Variables)
            co2_usa.(city).(info.Groups(group).Name).Variables(var).Name = info.Groups(group).Variables(var).Name;
            co2_usa.(city).(info.Groups(group).Name).Variables(var).Data = ncread(fullfile(fn.folder,fn.name),[info.Groups(group).Name,'/',info.Groups(group).Variables(var).Name]);
            if strcmp('time',co2_usa.(city).(info.Groups(group).Name).Variables(var).Name)
                co2_usa.(city).(info.Groups(group).Name).Variables(var).Data = datetime(co2_usa.(city).(info.Groups(group).Name).Variables(var).Data,'ConvertFrom','posixtime');
            end            
            for jj = 1:length(info.Groups(group).Variables(var).Attributes)
                co2_usa.(city).(info.Groups(group).Name).Variables(var).Attributes(jj).Name = info.Groups(group).Variables(var).Attributes(jj).Name;
                co2_usa.(city).(info.Groups(group).Name).Variables(var).Attributes(jj).Value = info.Groups(group).Variables(var).Attributes(jj).Value;
            end
        end
    end
    
    % Now check to see if there is a background for the city & load that if it exists.
    fn = dir(fullfile(readFolder,city,[city,'_background_',species,'_','*.nc']));
    if isempty(fn)
        fprintf('No background data.\n'); continue;
    else
        %ncdisp(fullfile(fn.folder,fn.name))
        info = ncinfo(fullfile(fn.folder,fn.name));

        % Attributes are the same as the city.
%         for jj = 1:length(info.Attributes)
%             co2_usa.(city).Attributes(jj).Name = info.Attributes(jj).Name;
%             co2_usa.(city).Attributes(jj).Value = info.Attributes(jj).Value;
%         end
%        co2_usa.(city).site_codes = cell(length(info.Groups),1);
%        co2_usa.(city).site_names = cell(length(info.Groups),1);
        
        group_num = length(co2_usa.(city).site_codes);
        for group = 1:length(info.Groups)
            co2_usa.(city).site_names{group+group_num,1} = info.Groups(group).Name;
            for jj = 1:length(info.Groups(group).Attributes)
                co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Name = info.Groups(group).Attributes(jj).Name;
                co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Value = info.Groups(group).Attributes(jj).Value;
                if strcmp(co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Name,'site_code')
                    co2_usa.(city).site_codes{group+group_num,1} = co2_usa.(city).(info.Groups(group).Name).Attributes(jj).Value;
                end
            end
            for var = 1:length(info.Groups(group).Variables)
                co2_usa.(city).(info.Groups(group).Name).Variables(var).Name = info.Groups(group).Variables(var).Name;
                co2_usa.(city).(info.Groups(group).Name).Variables(var).Data = ncread(fullfile(fn.folder,fn.name),[info.Groups(group).Name,'/',info.Groups(group).Variables(var).Name]);
                if strcmp('time',co2_usa.(city).(info.Groups(group).Name).Variables(var).Name)
                    co2_usa.(city).(info.Groups(group).Name).Variables(var).Data = datetime(co2_usa.(city).(info.Groups(group).Name).Variables(var).Data,'ConvertFrom','posixtime');
                end
                for jj = 1:length(info.Groups(group).Variables(var).Attributes)
                    co2_usa.(city).(info.Groups(group).Name).Variables(var).Attributes(jj).Name = info.Groups(group).Variables(var).Attributes(jj).Name;
                    co2_usa.(city).(info.Groups(group).Name).Variables(var).Attributes(jj).Value = info.Groups(group).Variables(var).Attributes(jj).Value;
                end
            end
        end
    end
    
    fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))
end
clear info

fprintf('Done loading city %s data. Overall time elapsed: %4.0f seconds.\n',species,toc(t_overall))

% city = 'indianapolis';
% %site = 'SITE02_co2_136M';
% %site = 'SITE10_co2_40M';
% site = 'SITE09_co2_130M';
% i_species = strcmp({co2_usa.(city).(site).Variables.Name},species);
% i_time = strcmp({co2_usa.(city).(site).Variables.Name},'time');
% 
% foo = co2_usa.(city).(site).Variables(i_time).Data(cursor_info.DataIndex)
% days(duration(foo-datetime(year(foo),1,1)))

% If there are duplicate times, this finds the index of the duplicate times:
%[ia,ib,ic] = unique(co2_usa.(city).(site).Variables(i_time).Data);
%id = setdiff(ic,ib);

%% Plot of the city data:

clear('t1','t2')
for ii = 1:size(cities,1)
city = cities{ii,1};
% Uppercase city name:
city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));

fx(ii) = figure(ii); fx(ii).Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' - All sites'],'FontSize',35,'FontWeight','Bold')
for jj = 1:length(co2_usa.(city).site_names)
    site = co2_usa.(city).site_names{jj,1};
    i_species = strcmp({co2_usa.(city).(site).Variables.Name},species);
    i_time = strcmp({co2_usa.(city).(site).Variables.Name},'time');
    if ~isempty(regexp(site,'background','once'))
        plot(co2_usa.(city).(site).Variables(i_time).Data,co2_usa.(city).(site).Variables(i_species).Data,'k-','LineWidth',2)
    else
        plot(co2_usa.(city).(site).Variables(i_time).Data,co2_usa.(city).(site).Variables(i_species).Data)
    end
end
ylabel([upper(species),' (ppm)'],'FontWeight','Bold')
%ylim([350,750])
hold off; grid on;
legend(replace(co2_usa.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold';

% Plot of 2 years of data:
%t1 = datetime(2014,1,1);  % SLC, Boston, Indy
%t1 = datetime(2015,1,1);  % LA
%t1 = datetime(2010,1,1);  % Portland
%t2 = t1+calyears(2);
%ax = gca; ax.XLim = [t1,t2]; ax.XTick = t1:calmonths(6):t2; datetick('x','yyyy-mm','keepticks')

% Plot all of the data:
ax = gca; t1 = ax.XLim(1); t2 = ax.XLim(2); datetick('x','yyyy')

if strcmp(plt.save_overview_image,'y')
    export_fig(fullfile(readFolder,city,[city,'_img_all_sites_',species,'.jpg']),'-r300','-p0.01',fx(ii))
%    export_fig(fullfile(readFolder,city,[city,'_img_all_sites_',species,'_',[datestr(t1,'yyyymmdd'),'-',datestr(t2,'yyyymmdd')],'.jpg']),'-r300','-p0.01',fx(ii))
end

end

