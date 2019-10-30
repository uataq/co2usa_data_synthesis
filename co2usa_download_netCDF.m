% Code to automate the download of CO2-USA Synthesis data from the ORNL:

download_location = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl');
if ~isfolder(download_location); mkdir(download_location); end
download_token = '<your_ORNL_download_token>'; % PUT IN YOUR DOWNLOAD TOKEN ISSUED FROM ORNL
hyperlinks = webread(['https://daac.ornl.gov/orders/',download_token,'/download_links.html']);
hyperlinks = regexp(hyperlinks,'<a href=".*?.nc">','match'); hyperlinks = replace(hyperlinks,{'<a href="','">'},'');
for i = 1:length(hyperlinks)
    filename = extractAfter(hyperlinks{i},'/data/');
    outfilename = websave(fullfile(download_location,filename),hyperlinks{i});
end
fprintf('Done downloading data from the ORNL DAAC\n')
clear('download_location','download_token','str','hyperlinks','filename')
