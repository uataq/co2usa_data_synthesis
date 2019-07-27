clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    %'indianapolis'
    %'salt_lake_city'
    %'los_angeles'
    %'san_francisco_beacon'
    %'portland'
};

eval('co2usa_load_netCDF')

plt.save_all_figures = 'n';

% Uppercase city name:
city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));

site_utc2lst = str2double(d.(city).(d.(city).site_names{1,1}).Attributes(11).Value);

if isfield(d.(city),'background_co2')
    c.sp = d.(city).background_co2.Variables(3).Data;
    c.t = d.(city).background_co2.Variables(1).Data;
else
    fprintf('No background data.\n')
    d.(city).background_co2.Variables(1).Name = 'time';
    d.(city).background_co2.Variables(1).Data = [NaT,NaT];
    d.(city).background_co2.Variables(3).Name = 'co2';
    d.(city).background_co2.Variables(3).Data = [NaN,NaN];
    
    c.sp = d.(city).background_co2.Variables(3).Data;
    c.t = d.(city).background_co2.Variables(1).Data;
end

if length(c.t)>10 % If there is a background for this site, calculate a smoothed version of it.
    bgTh = thoningCurveFit([datenum(c.t),c.sp],4);
    c.th_t = datetime(bgTh.smooth(:,1),'ConvertFrom','datenum');
    c.th_sp = bgTh.smooth(:,2);
else % If not, skip it.
    c.th_t = c.t;
    c.th_sp = c.sp;
end


fn = dir(fullfile(readFolder,['co2usa_CT2017_background_',city,'.dat']));
fid = fopen(fullfile(fn.folder,fn.name));
stilt_bg_raw = textscan(fid,'%f,%f,%f,%f','HeaderLines',1,'CollectOutput',1);
fclose(fid);
foo_time = num2str(stilt_bg_raw{1,1}(:,1));
stilt_bg.dtUTC = datetime(str2double(cellstr(foo_time(:,1:4))),str2double(cellstr(foo_time(:,5:6))),str2double(cellstr(foo_time(:,7:8))),str2double(cellstr(foo_time(:,9:10))),zeros(size(foo_time,1),1),zeros(size(foo_time,1),1));
stilt_bg.co2 = stilt_bg_raw{1,1}(:,4);
clear('foo_time','stilt_bg_raw')

%%

%site_min_height_index = false(length(d.(city).site_names),1);
%site_min_height_index([1,4,7,11,12]

%% Load CT data:

%load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_lvl1.mat'))
%load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_lvl2.mat'))
load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_lvl3.mat'))
load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_lvl4.mat'))
%load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_lvl5.mat'))
%load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_lvl10.mat'))
load(fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','CarbonTracker','CT2017','CT2017_latlon.mat'))

% Location of city with CT
site = d.(city).site_names{1,1};
i_lat = strcmp({d.(city).(site).Attributes.Name},'site_latitude');
i_lon = strcmp({d.(city).(site).Attributes.Name},'site_longitude');

ctCityLat = find(ctLat>str2double(d.(city).(site).Attributes(i_lat).Value),1,'first')-1;
ctCityLon = find(ctLon>str2double(d.(city).(site).Attributes(i_lon).Value),1,'first')-1;



%% Thoning curve of CT level 4 (this seems to be the best level - determined by LM on 2018-12-01)
c.ct_sp = reshape(co2l3(ctCityLon,ctCityLat,:),size(tUTC,1),1);
c.ct_t = tUTC;
bgTh_ct = thoningCurveFit([datenum(c.ct_t),c.ct_sp],4);
c.ct_th_t = datetime(bgTh_ct.smooth(:,1),'ConvertFrom','datenum');
c.ct_th_sp = bgTh_ct.smooth(:,2);

%% Map of CT
figure(101);clf; set(gcf,'Color','w')
ax = usamap('conus'); setm(ax,'MapProjection','mercator'); set(ax, 'Visible', 'off')
latlim = getm(ax, 'MapLatLimit');lonlim = getm(ax, 'MapLonLimit');
states = shaperead('usastatehi','UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
cx = colorbar('Location','EastOutside','FontSize',8);
tightmap
surfm(ctLat,ctLon,squeeze(co2l3(:,:,1))')
%foo = squeeze(co2l1(:,:,1)); foo(ctCityLon,ctCityLat) = 450;
%surfm(ctLat,ctLon,foo')
geoshow(ax, states,'FaceColor',[1,1,1],'facealpha',0,'linewidth',1,'EdgeColor',[0 0 0])
set(get(cx,'ylabel'),'String', 'CO_2 (ppm)');

plotm(str2double(d.(city).(site).Attributes(i_lat).Value),str2double(d.(city).(site).Attributes(i_lon).Value),'r.','MarkerSize',20) % City location
textm(str2double(d.(city).(site).Attributes(i_lat).Value)+0.1,str2double(d.(city).(site).Attributes(i_lon).Value)+0.4,[upper(city(1)),city(2:end)])

%% Calculate lower percentile of all sites.

% Find overall city start/end date:

site = d.(city).site_names{1};
t_start = d.(city).(site).Variables(strcmp({d.(city).(site).Variables.Name},'time')).Data(1);
t_end = d.(city).(site).Variables(strcmp({d.(city).(site).Variables.Name},'time')).Data(end);

for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1}; if ~isempty(regexp(site,'background','once')); continue; end
    i_species = strcmp({d.(city).(site).Variables.Name},species); i_time = strcmp({d.(city).(site).Variables.Name},'time');
    t_start = min([t_start,d.(city).(site).Variables(i_time).Data(1)]);
    t_end = max([t_end,d.(city).(site).Variables(i_time).Data(end)]);
end

% Flat file of all of the sites in a city:
bg.dtUTC = (t_start:1/24:t_end)';
bg.co2_all = nan(length(bg.dtUTC),length(d.(city).site_names)-1);
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1}; if ~isempty(regexp(site,'background','once')); continue; end
    i_species = strcmp({d.(city).(site).Variables.Name},species); i_time = strcmp({d.(city).(site).Variables.Name},'time');
    [~,ia,ib] = intersect(datenum(bg.dtUTC),datenum(d.(city).(site).Variables(i_time).Data));
    bg.co2_all(ia,jj) = d.(city).(site).Variables(i_species).Data(ib);
end

%%
% Minimum value at every hour
bg.co2_min = nanmin(bg.co2_all,[],2);

% This limits the data to daytime hours only. Doing that gives essentially the same thing, but you have to increase the pct. 
%bg.co2_min(or(hour(bg.dtUTC+site_utc2lst/24)<12,hour(bg.dtUTC+site_utc2lst/24)>17)) = nan;

%[~,bg.co2_min_ind,~] = find(bg.co2_all==bg.co2_min); % This is the index indicating which site is being used as the min background site.
bg.co2_min_ind = bg.co2_all==bg.co2_min; % This is the index indicating which site is being used as the min background site.

%% Temp code for LA:
if strcmp(city,'los_angeles')
    [num,txt] = xlsread('C:\Users\logan_000\gcloud.utah.edu\data\co2-usa\data_input\los_angeles\LA_CO2_background_estimates_all_sites_forLogan_CO2USA_synthesis.xlsx');
    txt = txt(2:end,:);
    
    bgla.dtUTC = datetime(txt(:,1),'InputFormat','MM/dd/yyyy h:mm:ss a');
    bgla.vic = num(:,1);
    bgla.ljo = num(:,2);
    bgla.sci = num(:,3);
end

%% Calculate the running 5% of co2_min
bg.co2_pct = nan(size(bg.co2_min));
tic
pct = 50;
winDay = 7;
win = 24*winDay; dim = length(i-win:i+win)*size(bg.co2_all,2);
for i = win+1:length(bg.co2_pct)-win-1
    bg.co2_pct(i) = prctile(bg.co2_min(i-win:i+win),pct);
%    bg.co2_pct(i) = prctile(reshape(bg.co2_all(i-win:i+win,:),dim,1),10);
end
toc

% Comparison of various background calculations

site = 'background_co2';
i_species = strcmp({d.(city).(site).Variables.Name},species);
i_time = strcmp({d.(city).(site).Variables.Name},'time');

fx = figure(100); fx.Color = [1 1 1]; clf; hold on

%plot(tUTC,reshape(co2l1(ctCityLon,ctCityLat,:),size(tUTC,1),1),'c-')
%plot(tUTC,reshape(co2l2(ctCityLon,ctCityLat,:),size(tUTC,1),1),'g-')
%plot(tUTC,reshape(co2l4(ctCityLon,ctCityLat,:),size(tUTC,1),1),'c-')
plt.f100.ctl3 = plot(tUTC,reshape(co2l3(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[1,.6,.6]); 
%plot(tUTC,reshape(co2l5(ctCityLon,ctCityLat,:),size(tUTC,1),1),'c-')
%plot(tUTC,reshape(co2l10(ctCityLon,ctCityLat,:),size(tUTC,1),1),'y-')

plt.f100.city_bg = plot(d.(city).(site).Variables(i_time).Data,d.(city).(site).Variables(i_species).Data,'-','Color',[.5,.5,1],'LineWidth',1);
plt.f100.city_bg_th = plot(c.th_t,c.th_sp,'-','LineWidth',3,'Color',[0,0,.8]);
plt.f100.ct_th = plot(c.ct_th_t,c.ct_th_sp,'-','LineWidth',3,'Color',[.8,0,0]); % Thoning curve of CT lvl 4

plt.f100.stilt_bg = plot(stilt_bg.dtUTC,stilt_bg.co2,'k-','LineWidth',1,'MarkerSize',15);
stilt_bg.co2_sp = ppval(csaps(datenum(stilt_bg.dtUTC),stilt_bg.co2,0.0001),datenum(stilt_bg.dtUTC));
plt.f100.stilt_bg_sp = plot(stilt_bg.dtUTC,stilt_bg.co2_sp,'k-','LineWidth',3);

%plt.f100.bg_min = plot(bg.dtUTC,bg.co2_min,'c-','LineWidth',3);
plt.f100.bg_pct = plot(bg.dtUTC,bg.co2_pct,'g-','LineWidth',3);


plt.f100.l = [plt.f100.city_bg_th,plt.f100.ct_th,plt.f100.stilt_bg,plt.f100.stilt_bg_sp,plt.f100.bg_pct];
plt.f100.n = {[city_long_name ' bg'],'CT2017-lvl3','STILT','STILT-spline',[num2str(pct),'th% of ',num2str(winDay),'day city min']}; % Legend labels and names

% This shows which site has the hourly min value from the network.
% plt.marker_options = {'o','+','*','x','s','d','^','v','>','<','p'};
% for ind = 1:size(bg.co2_all,2); plt.f100.bg_pct_ID(ind) = plot(bg.dtUTC(bg.co2_min_ind(:,ind)),bg.co2_pct(bg.co2_min_ind(:,ind),1),plt.marker_options{rem(ind-1,length(plt.marker_options))+1},'LineWidth',2); end
% plt.f100.l = [plt.f100.l, plt.f100.bg_pct_ID];
% plt.f100.n = [plt.f100.n, replace(d.(city).site_names(1:size(bg.co2_all,2))','_',' ')];

% plt.f100.vic = plot(bgla.dtUTC,bgla.vic,'LineWidth',3);
% plt.f100.ljo = plot(bgla.dtUTC,bgla.ljo,'LineWidth',3);
% plt.f100.sci = plot(bgla.dtUTC,bgla.sci,'LineWidth',3);
% plt.f100.l = [plt.f100.l, plt.f100.vic,plt.f100.ljo,plt.f100.sci];
% plt.f100.n = [plt.f100.n, 'VIC','LJO','SCI'];

legend(plt.f100.l,plt.f100.n)
% legend([plt.f100.city_bg_th,plt.f100.ct_th,plt.f100.stilt_bg,plt.f100.stilt_bg_sp],...
%     [city_long_name ' bg'],'CarbonTracker','STILT','STILT-spline')

if strcmp(city,'indianapolis'); xlim([datetime(2010,7,1),datetime(2017,7,1)]); end
if strcmp(city,'boston'); xlim([datetime(2012,7,1),datetime(2017,7,1)]); end
xlim([datetime(2014,7,1),datetime(2017,7,1)])

set(gca,'FontSize',16,'FontWeight','bold')
title([city_long_name,' ',upper(species),' - Background comparison'],'FontSize',35,'FontWeight','Bold')
ylabel('CO_2 (ppm)'); hold off; grid on

plt.save_background_comparison = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_background_comparison,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_background_comparison_',species,'_',num2str(pct),'pct',num2str(winDay),'dayCityMin.jpg']),'-r300','-p0.01',fx)
    %export_fig(fullfile(readFolder,city,[city,'_img_background_comparison_',species,'_lvl_all.jpg']),'-r300','-p0.01',fx)
end


%%
fx = figure(102); fx.Color = [1 1 1]; clf
bar(categorical(replace(d.(city).site_names(1:size(bg.co2_all,2))','_',' ')),nansum(bg.co2_min_ind,1))
set(gca,'FontSize',16,'FontWeight','bold')
title(['Site contributions to the hourly min values at ',city_long_name],'FontSize',20)
ylabel('Count of hourly obs')
xtickangle(45)
plt.save_min_value_contribution = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_min_value_contribution,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_min_value_contribution_',species,'.jpg']),'-r300','-p0.01',fx)
end


%% Plot of CT levels
% fx = figure(500); fx.Color = [1 1 1]; clf; hold on
% plt.f500.ctl1 = plot(tUTC,reshape(co2l1(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[0.0000,0.4470,0.7410],'LineWidth',1);
% plt.f500.ctl2 = plot(tUTC,reshape(co2l2(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[0.8500,0.3250,0.0980],'LineWidth',1);
% plt.f500.ctl3 = plot(tUTC,reshape(co2l3(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[0.4940,0.1840,0.5560],'LineWidth',1); 
% plt.f500.ctl4 = plot(tUTC,reshape(co2l4(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[0.9290,0.6940,0.1250],'LineWidth',1);
% plt.f500.ctl5 = plot(tUTC,reshape(co2l5(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[0.4660,0.6740,0.1880],'LineWidth',1);
% plt.f500.ctl10 = plot(tUTC,reshape(co2l10(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[0.3010,0.7450,0.9330],'LineWidth',1);
% 
% plt.f500.bg_pct = plot(bg.dtUTC,bg.co2_pct,'g-','LineWidth',3);
% legend([plt.f500.ctl1,plt.f500.ctl2,plt.f500.ctl3,plt.f500.ctl4,plt.f500.ctl5,plt.f500.ctl10,plt.f500.bg_pct],'CT2017-lvl1','CT2017-lvl2','CT2017-lvl3','CT2017-lvl4','CT2017-lvl5','CT2017-lvl10',[num2str(pct),'th% of ',num2str(winDay),'day city min'])
% set(gca,'FontSize',16,'FontWeight','bold')
% title(['CT2017 comparison (',city_long_name,' ',upper(species),')'],'FontSize',35,'FontWeight','Bold')
% ylabel('CO_2 (ppm)'); hold off; grid on;xlim([datetime(2013,1,1),datetime(2017,1,1)])
% 
% plt.save_CT_levels_comparison = 'y';
% if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_CT_levels_comparison,'y'))
%     export_fig(fullfile(readFolder,city,[city,'_img_CT2017_comparison_',species,'_lvl_all.jpg']),'-r300','-p0.01',fx)
% end
% 

%% Plot of all sites & background:

fx = figure(1); fx.Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' - All sites'],'FontSize',35,'FontWeight','Bold')
for jj = 1:length(d.(city).site_names)
    %site = 'COM_co2_45m';
    site = d.(city).site_names{jj,1};
    i_species = strcmp({d.(city).(site).Variables.Name},species);
    i_time = strcmp({d.(city).(site).Variables.Name},'time');
    if ~isempty(regexp(site,'background','once'))
        plot(d.(city).(site).Variables(i_time).Data,d.(city).(site).Variables(i_species).Data,'k-','LineWidth',2)
    else
        plot(d.(city).(site).Variables(i_time).Data,d.(city).(site).Variables(i_species).Data)
    end
end
plot(c.th_t,c.th_sp,'b-','LineWidth',2)
plot(bg.dtUTC,bg.co2_pct,'g-','LineWidth',3);

% plt.f100.vic = plot(bgla.dtUTC,bgla.vic,'LineWidth',3);
% plt.f100.ljo = plot(bgla.dtUTC,bgla.ljo,'LineWidth',3);
% plt.f100.sci = plot(bgla.dtUTC,bgla.sci,'LineWidth',3);


%ax = gca; x_range = ax.XLim;
% plot(c.ct_th_t,c.ct_th_sp,'-','LineWidth',3,'Color',[.8,0,0]) % Thoning curve of CT lvl 4
% ax.XLim = x_range;
ylim([350,750])
if strcmp(city,'salt_lake_city'); xlim([datetime(2002,1,1),datetime(2018,1,1)]); end
if strcmp(city,'indianapolis'); xlim([datetime(2013,1,1),datetime(2019,1,1)]); end
hold off; grid on;ylabel([upper(species),' (ppm)']);
%legend([replace(d.(city).site_names,'_',' ');'bg smooth';'CT2017 lvl4 sm'],'Location','NorthWest')
legend([replace(d.(city).site_names,'_',' ');'bg smooth';[num2str(pct),'th% of ',num2str(winDay),'day city min']],'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
%datetick('x','yyyy','keepticks')

plt.save_overview_w_background = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_overview_w_background,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_overview_w_background_w_pct_',species,'.jpg']),'-r300','-p0.01',fx)
end


%% Calculate excess CO2

% Uses CT2017
% c.bg_t = c.ct_th_t;
% c.bg_sp = c.ct_th_sp;

% Uses the data derived background
c.bg_t = c.th_t;
c.bg_sp = c.th_sp;

if all(isnan(c.bg_sp)) % If there is no bg data, use the percent method background calculation.
    c.bg_t = bg.dtUTC;
    c.bg_sp = bg.co2_pct;
end


for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    i_species = strcmp({d.(city).(site).Variables.Name},species);
    i_time = strcmp({d.(city).(site).Variables.Name},'time');
    
    t = d.(city).(site).Variables(i_time).Data;
    data = d.(city).(site).Variables(i_species).Data;
    
    c.(site).data = data(and(t>c.bg_t(1),t<c.bg_t(end))); % trimming so that the data only covers the background.
    c.(site).t = t(and(t>c.bg_t(1),t<c.bg_t(end)));
    c.(site).excess = c.(site).data-interp1(datenum(c.bg_t),c.bg_sp,datenum(c.(site).t));
end

%%
fx = figure(2); fx.Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' excess - All sites'],'FontSize',35,'FontWeight','Bold')
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    plot(c.(site).t,c.(site).excess) % Excess CO2
end
%plot(c.th_t,c.th_sp,'b-','LineWidth',2)
hold off; grid on;ylabel([upper(species),' (ppm)']);
legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
if strcmp(city,'indianapolis'); xlim([datetime(2013,1,1),datetime(2017,1,1)]); end
datetick('x','yyyy','keepticks')
ylim([-50,300])
plt.save_overview_w_background = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_overview_w_background,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_overview_excess_',species,'.jpg']),'-r300','-p0.01',fx)
end

%% Diel averages

for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    c.(site).diel = nan(24,1);
    for hh = 1:24
        c.(site).diel(hh,1) = nanmean(c.(site).excess(hour(c.(site).t+site_utc2lst/24)==hh-1));
    end
end

%% Diel plot
fx = figure(3); fx.Color = [1 1 1]; clf; hold on
%title([city_long_name,' ',upper(species),' diel - All sites'],'FontSize',35,'FontWeight','Bold')
title([city_long_name,' ',upper(species),' diel - 10m sites'],'FontSize',35,'FontWeight','Bold')
plotted_cities = {};
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if str2double(d.(city).(site).Attributes(8).Value)>15; continue; end % only the 10m sites
    plotted_cities = [plotted_cities;site];
    plot((0:23)',c.(site).diel,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
hold off; grid on;
ylabel(['Excess ',upper(species),' (ppm)']); xlabel('Hour')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
if strcmp(city,'indianapolis'); ylim([-3,40]); end

plt.save_diel_excess = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_diel_excess,'y'))
%    export_fig(fullfile(readFolder,city,[city,'_img_diel_',species,'_excess.jpg']),'-r300','-p0.01',fx)
    export_fig(fullfile(readFolder,city,[city,'_img_diel_',species,'_excess_10m_sites.jpg']),'-r300','-p0.01',fx)
end


%% Seasonal excess
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    c.(site).monthly = nan(12,1);
    for mm = 1:12
        c.(site).monthly(mm,1) = nanmean(c.(site).excess(month(c.(site).t)==mm));
        c.(site).monthly_midafternoon(mm,1) = nanmean(c.(site).excess(and(month(c.(site).t)==mm,and(hour(c.(site).t+site_utc2lst/24)>11,hour(c.(site).t+site_utc2lst/24)<18))));
    end
end

%% Seasonal plot
fx = figure(4); fx.Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' excess monthly average - All sites'],'FontSize',35,'FontWeight','Bold')
plotted_cities = {};
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if any(isnan(c.(site).monthly)); continue; end
    plotted_cities = [plotted_cities;site];
    plot((1:12)',c.(site).monthly,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
ylabel(['Excess ',upper(species),' (ppm)']); xlabel('Month')
xlim([1,12])
hold off; grid on;
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

plt.save_monthly_excess = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_monthly_excess,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_monthly_',species,'_excess.jpg']),'-r300','-p0.01',fx)
end


%% Seasonal plot of mid-afternoon concentrations
fx = figure(5); fx.Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' excess monthly mid-afternoon (12-17 LST)'],'FontSize',35,'FontWeight','Bold')
plotted_cities = {};
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if any(isnan(c.(site).monthly_midafternoon)); continue; end
    plotted_cities = [plotted_cities;site];
    plot((1:12)',c.(site).monthly_midafternoon,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
ylabel(['Excess ',upper(species),' (ppm)']); xlabel('Month')
xlim([1,12])
hold off; grid on;
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
ylim([-5,40])
plt.save_monthly_midafternoon_excess = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_monthly_midafternoon_excess,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_monthly_midafternoon_',species,'_excess.jpg']),'-r300','-p0.01',fx)
end








