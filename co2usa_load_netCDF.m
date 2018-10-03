clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

% Loads the data from all of the cities.

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
species = 'co2';
t_overall = tic;
fprintf('Loading the %s city data...\n',species)
cities = {
    'boston'
    'indianapolis'
    'los_angeles'
    'portland'
    'san_francisco_baaqmd'
    'san_francisco_beacon'
    };

for ii = 1:size(cities,1)
    city = cities{ii,1};
    t_city = tic;
    fprintf('Working on %s...',city)
    
    fn = dir(fullfile(readFolder,city,[city,'_all_sites_',species,'_','*.nc']));
    if isempty(fn);     fprintf('No data. Time elapsed: %4.0f seconds.\n',toc(t_city)); continue; end % Skip it if the file doesn't exist.
    
    %ncdisp(fullfile(fn.folder,fn.name))
    info = ncinfo(fullfile(fn.folder,fn.name));
    
    for jj = 1:length(info.Attributes)
        d.(city).Attributes(jj).Name = info.Attributes(jj).Name;
        d.(city).Attributes(jj).Value = info.Attributes(jj).Value;
    end
    
    for group = 1:length(info.Groups)
        d.(city).site_names{group,1} = info.Groups(group).Name;
        for jj = 1:length(info.Groups(group).Attributes)
            d.(city).(info.Groups(group).Name).Attributes(jj).Name = info.Groups(group).Attributes(jj).Name;
            d.(city).(info.Groups(group).Name).Attributes(jj).Value = info.Groups(group).Attributes(jj).Value;
        end
        for var = 1:length(info.Groups(group).Variables)
            d.(city).(info.Groups(group).Name).Variables(var).Name = info.Groups(group).Variables(var).Name;
            d.(city).(info.Groups(group).Name).Variables(var).Data = ncread(fullfile(fn.folder,fn.name),[info.Groups(group).Name,'/',info.Groups(group).Variables(var).Name]);
            if strcmp('time',d.(city).(info.Groups(group).Name).Variables(var).Name)
                d.(city).(info.Groups(group).Name).Variables(var).Data = datetime(d.(city).(info.Groups(group).Name).Variables(var).Data,'ConvertFrom','posixtime');
            end            
            for jj = 1:length(info.Groups(group).Variables(var).Attributes)
                d.(city).(info.Groups(group).Name).Variables(var).Attributes(jj).Name = info.Groups(group).Variables(var).Attributes(jj).Name;
                d.(city).(info.Groups(group).Name).Variables(var).Attributes(jj).Value = info.Groups(group).Variables(var).Attributes(jj).Value;
            end
        end
    end
    
    % Plot of all of the data from the city
    fx(ii) = figure(ii); fx(ii).Color = [1 1 1]; clf; hold on
    title([replace(city,'_',' '),' ',species,' - All sites'])
    for jj = 1:length(d.(city).site_names)
        %site = 'COM_co2_45m';
        site = d.(city).site_names{jj,1};
        i_species = strcmp({d.(city).(site).Variables.Name},species);
        i_time = strcmp({d.(city).(site).Variables.Name},'time');
        plot(d.(city).(site).Variables(i_time).Data,d.(city).(site).Variables(i_species).Data)
    end
    hold off; grid on;
    legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
    
    fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))
end
fprintf('Done loading city %s data. Overall time elapsed: %4.0f seconds.\n',species,toc(t_overall))




% city = 'indianapolis';
% %site = 'SITE02_co2_136M';
% %site = 'SITE10_co2_40M';
% site = 'SITE09_co2_130M';
% i_species = strcmp({d.(city).(site).Variables.Name},species);
% i_time = strcmp({d.(city).(site).Variables.Name},'time');
% 
% foo = d.(city).(site).Variables(i_time).Data(cursor_info.DataIndex)
% days(duration(foo-datetime(year(foo),1,1)))

% If there are duplicate times, this finds the index of the duplicate times:
%[ia,ib,ic] = unique(d.(city).(site).Variables(i_time).Data);
%id = setdiff(ic,ib);






