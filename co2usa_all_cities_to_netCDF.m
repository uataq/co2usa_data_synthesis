

%% Master script to process all CO2-USA cities at once.

%% Boston
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'boston','*.nc'))
delete(fullfile(writeFolder,'boston','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'boston','txt_formatted_files','*.zip'))
eval('co2usa_boston_to_netCDF')
eval('co2usa_boston_background_to_netCDF')

%% Indianapolis
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'indianapolis','*.nc'))
delete(fullfile(writeFolder,'indianapolis','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'indianapolis','txt_formatted_files','*.zip'))
eval('co2usa_indianapolis_to_netCDF')
eval('co2usa_indianapolis_background_to_netCDF')

%% Los Angeles
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'los_angeles','*.nc'))
delete(fullfile(writeFolder,'los_angeles','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'los_angeles','txt_formatted_files','*.zip'))
eval('co2usa_los_angeles_to_netCDF')
%eval('co2usa_los_angeles_background_to_netCDF')

%% Northeast Corridor
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'northeast_corridor','*.nc'))
delete(fullfile(writeFolder,'northeast_corridor','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'northeast_corridor','txt_formatted_files','*.zip'))
eval('co2usa_northeast_corridor_to_netCDF')
%eval('co2usa_northeast_corridor_background_to_netCDF')

%% Portland
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'portland','*.nc'))
delete(fullfile(writeFolder,'portland','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'portland','txt_formatted_files','*.zip'))
eval('co2usa_portland_to_netCDF')
%eval('co2usa_portland_background_to_netCDF')

%% Salt Lake City
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'salt_lake_city','*.nc'))
delete(fullfile(writeFolder,'salt_lake_city','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'salt_lake_city','txt_formatted_files','*.zip'))
eval('co2usa_salt_lake_city_to_netCDF')
eval('co2usa_salt_lake_city_background_to_netCDF')

%% San Francisco BAAQMD
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'san_francisco_baaqmd','*.nc'))
delete(fullfile(writeFolder,'san_francisco_baaqmd','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'san_francisco_baaqmd','txt_formatted_files','*.zip'))
eval('co2usa_san_francisco_baaqmd_to_netCDF')
%eval('co2usa_san_francisco_baaqmd_background_to_netCDF')

%% San Francisco BEACON
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
delete(fullfile(writeFolder,'san_francisco_beacon','*.nc'))
delete(fullfile(writeFolder,'san_francisco_beacon','txt_formatted_files','*.txt'))
delete(fullfile(writeFolder,'san_francisco_beacon','txt_formatted_files','*.zip'))
eval('co2usa_san_francisco_beacon_to_netCDF')
%eval('co2usa_san_francisco_beacon_background_to_netCDF')



