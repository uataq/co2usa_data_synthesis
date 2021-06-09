# -*- coding: utf-8 -*-
"""
co2usa_load_netCDF: Load the CO2-USA Data Synthesis files from netCDF

USAGE:

The CO2-USA synthesis data is available to download from the ORNL DAAC:
https://doi.org/10.3334/ORNLDAAC/1743

To download the data, first sign into your account (or create one if you don't have one). 
Next, click on "Download Data" to download the entire data set in a zip file. 
Extract the netCDF files to a folder on your computer.

The CO2-USA synthesis data files should be all saved in a single directory:
/co2_usa_netCDF_files/[netCDF_files.nc]

For example, for the CO2 data file for a Boston site would be:
/co2_usa_netCDF_files/boston_co2_HF_29m_1_hour_R0_2020-09-28.nc

Set the following variables:
city: String of CO2-USA city.  Example:
    city = 'boston'

species: String with target species. Example:
    species = 'co2'

read_folder: Path to the directory where you saved the data files. Example:
    current_folder = os.getcwd()
    read_folder = current_folder+'\\netCDF_formatted_files\\'

The data is in the 'co2usa' variable.

For more information, visit the CO2-USA GitHub repository:
https://github.com/loganemitchell/co2usa_data_synthesis

Written by Logan Mitchell (logan.mitchell@utah.edu)
University of Utah
Last updated: 2021-06-09

"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os
import glob
import netCDF4 as nc

#%% Executed this manually to enable interactive figures:
#%matplotlib qt

#%%

current_folder = os.getcwd()
read_folder = current_folder+'\\gcloud.utah.edu\\data\\co2-usa\\synthesis_output_ornl_new\\netCDF_formatted_files\\'

co2usa = {}

city = 'boston'
species = 'co2'
co2usa[city] = {}

all_files = glob.glob(read_folder+city+'_'+species+'*.nc')
    
for fni in range(len(all_files)):
    #print('Loading '+all_files[fni])
    nc_dat = nc.Dataset(all_files[fni])
    site = all_files[fni][len(read_folder):all_files[fni].find('_1_hour')]
    co2usa[city][site] = {}
    
    co2usa[city][site]['global_attributes'] = {} # Site global attributes
    for name in nc_dat.ncattrs():
        co2usa[city][site]['global_attributes'][name] = getattr(nc_dat, name)
        #print("Global attr {} = {}".format(name, getattr(nc_dat, name)))
        
    co2usa[city][site]['attributes'] = {} # Variable attributes
    for name in nc_dat.variables.keys():
        co2usa[city][site]['attributes'][name] = {}
        for attrname in nc_dat.variables[name].ncattrs():
            co2usa[city][site]['attributes'][name][attrname] = getattr(nc_dat.variables[name], attrname)
            #print("{} -- {}".format(attrname, getattr(nc_dat.variables[name], attrname)))
    
    for name in nc_dat.variables.keys(): # Variable data
        co2usa[city][site][name] = nc_dat.variables[name][:].data
    
    # Convert to datetime
    co2usa[city][site]['time'] = pd.to_datetime(co2usa[city][site]['time']*1e9)
    # Take care of NaNs
    co2usa[city][site][species][co2usa[city][site][species]==co2usa[city][site]['attributes'][species]['_FillValue']] = np.nan
    # Remove the temporary netCDF variable
    del nc_dat

#%% Plot the CO2 USA data

sites = co2usa[city].keys()

f1 = plt.figure(1); f1 = plt.clf(); ax = plt.axes(f1)
plt.title(city+' '+species,fontsize=20)
for site in sites:
    if site.find('background') == -1:
        plt.plot(co2usa[city][site]['time'],co2usa[city][site][species],label=site)
for site in sites:
    if site.find('background') != -1:
        plt.plot(co2usa[city][site]['time'],co2usa[city][site][species],'k-',label=site)
ax.set_ylabel(species,fontsize=15)
plt.legend(fontsize=14)
plt.grid(b=True,axis='both')






