

%% Master script to process all CO2-USA cities at once.

%% Boston
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'boston','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'boston','txt_formatted_files','*.txt'))
eval('co2usa_boston_to_netCDF')
eval('co2usa_boston_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Indianapolis
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'indianapolis','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'indianapolis','txt_formatted_files','*.txt'))
eval('co2usa_indianapolis_to_netCDF')
eval('co2usa_indianapolis_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Los Angeles
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'los_angeles','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'los_angeles','txt_formatted_files','*.txt'))
eval('co2usa_los_angeles_to_netCDF')
%eval('co2usa_los_angeles_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Northeast Corridor
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'northeast_corridor','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'northeast_corridor','txt_formatted_files','*.txt'))
eval('co2usa_northeast_corridor_to_netCDF')
%eval('co2usa_northeast_corridor_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Portland
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'portland','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'portland','txt_formatted_files','*.txt'))
eval('co2usa_portland_to_netCDF')
%eval('co2usa_portland_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Salt Lake City
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'salt_lake_city','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'salt_lake_city','txt_formatted_files','*.txt'))
eval('co2usa_salt_lake_city_to_netCDF')
eval('co2usa_salt_lake_city_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% San Francisco BAAQMD
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'san_francisco_baaqmd','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'san_francisco_baaqmd','txt_formatted_files','*.txt'))
eval('co2usa_san_francisco_baaqmd_to_netCDF')
%eval('co2usa_san_francisco_baaqmd_background_to_netCDF')
eval('co2usa_netCDF2txt')


%% San Francisco BEACON
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'san_francisco_beacon','netCDF_formatted_files','*.nc'))
delete(fullfile(writeFolder,'san_francisco_beacon','txt_formatted_files','*.txt'))
eval('co2usa_san_francisco_beacon_to_netCDF')
%eval('co2usa_san_francisco_beacon_background_to_netCDF')
eval('co2usa_netCDF2txt')

%%
%return

%% Package up each city in a zip file:

clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');

fprintf('Working on zipping the city files...\n')

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
t_city = tic;

file_names = struct;
for ii = 1:size(cities,1)
    city = cities{ii,1};
    fprintf('Working on %s...',city)
    netCDF_files = dir(fullfile(writeFolder,city,'netCDF_formatted_files','*.nc'));
    txt_files = dir(fullfile(writeFolder,city,'txt_formatted_files','*.txt'));
    
    all_files = [join([cellstr(repmat([city,'/netCDF_formatted_files/'],length(netCDF_files),1)),{netCDF_files.name}'],'',2);...
        join([cellstr(repmat([city,'/txt_formatted_files/'],length(txt_files),1)),{txt_files.name}'],'',2)];
    
    zip(fullfile(writeFolder,['co2usa_',city,'_',netCDF_files(1).name(end-12:end-3),'.zip']),all_files,fullfile(writeFolder))
    fprintf('Done.\n')
end
fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))

