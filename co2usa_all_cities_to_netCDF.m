

%% Master script to process all CO2-USA cities at once.

%% Boston
clear all
close all
currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','data_input');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','boston*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','boston*.txt'))
eval('co2usa_boston_to_netCDF')
eval('co2usa_boston_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Indianapolis
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','indianapolis*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','indianapolis*.txt'))
eval('co2usa_indianapolis_to_netCDF')
eval('co2usa_indianapolis_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Los Angeles
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','los_angeles*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','los_angeles*.txt'))
eval('co2usa_los_angeles_to_netCDF')
%eval('co2usa_los_angeles_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Northeast Corridor
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','northeast_corridor*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','northeast_corridor*.txt'))
eval('co2usa_northeast_corridor_to_netCDF')
%eval('co2usa_northeast_corridor_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Portland
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','portland*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','portland*.txt'))
eval('co2usa_portland_to_netCDF')
%eval('co2usa_portland_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Salt Lake City
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','salt_lake_city*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','salt_lake_city*.txt'))
eval('co2usa_salt_lake_city_to_netCDF')
eval('co2usa_salt_lake_city_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% San Francisco BAAQMD
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','san_francisco_baaqmd*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','san_francisco_baaqmd*.txt'))
eval('co2usa_san_francisco_baaqmd_to_netCDF')
%eval('co2usa_san_francisco_baaqmd_background_to_netCDF')
eval('co2usa_netCDF2txt')


%% San Francisco BEACON
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','san_francisco_beacon*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','san_francisco_beacon*.txt'))
eval('co2usa_san_francisco_beacon_to_netCDF')
%eval('co2usa_san_francisco_beacon_background_to_netCDF')
eval('co2usa_netCDF2txt')

%% Toronto
clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');
delete(fullfile(writeFolder,'netCDF_formatted_files','toronto*.nc'))
delete(fullfile(writeFolder,'txt_formatted_files','toronto*.txt'))
eval('co2usa_toronto_to_netCDF')
%eval('co2usa_toronto_background_to_netCDF')
eval('co2usa_netCDF2txt')

%%
return

%% Package up each city in a zip file:

clear all
close all
currentFolder = pwd;
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new');

fprintf('Working on zipping the city files...\n')

cities = {
    'boston'
    'indianapolis'
    'los_angeles'
    'northeast_corridor'
    'portland'
    'salt_lake_city'
    'san_francisco_beacon'
    'san_francisco_baaqmd'
    'toronto'
    };
t_city = tic;

file_names = struct;
for ii = 1:size(cities,1)
    city = cities{ii,1};
    fprintf('Working on %s...',city)
    netCDF_files = dir(fullfile(writeFolder,'netCDF_formatted_files',[city,'*.nc']));
    txt_files = dir(fullfile(writeFolder,'txt_formatted_files',[city,'*.txt']));
    
    all_files = [fullfile({netCDF_files.folder}',{netCDF_files.name}');...
        fullfile({txt_files.folder}',{txt_files.name}')];
    
    zip(fullfile(writeFolder,['co2usa_',city,'_',netCDF_files(1).name(end-12:end-3),'.zip']),all_files,fullfile(writeFolder))
    fprintf('Done.\n')
end
fprintf('Done. Time elapsed: %4.0f seconds.\n',toc(t_city))

