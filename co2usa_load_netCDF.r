# Load the CO2-USA Data Synthesis files from netCDF
#
# USAGE:
#
# The CO2-USA data should be saved in a directory structure as follows:
# /synthesis_output/[city]/[netCDF_file.nc]
#
# For example, for the CO2 data file for Boston it would be:
# /synthesis_output/boston/boston_all_sites_co2_1_hour_R0_2019-07-09.nc
#
# Update the cities you want to extract, the species, and choose if you want to create plots.
# After running the script, the CO2_USA greenhouse gas data will all be contained within the
# 'co2_usa' list variable.
#
# For more information, visit the CO2-USA GitHub repository:
# https://github.com/loganemitchell/co2usa_data_synthesis
#
# Written by Logan Mitchell (logan.mitchell@utah.edu) and Ben Fasoli
# University of Utah
# Last updated: 2019-07-29

if (!'tidyverse' %in% installed.packages()) install.packages('tidyverse', repos='http://cran.us.r-project.org')
if (!'ncdf4' %in% installed.packages()) install.packages('ncdf4', repos='http://cran.us.r-project.org')
if (!'ggplot2' %in% installed.packages()) install.packages('ggplot2', repos='http://cran.us.r-project.org')
if (!'RColorBrewer' %in% installed.packages()) install.packages('RColorBrewer', repos='http://cran.us.r-project.org')
if (!'plotly' %in% installed.packages()) install.packages('plotly', repos='http://cran.us.r-project.org')
library(tidyverse)
library(ncdf4)
library(ggplot2)
library(RColorBrewer)
library(plotly)

# Clear the workspace
rm(list = ls())

######## Optional code to download the data from the ORNL DAAC:  ########

ornl_download = 'n'
if (ornl_download=='y') {
  read_folder = file.path('C:/Users','u0932260','gcloud.utah.edu','data','co2-usa','synthesis_output_ornl')
  if (!dir.exists(read_folder)) mkdir(read_folder)
  setwd(read_folder)
  download_token = 'your_ORNL_download_token' # PUT IN YOUR DOWNLOAD TOKEN ISSUED FROM ORNL
  hyperlinks = readLines(paste('https://daac.ornl.gov/orders/',download_token,'/download_links.html',sep=''))
  hyperlinks = hyperlinks[grep(pattern='<a href=".*?.nc">',hyperlinks)] # indices of the lines with valid hyperlinks
  hyperlinks = gsub(pattern='<li><a href="',replacement='',hyperlinks)
  hyperlinks = gsub(pattern='\">.*</li>',replacement='',hyperlinks)
  for (i in 1:length(hyperlinks)) {
    filename = substr(hyperlinks[i],regexpr('/data/',hyperlinks[i])+6,nchar(hyperlinks[i]))
    download.file(hyperlinks[i],file.path(read_folder,filename),mode='wb')
  }
  print('Done downloading data from the ORNL DAAC')
  rm('download_token','hyperlinks','filename')
}


######## Set the following options:  ########

# City options: 'boston', 'indianapolis', 'los_angeles', 'northeast_corridor', 'portland', 'salt_lake_city', 'san_francisco_baaqmd', 'san_francisco_beacon'
# Note: multiple cities may be selected.
cities = c('boston','los_angeles')

# Greenhouse gas species options: 'co2', 'ch4', or 'co'
species = 'co2'

# Produce figures for each city? The script runs faster if no figures are produced.
make_co2_usa_plots = 'y' # Options: 'y' or 'n'

# Choose the path to the location on your computer where the CO2-USA Synthesis data files have been saved, called the 'read_folder'.
# Within the 'read_folder' the data should be saved in subfolders as follows:
# /read_folder/[city]/netCDF_formatted_files/[city_species_site_inlet_netCDF_file.nc]
#
# For example, the CO2 measurements from the COP site in Boston would be:
# /read_folder/boston/netCDF_formatted_files/boston_co2_COP_215m_1_hour_R0_2019-07-09

read_folder = file.path('C:/Users','u0932260','gcloud.utah.edu','data','co2-usa','synthesis_output_ornl')
if (!dir.exists(read_folder)) stop('Cannot find the specified read folder. Check the file path to make sure it is correct.')
setwd(read_folder)

##############################################

# Create the data structures
co2_usa = list()
co2_usa_figures = list()

for (ii in 1:length(cities)) {
  city = cities[ii]
  
  # netCDF file name
#  file.path(read_folder,city,'netCDF_formatted_files')
  fn = list.files(path=file.path(read_folder),
                  pattern=paste(city,'_',species,'_','.*nc$',sep = ''),
                  include.dirs = TRUE)
  if (is_empty(fn)) {
    warning(paste('Looked for data files for ',city,' here:\n',
                  file.path(read_folder),
                  '\nHowever none were found. Either they do not exist or the path name is incorrect.\n',
                  'Check the path and file names. Skipping ',city,' data files for now.',sep=''))
    next()
  }
  
  # Data frame for all of the sites
  co2_usa[[city]][['all_sites']] = data.frame()
  
  for (jj in 1:length(fn)) {
    # Opens the netCDF file for reading
    info = nc_open(file.path(read_folder,fn[jj]))
    
    # site/inlet/species name
    site = substr(fn[jj],regexpr(species,fn[jj])+str_length(species)+1,regexpr('_1_hour',fn[jj])-1)
    
    # Global attributes for that site
    co2_usa[[city]][['Attributes']][[site]] = list('global' = ncatt_get(info,varid=0))

    # Extracting the time variable
    co2_usa[[city]][[site]] = data.frame(time = as.POSIXct(info$dim$time$vals, tz='UTC',origin = "1970-01-01 00:00.00"))
    
    # Extracting the variable Name, Data, and Attributes
    var_names = attributes(info$var)$names
    
    for (kk in 1:length(var_names)) {
      var_name = var_names[kk]
      
      # Variable Attributes
      co2_usa[[city]][['Attributes']][[site]][[var_name]] = ncatt_get(info,var_name)
      # Variable data
      co2_usa[[city]][[site]][var_name] = ncvar_get(info,var_name)
    }
    
    # Add the site_name data column to the data frame (to make plotting easier):
    co2_usa[[city]][[site]]['site_name'] = site
    
    # Bind all the sites together into a single data frame for easier plotting:
    co2_usa[[city]][['all_sites']] = bind_rows(co2_usa[[city]][['all_sites']],co2_usa[[city]][[site]])
  }

  if (make_co2_usa_plots=='y') {
    # Make a plot of all of the sites in the city:
    colourCount = length(unique(co2_usa[[city]][['all_sites']]$site_name))
    getPalette = colorRampPalette(brewer.pal(9, "Set1"))
    
    co2_usa_figures[[city]][['all_sites_fig']] = ggplot(data = co2_usa[[city]][['all_sites']], aes_string(x = 'time', y = species)) +
      geom_line(aes(color = site_name), alpha = 0.9) +
      scale_colour_manual(values = getPalette(colourCount)) +
      theme_classic() +
      labs(color = 'Site',
           title = city,
           x = '')
    print(ggplotly(co2_usa_figures[[city]][['all_sites_fig']]))
  }
}


