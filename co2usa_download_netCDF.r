# Code to download the CO2-USA data synthesis from the ORNL DAAC:

read_folder = file.path('C:/Users','u0932260','gcloud.utah.edu','data','co2-usa','synthesis_output_ornl')
if (!dir.exists(read_folder)) mkdir(read_folder)
setwd(read_folder)
download_token = '<your_ORNL_download_token>' # PUT IN YOUR DOWNLOAD TOKEN ISSUED FROM ORNL
hyperlinks = readLines(paste('https://daac.ornl.gov/orders/',download_token,'/download_links.html',sep=''))
hyperlinks = hyperlinks[grep(pattern='<a href=".*?.nc">',hyperlinks)] # indices of the lines with valid hyperlinks
hyperlinks = gsub(pattern='<li><a href="',replacement='',hyperlinks)
hyperlinks = gsub(pattern='\">.*</li>',replacement='',hyperlinks)
for (i in 1:length(hyperlinks)) {
  filename = substr(hyperlinks[i],regexpr('/data/',hyperlinks[i])+6,nchar(hyperlinks[i]))
  print(paste('Downloading',filename))
  download.file(hyperlinks[i],file.path(read_folder,filename),mode='wb')
}
print('Done downloading data from the ORNL DAAC')
rm('download_token','hyperlinks','filename')
