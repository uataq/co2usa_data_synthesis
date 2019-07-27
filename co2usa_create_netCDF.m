% Must first run the CO2USA processing script to generate all of the
% variables.


if ~exist(fullfile(writeFolder,city),'dir'); mkdir(fullfile(writeFolder,city)); end

for species_ind = 1:length(site.unique_species)

species = site.unique_species{species_ind};

fnStr = fullfile(writeFolder,city,[city,'_all_sites_',species,'_1_hour_R0_',site.date_issued_str,'.nc']);

fprintf('Working on %s.\n',fnStr)

n.ncid = netcdf.create(fnStr,'NETCDF4');

varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'title',['Hourly averaged atmospheric ',site.unique_species_long_name{species_ind},' (',upper(species),') measurements in ',city_long_name,'.']);
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'summary',['Hourly averaged atmospheric ',upper(species),' measurements from ',num2str(sum(strcmp(site.species,species))),' monitoring sites in ',city_long_name,'.']);
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'keywords','carbon dioxide, methane, carbon monoxide, urban, greenhouse gas');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'comment',['Observations represent the hourly average ',upper(species),' mole fraction with the time stamp representing the floored hour. For example: data from 08:00 to 08:59 were averaged and have the time stamp of 08:00.']);
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'references',site.reference);
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'source','spectroscopy');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'date_created',site.date_issued_str); % Indianapolis does not distinguish between date created and date issued.
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'date_issued',site.date_issued_str);

varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'fair_use_policy1','These cooperative data products are made freely available to the public and scientific community to advance the study of urban carbon cycling and associated air pollutants.');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'fair_use_policy2','Fair credit should be given to data contributors and will depend on the nature of your work.  When you start data analysis that may result in a publication, it is your responsibility to contact the data contributors directly, such that, if it is appropriate, they have the opportunity to contribute substantively and become a co-author.');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'fair_use_policy3','Data contributors reserve the right to make corrections to the data based on scientific grounds (e.g. recalibration or operational issues).');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'fair_use_policy4','Use of the data implies an agreement to reciprocate by making your research efforts (e.g. measurements as well as model tools, data products, and code) publicly available in a timely manner to the best of your ability.');

varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'provider_total_listed',num2str(length(provider)));
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'provider_url',city_url);
for i = 1:length(provider)
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_name'],provider(i).name);
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_address1'],provider(i).address1);
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_address2'],provider(i).address2);
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_address3'],provider(i).address3);
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_country'],provider(i).country);
    %varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_city'],provider(i).city); % this is redundant to the netcdf file. 
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_affiliation'],provider(i).affiliation);
    varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_email'],provider(i).email);
    if isfield(provider,'parameter'); varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,['provider_',num2str(i),'_parameter'],[provider(i).parameter,site.species_list]); end
end

varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_name','Logan Mitchell');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_address1','Department of Atmospheric Sciences');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_address2','135 S. 1460 E. Rm. 819');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_address3','Salt Lake City, UT 84112');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_country','United States');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_affiliation','University of Utah');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'compilation_originator_email','Logan.Mitchell@utah.edu');

varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'id','Dataset_DOI_will_go_here_when_its_available');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'history',[...
    char(datetime('now', 'TimeZone', 'America/Denver', 'Format', 'yyyy-MM-dd HH:mm:SS Z')),' Mitchell Matlab ',version,' netcdf.create']);
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'cdm_data_type','timeSeries');
varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'Conventions','CF-1.7, ACDD-1.3');
%varid = netcdf.getConstant('GLOBAL'); netcdf.putAtt(n.ncid,varid,'name','description');

% n.idLatDim = netcdf.defDim(n.ncid,'lat',1);
% n.idLonDim = netcdf.defDim(n.ncid,'lon',1);
% n.idElevationDim = netcdf.defDim(n.ncid,'elevation',1);
% n.idInletHeightDim = netcdf.defDim(n.ncid,'inlet_height',1);

n.idTimeStringDim = netcdf.defDim(n.ncid,'time_string',20);

%for i = 1:length(site.groups)
grp = 1;
for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species) % Loops through all of the species
        sptxt = site.(site.codes{i}).species{sp};
        
        % The netCDF files are organized by species, so for example, it
        % compiles all of the CO2 data first, then all of the CH4 data
        % next. For each file the code loops through every site/species
        % combo in the sites structure. This test below skips all of the
        % site/species combo that do not belong to the species in the file.
        if ~strcmp(sptxt,species) % If the species isn't the one being compiled this time, continue onto the next site/species.
            continue
        end
        
        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            
            if ~isfield(site.(site.codes{i}),[sptxt,'_',intxt]) % There is no data for this site/species/inlet.
                continue
            end
            
            if strcmp(site.(site.codes{i}).name,'background')
                group_name = [site.(site.codes{i}).name,'_',sptxt]; % no inlet text for the background.
            else
                group_name = [site.(site.codes{i}).code,'_',sptxt,'_',intxt];
            end
            
            n.id_site_Grp(grp,1) = netcdf.defGrp(n.ncid,group_name); % Group folder
            
            n.id_time_Dim(grp,1) = netcdf.defDim(n.id_site_Grp(grp,1),'time',length(site.(site.codes{i}).([sptxt,'_',intxt,'_time']))); % Time dimension
            
            % Site specific attributes.
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_code',site.(site.codes{i}).code);
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_name',site.(site.codes{i}).long_name);
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_country',site.(site.codes{i}).country);
            if site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(end,1)==-1e34 % the background has fill values, so the format should be changed.
                fmt.lat = '%0.6g'; fmt.lon = '%0.6g'; fmt.elevation = '%0.6g'; fmt.inlet_height = '%0.6g';
            else
                fmt.lat = '%0.4f'; fmt.lon = '%0.4f'; fmt.elevation = '%0.1f'; fmt.inlet_height = '%0.1f';
            end                
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_latitude',num2str(site.(site.codes{i}).([sptxt,'_',intxt,'_lat'])(end,1),fmt.lat));
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_longitude',num2str(site.(site.codes{i}).([sptxt,'_',intxt,'_lon'])(end,1),fmt.lon));
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_elevation',num2str(site.(site.codes{i}).([sptxt,'_',intxt,'_elevation'])(end,1),fmt.elevation));
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_elevation_unit','masl');
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_inlet_height',num2str(site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height'])(end,1),fmt.inlet_height));
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_inlet_height_unit','magl');
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_position_comment',['This is the current location of the site. The sampling location may have changed over time ',...
                'so the sampling location for each observation are reported in the latitude, longitude, and altitude variables.']);
            t1 = datetime(2017,1,1,1,1,1,'TimeZone',site.(site.codes{i}).time_zone); [dt,dst] = tzoffset(t1);
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_utc2lst',num2str(hours(dt-dst))); clear('t1','dt','dst');
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'site_utc2lst_comment','Add site_utc2lst hours to convert a time stamp in UTC (Coordinated Universal Time) to LST (Local Standard Time).');
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'dataset_parameter',sptxt);
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'dataset_calibration_scale',site.(site.codes{i}).calibration_scale{sp});
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'dataset_start_date',datestr(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(1),'yyyy-mm-ddTHH:MM:SSZ'));
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'dataset_stop_date',datestr(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])(end),'yyyy-mm-ddTHH:MM:SSZ'));
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'dataset_data_frequency','1');
            netcdf.putAtt(n.id_site_Grp(grp,1),netcdf.getConstant('GLOBAL'),'dataset_data_frequency_unit','hour');
            
            n.id_POSIX_time(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'time','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_POSIX_time(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_POSIX_time(grp,1),'units','seconds since 1970-01-01T00:00:00Z');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_POSIX_time(grp,1),'long_name','sample_time_in_seconds_since_january_1_1970');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_POSIX_time(grp,1),'comment','POSIX time. Number of seconds since January 1, 1970 in UTC.');
            
            n.id_time_string(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'time_string','NC_CHAR',[n.id_time_Dim(grp,1),n.idTimeStringDim]);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_time_string(grp,1),'long_name','Sample date/time in ISO 8601 format (UTC).');
            
            n.id_obs(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),sptxt,'NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_obs(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_obs(grp,1),'units',site.(site.codes{i}).species_units{sp});
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_obs(grp,1),'standard_name',['mole_fraction_of_',site.(site.codes{i}).species_long_name{sp},'_in_dry_air']);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_obs(grp,1),'long_name',['Average of the ',sptxt,' mole fraction measurements (',site.(site.codes{i}).species_units_long_name{sp},') in the hour.']);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_obs(grp,1),'cell_method',[sptxt,': mean']);
            
            n.id_std(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'std_dev','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_std(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_std(grp,1),'units',site.(site.codes{i}).species_units{sp});
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_std(grp,1),'cell_method',[sptxt,': standard_deviation']);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_std(grp,1),'long_name',['Standard deviation of the ',sptxt,' mole fraction measurements (',site.(site.codes{i}).species_units_long_name{sp},') in the hour.']);
            
            n.id_n(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'n','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_n(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_n(grp,1),'units','count');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_n(grp,1),'long_name',['Number of the ',sptxt,' mole fraction measurements in the hour.']);
            
            n.id_unc(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'uncertainty','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_unc(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_unc(grp,1),'units',site.(site.codes{i}).species_units{sp});
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_unc(grp,1),'long_name','Measurement uncertainty determined by the data provider. See the Reference for more details.');
            
            n.id_lat(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'lat','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_lat(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_lat(grp,1),'units','degrees_north');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_lat(grp,1),'standard_name','latitude');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_lat(grp,1),'axis','Y');
            
            n.id_lon(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'lon','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_lon(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_lon(grp,1),'units','degrees_east');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_lon(grp,1),'standard_name','longitude');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_lon(grp,1),'axis','X');
            
            n.id_elevation(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'elevation','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_elevation(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_elevation(grp,1),'units','meters');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_elevation(grp,1),'long_name','Elevation above sea level at the station location.');
            
            n.id_inlet_height(grp,1) = netcdf.defVar(n.id_site_Grp(grp,1),'inlet_height','NC_DOUBLE',n.id_time_Dim(grp,1));
            netcdf.defVarFill(n.id_site_Grp(grp,1),n.id_inlet_height(grp,1),false,-1e34);
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_inlet_height(grp,1),'units','meters');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_inlet_height(grp,1),'long_name','Height of the sample inlet above ground level.');
            netcdf.putAtt(n.id_site_Grp(grp,1),n.id_inlet_height(grp,1),'axis','Z');
            
            grp = grp+1; % Advance to the next data group folder
        end
    end
end

% Takes the ncdf file out of define mode and into data entry mode.
netcdf.endDef(n.ncid);

grp = 1;
for i = 1:length(site.codes)
    for sp = 1:length(site.(site.codes{i}).species)
        sptxt = site.(site.codes{i}).species{sp};
        
        if ~strcmp(sptxt,species) % If the species isn't the one being compiled this time, continue onto the next site/species.
            continue
        end

        for inlet = 1:length(site.(site.codes{i}).inlet_height_long_name)
            intxt = site.(site.codes{i}).inlet_height_long_name{inlet};
            
            if ~isfield(site.(site.codes{i}),[sptxt,'_',intxt]) % There is no data for this site/species/inlet.
                continue
            end
            
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_POSIX_time(grp,1),posixtime(site.(site.codes{i}).([sptxt,'_',intxt,'_time'])));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_time_string(grp,1),datestr(site.(site.codes{i}).([sptxt,'_',intxt,'_time']),'yyyy-mm-ddTHH:MM:SSZ'));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_obs(grp,1),site.(site.codes{i}).([sptxt,'_',intxt]));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_std(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_std']));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_n(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_n']));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_unc(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_unc']));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_lat(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_lat']));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_lon(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_lon']));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_elevation(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_elevation']));
            netcdf.putVar(n.id_site_Grp(grp,1),n.id_inlet_height(grp,1),site.(site.codes{i}).([sptxt,'_',intxt,'_inlet_height']));
            grp = grp+1;
        end
    end
end

netcdf.close(n.ncid) % Close the netCDF

fn = dir(fnStr);
%ncdisp([fn.folder,'\',fn.name])


end


