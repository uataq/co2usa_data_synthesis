# Load CO2-USA Data Synthesis files from netCDF
#
# Usage:
#
# The CO2-USA data should be saved in a directory structure as follows:
# /synthesis_output/[city]/[netCDF_file.nc]
#
# For example, for the CO2 data file for Boston it would be:
# /synthesis_output/boston/boston_all_sites_co2_1_hour_R0_2019-07-09.nc
#
# Update the cities you want to extract, the species, and choose if you want to create plots.
#
# Written by Logan Mitchell and Ben Fasoli
# Last updated: 2019-07-26

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

cities = c('san_francisco_beacon','indianapolis')#,'salt_lake_city')#,'boston') # options: 'boston', 'indianapolis', 'los_angeles', 'northeast_corridor', 'portland', 'salt_lake_city', 'san_francisco_baaqmd', 'san_francisco_beacon'
#cities = c('boston')

species = 'co2' # options: 'co2', 'ch4', or 'co'

# Produce figures for each city? The script runs faster if no figures are produced.
make_co2_usa_plots = 'y' # Options: 'y' or 'n'


#currentFolder = getwd()
readFolder = file.path('C:/Users','logan','gcloud.utah.edu','data','co2-usa','synthesis_output')
if (!dir.exists(readFolder)) stop('Cannot find the specified read folder. Check the file path to make sure it is correct.')
setwd(readFolder)

# Create the data structures
co2_usa = list()
co2_usa_figures = list()

for (ii in 1:length(cities)) {
  city = cities[ii]
  
  # netCDF file name
  fn = list.files(path=file.path(readFolder,city),
                  pattern=paste(city,'_all_sites_',species,'_','.*nc$',sep = ''),
                  include.dirs = TRUE)
  if (is_empty(fn)) {
    warning(paste('File for ',city,' doesnt exist. Check the path and file names. Skipping it for now.',sep=''))
    next()
  }
  
  # Opens the netCDF file for reading
  info = nc_open(file.path(readFolder,city,fn))
  
  # Global attributes for that city
  co2_usa[[city]][['Attributes']] = list('global' = ncatt_get(info,varid=0))
  
  # Data frame for all of the sites
  co2_usa[[city]][['all_sites']] = data.frame()
  
  for (jj in 1:length(info$groups)) {
    # If the group name is blank, skip it
    if (info$groups[[jj]]$name=="") next()
    
    # site/inlet/species name
    site = info$groups[[jj]]$name
    
    # Extracting the time variable
    co2_usa[[city]][[site]] = data.frame(time = as.POSIXct(info$dim[[paste(site,'/time',sep='')]]$vals, tz='UTC',origin = "1970-01-01 00:00.00"))
    
    # Extracting the variable Name, Data, and Attributes
    var_names = str_replace(attributes(info$var)$names[grep(site,attributes(info$var)$names)],paste(site,'/',sep=''),'')
    
    for (kk in 1:length(var_names)) {
      var_name = var_names[kk]
      
      # Variable Attributes
      co2_usa[[city]][['Attributes']][[site]][[var_name]] = ncatt_get(info,paste(site,'/',var_name,sep=''))
      # Variable data
      co2_usa[[city]][[site]][var_name] = ncvar_get(info,paste(site,'/',var_name,sep=''))
    }
    # Add the site name to the data frame:
    co2_usa[[city]][[site]]['site_name'] = site
    
    # Bind all the sites together into a single data frame for easier plotting:
    co2_usa[[city]][['all_sites']] = bind_rows(co2_usa[[city]][['all_sites']],co2_usa[[city]][[site]])
  }
  
  # Check to see if that city has a background:
  fn = list.files(path=file.path(readFolder,city),
                  pattern=paste(city,'_background_',species,'_','.*nc$',sep = ''),
                  include.dirs = TRUE)
  if (!is_empty(fn)) {
    # Opens the background netCDF file for reading
    info = nc_open(file.path(readFolder,city,fn))
    
    jj = 2
    # site/inlet/species name
    site = info$groups[[jj]]$name
    
    # Extracting the time variable
    co2_usa[[city]][[site]] = data.frame(time = as.POSIXct(info$dim[[paste(site,'/time',sep='')]]$vals, tz='UTC',origin = "1970-01-01 00:00.00"))
    
    # Extracting the variable Name, Data, and Attributes
    var_names = str_replace(attributes(info$var)$names[grep(site,attributes(info$var)$names)],paste(site,'/',sep=''),'')
    
    for (kk in 1:length(var_names)) {
      var_name = var_names[kk]
      
      # Variable Attributes
      co2_usa[[city]][['Attributes']][[site]][[var_name]] = ncatt_get(info,paste(site,'/',var_name,sep=''))
      # Variable data
      co2_usa[[city]][[site]][var_name] = ncvar_get(info,paste(site,'/',var_name,sep=''))
    }
    # Add the site name to the data frame:
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


