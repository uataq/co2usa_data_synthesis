# CO2 Urban Synthesis and Analysis (CO2-USA) Data Synthesis
Urban greenhouse gas network measurements for cities in the CO2 Urban Synthesis and Analysis network.

More information about the CO2 Urban Synthesis and Analysis project can be found on our main project web page:

http://sites.bu.edu/co2usa/

This Git-Hub page contains the code that is being used to generate a harmonized CO2, CH4, and CO mixing ratio dataset that is readily useable, traceable, and accessible by the research community and the public.

<b>Data Fair Use Policy:

These cooperative data products are made freely available to the public and scientific community to advance the study of urban carbon cycling and associated air pollutants. Fair credit should be given to data producers and will depend on the nature of your work.  While this data is available under a CC0 license, responsible use includes properly citing the data.  When you start data analysis that may result in a publication, we recommend that you contact the data producers directly since they have primary knowledge of their data and any updates and, if it is appropriate, so they have the opportunity to contribute substantively to the analysis and become a co-author.  Data producers reserve the right to make corrections to the data based on scientific grounds (e.g. recalibration or operational issues). This dataset is made freely and openly available, with a goal that the results of work using this data also be made freely and openly available to the greatest extent possible.</b>


The CO2-USA synthesis data product can be downloaded from the Oak Ridge National Laboratory Distributed Active Archive Center (ORNL DAAC) here:
https://doi.org/10.3334/ORNLDAAC/1743

After downloading the data from the ORNL DAAC, you can use the code in this GitHub repository to load the entire CO2-USA synthesis data set quickly and easily.  The code has been written for the R, Python, and Matlab programming languages:

R: https://github.com/uataq/co2usa_data_synthesis/blob/master/co2usa_load_netCDF.r

Matlab: https://github.com/uataq/co2usa_data_synthesis/blob/master/co2usa_load_netCDF.m

Python: https://github.com/uataq/co2usa_data_synthesis/blob/master/co2usa_load_netCDF.py

The data files are in netCDF and text format.  NetCDF files can be viewed with the Panoply data viewer developed by NASA (https://www.giss.nasa.gov/tools/panoply/).  The text files are created from the netCDF files and therefore their content is identical.

Logan Mitchell gave a presentation about this Data Synthesis project at the CO2-USA workshop in Salt Lake City, UT on Oct 25, 2018.  It includes the scope of the project, many of the details about the data conventions used, and some initial cross-city data comparisons.  You can see a PDF of the presentation here:
https://github.com/uataq/co2usa_data_synthesis/blob/master/Mitchell_CO2-USA_2018_workshop_2_V1.pdf

If you would like more information, please contact Logan Mitchell (logan.mitchell@utah.edu).

Additional greenhouse gas measurement data can be found at:

1.) The NOAA ObsPack archive: https://www.esrl.noaa.gov/gmd/ccgg/obspack/

2.) The World Data Center for Greenhouse Gases: https://gaw.kishou.go.jp/

