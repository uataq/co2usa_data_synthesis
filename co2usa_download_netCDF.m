% Code to automate the download of CO2-USA Synthesis netCDF data from the ORNL DAAC:
%
% Step 1: Visit the CO2-USA archive on the ORNL DAAC:
% https://doi.org/10.3334/ORNLDAAC/1743
% 
% Step 2: Sign into your account (or create one if you don't have one) 
%
% Step 3: Click on "Download Data" to download the entire data set in a zip file. 
%
% If you want to download part of the data set, follow these optional steps:
%
% Step 4: Select the data files you want to download, put them in your
% cart, and select "Order These Items" from your cart.
%
% Step 5: The ORNL DAAC will send you an email with a location where you can
% download the data.  They give you several options to download the data,
% and the following code is one additional option for you to download the
% data.
% 
% Step 6: Copy your download token in the email from the ORNL DAAC and past it below:
% For example: 'aun26r81235cr3h4c3v9y1g32t22646g'
download_token = '<your_ORNL_download_token>';

% Step 7: Choose the location on your computer to save the data:
download_location = fullfile('C:/Users','u0932260','gcloud.utah.edu','data','co2-usa','synthesis_output_ornl');
if ~isfolder(download_location); mkdir(download_location); end

% Step 8: The rest of the code will download the data for you:
hyperlinks = webread(['https://daac.ornl.gov/orders/',download_token,'/download_links.html']);
hyperlinks = regexp(hyperlinks,'<a href=".*?.nc">','match'); 
hyperlinks = replace(hyperlinks,{'<a href="','">'},'');
for i = 1:length(hyperlinks)
    filename = extractAfter(hyperlinks{i},'/data/');
    fprintf('Downloading %s...\n',filename)
    outfilename = websave(fullfile(download_location,filename),hyperlinks{i});
end
fprintf('Done downloading the CO2-USA synthesis data from the ORNL DAAC\n')
clear('download_location','download_token','hyperlinks','filename')
