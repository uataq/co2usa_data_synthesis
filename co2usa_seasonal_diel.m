clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    'boston'
    'indianapolis'
    'northeast_corridor'
    'salt_lake_city'
    'los_angeles'
    'san_francisco_beacon'
    %'san_francisco_baaqmd'
    'portland'
    'toronto'
};

species_to_load = {'co2'
    'ch4'
    'co'
    };

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_new','netCDF_formatted_files');
%readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output_ornl_20191031'); % ORNL Archive
save_overview_image = 'n';
co2_usa = co2usa_load_netCDF(cities,species_to_load,readFolder,save_overview_image);

%%


species = 'co2';
city = 'salt_lake_city';
plt.save_all_figures = 'n';

% Uppercase city name:
city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));

site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));
site_utc2lst = str2double(co2_usa.(city).(site_codes{1}).global_attributes.site_utc2lst);

site = [species,'_background'];
if isfield(co2_usa.(city),site)
    c.sp = co2_usa.(city).(site).(species);
    c.t = co2_usa.(city).(site).time;
else
    fprintf('No background data.\n')
    co2_usa.(city).(site).time = [NaT,NaT];
    co2_usa.(city).(site).(species) = [NaN,NaN];
    
    c.sp = co2_usa.(city).(site).(species);
    c.t = co2_usa.(city).(site).time;
end

if length(c.t)>10 % If there is a background for this site, calculate a smoothed version of it.
    bgTh = thoningCurveFit([datenum(c.t),c.sp],4);
    c.th_t = datetime(bgTh.smooth(:,1),'ConvertFrom','datenum');
    c.th_sp = bgTh.smooth(:,2);
else % If not, skip it.
    c.th_t = c.t;
    c.th_sp = c.sp;
end

% Change the read folder to my working synthesis_output directory (other one is ORNL dir):
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');
writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output');

fn = dir(fullfile(readFolder,['co2usa_CT2017_background_',city,'.dat']));
if ~isempty(fn)
    stilt_bg.plot = 'y';
    fid = fopen(fullfile(fn.folder,fn.name));
    stilt_bg_raw = textscan(fid,'%f,%f,%f,%f','HeaderLines',1,'CollectOutput',1);
    fclose(fid);
    foo_time = num2str(stilt_bg_raw{1,1}(:,1));
    stilt_bg.dtUTC = datetime(str2double(cellstr(foo_time(:,1:4))),str2double(cellstr(foo_time(:,5:6))),str2double(cellstr(foo_time(:,7:8))),str2double(cellstr(foo_time(:,9:10))),zeros(size(foo_time,1),1),zeros(size(foo_time,1),1));
    stilt_bg.co2 = stilt_bg_raw{1,1}(:,4);
    clear('foo_time','stilt_bg_raw')
else
    stilt_bg.plot = 'n';
    stilt_bg.dtUTC = [NaT,NaT];
    stilt_bg.co2 = [NaN,NaN];
end

%%

%site_min_height_index = false(length(site_codes),1);
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
site = site_codes{1};

ctCityLat = find(ctLat>str2double(co2_usa.(city).(site).global_attributes.site_latitude),1,'first')-1;
ctCityLon = find(ctLon>str2double(co2_usa.(city).(site).global_attributes.site_longitude),1,'first')-1;



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

plotm(str2double(co2_usa.(city).(site).global_attributes.site_latitude),str2double(co2_usa.(city).(site).global_attributes.site_longitude),'r.','MarkerSize',20) % City location
textm(str2double(co2_usa.(city).(site).global_attributes.site_latitude)+0.1,str2double(co2_usa.(city).(site).global_attributes.site_longitude)+0.4,[upper(city(1)),city(2:end)])

%% Calculate lower percentile of all sites.

% Find overall city start/end date:

site = site_codes{1};
t_start = co2_usa.(city).(site).time(1);
t_end = co2_usa.(city).(site).time(end);

for jj = 1:length(site_codes)
    site = site_codes{jj,1}; if ~isempty(regexp(site,'background','once')); continue; end
    t_start = min([t_start,co2_usa.(city).(site).time(1)]);
    t_end = max([t_end,co2_usa.(city).(site).time(end)]);
end

% Flat file of all of the sites in a city:
bg.dtUTC = (t_start:1/24:t_end)';
bg.co2_all = nan(length(bg.dtUTC),length(site_codes));
for jj = 1:length(site_codes)
    site = site_codes{jj,1}; if ~isempty(regexp(site,'background','once')); continue; end
    [~,ia,ib] = intersect(datenum(bg.dtUTC),datenum(co2_usa.(city).(site).time));
    bg.co2_all(ia,jj) = co2_usa.(city).(site).(species)(ib);
end


%%
% Minimum value at every hour
bg.co2_min = nanmin(bg.co2_all,[],2);

% This limits the data to daytime hours only. Doing that gives essentially the same thing, but you have to increase the pct. 
%bg.co2_min(or(hour(bg.dtUTC+site_utc2lst/24)<12,hour(bg.dtUTC+site_utc2lst/24)>17)) = nan;

%[~,bg.co2_min_ind,~] = find(bg.co2_all==bg.co2_min); % This is the index indicating which site is being used as the min background site.
bg.co2_min_ind = bg.co2_all==bg.co2_min; % This is the index indicating which site is being used as the min background site.

%% Temp code for LA:
% if strcmp(city,'los_angeles')
%     [num,txt] = xlsread('C:\Users\logan_000\gcloud.utah.edu\data\co2-usa\data_input\los_angeles\LA_CO2_background_estimates_all_sites_forLogan_CO2USA_synthesis.xlsx');
%     txt = txt(2:end,:);
%     
%     bgla.dtUTC = datetime(txt(:,1),'InputFormat','MM/dd/yyyy h:mm:ss a');
%     bgla.vic = num(:,1);
%     bgla.ljo = num(:,2);
%     bgla.sci = num(:,3);
% end

%% Calculate the running 5% of co2_min
bg.co2_pct = nan(size(bg.co2_min));
tic

if strcmp(city,'indianapolis'); pct = 40; winDay = 0.25; % determined on 2020-07-02
elseif strcmp(city,'boston'); pct = 55; winDay = 1; % determined on 2020-07-02
elseif strcmp(city,'salt_lake_city'); pct = 5; winDay = 3; % determined on 2020-07-02
else; pct = 50; winDay = 7;
end

win = 24*winDay; dim = length(i-win:i+win)*size(bg.co2_all,2);
for i = win+1:length(bg.co2_pct)-win-1
    bg.co2_pct(i) = prctile(bg.co2_min(i-win:i+win),pct);
end
bg.co2_pct_str = [num2str(pct),'percentile-',num2str(winDay),'dayWindow'];
plt.save_percentile_background = 'n';
if strcmp(plt.save_percentile_background,'y')
    xlswrite(fullfile(writeFolder,city,[city,'_pct_bg_',num2str(pct),'percentile_',num2str(winDay),'dayWindow.xlsx']),...
        [{'Time UTC','Year','Month','Day','Hour','Min','Sec','CO2 ppm (network minimum)',['CO2 ppm (',bg.co2_pct_str,')']};...
        cellstr(datestr(bg.dtUTC,'yyyy-mm-dd HH:MM:ss +00:00')),num2cell([datevec(bg.dtUTC),bg.co2_min,bg.co2_pct])],['A1:I',num2str(length(bg.dtUTC)+1,'%0.0f')]);
end
toc

% Scatter plot of percentile background vs. city provided background

if any(strcmp(city,{'indianapolis','boston','salt_lake_city','los_angeles'}))
    site = 'co2_background';
    [~,ix.all,iy.all] = intersect(co2_usa.(city).(site).time,bg.dtUTC);
    
    comp.months = [3,5;
        6,8;
        9,11;
        12,2];
    
    comp.x_all = co2_usa.(city).(site).(species)(ix.all);
    comp.x_sp = comp.x_all(and(month(co2_usa.(city).(site).time(ix.all))>=comp.months(1,1),month(co2_usa.(city).(site).time(ix.all))<=comp.months(1,2)));
    comp.x_su = comp.x_all(and(month(co2_usa.(city).(site).time(ix.all))>=comp.months(2,1),month(co2_usa.(city).(site).time(ix.all))<=comp.months(2,2)));
    comp.x_fa = comp.x_all(and(month(co2_usa.(city).(site).time(ix.all))>=comp.months(3,1),month(co2_usa.(city).(site).time(ix.all))<=comp.months(3,2)));
    comp.x_wi = comp.x_all(or(month(co2_usa.(city).(site).time(ix.all))>=comp.months(4,1),month(co2_usa.(city).(site).time(ix.all))<=comp.months(4,2)));

    comp.y_all = bg.co2_pct(iy.all);
    comp.y_sp = comp.y_all(and(month(bg.dtUTC(iy.all))>=comp.months(1,1),month(bg.dtUTC(iy.all))<=comp.months(1,2)));
    comp.y_su = comp.y_all(and(month(bg.dtUTC(iy.all))>=comp.months(2,1),month(bg.dtUTC(iy.all))<=comp.months(2,2)));
    comp.y_fa = comp.y_all(and(month(bg.dtUTC(iy.all))>=comp.months(3,1),month(bg.dtUTC(iy.all))<=comp.months(3,2)));
    comp.y_wi = comp.y_all(or(month(bg.dtUTC(iy.all))>=comp.months(4,1),month(bg.dtUTC(iy.all))<=comp.months(4,2)));
    
    [comp.b_all,~,~,~,comp.stats_all] = regress(comp.y_all,[ones(size(comp.x_all)),comp.x_all]); % regression
    [comp.b_sp,~,~,~,comp.stats_sp] = regress(comp.y_sp,[ones(size(comp.x_sp)),comp.x_sp]);
    [comp.b_su,~,~,~,comp.stats_su] = regress(comp.y_su,[ones(size(comp.x_su)),comp.x_su]);
    [comp.b_fa,~,~,~,comp.stats_fa] = regress(comp.y_fa,[ones(size(comp.x_fa)),comp.x_fa]);
    [comp.b_wi,~,~,~,comp.stats_wi] = regress(comp.y_wi,[ones(size(comp.x_wi)),comp.x_wi]);

    fx = figure(50); fx.Color = [1 1 1]; clf; hold on
    plt.f50.ool = plot([370,450],[370,450],'-','LineWidth',3,'Color',[.5,.5,.5]);
    plt.f50.all = plot(comp.x_all,comp.y_all,'k.');
    plt.f50.sp = plot(comp.x_sp,comp.y_sp,'.','MarkerSize',15);
    plt.f50.su = plot(comp.x_su,comp.y_su,'.','MarkerSize',15);
    plt.f50.fa = plot(comp.x_fa,comp.y_fa,'.','MarkerSize',15);
    plt.f50.wi = plot(comp.x_wi,comp.y_wi,'.','MarkerSize',15);
    ylim([360,450])
    ax = gca;
    text((ax.XLim(2)-ax.XLim(1))*.01+ax.XLim(1),(ax.YLim(2)-ax.YLim(1))*(.98)+ax.YLim(1),'1:1 line','FontWeight','bold','FontSize',13,'Color',plt.f50.ool.Color);
    text((ax.XLim(2)-ax.XLim(1))*.01+ax.XLim(1),(ax.YLim(2)-ax.YLim(1))*(.95)+ax.YLim(1),['All: ',blanks(11),'y = ',num2str(comp.b_all(2),'%5.3f'),'x',num2str(comp.b_all(1),'%+4.1f'),' R^2=',num2str(comp.stats_all(1),'%0.3f'),'. Mean abs diff: ',num2str(nanmean(abs(comp.x_all-comp.y_all)),'%0.1f'),'ppm'],'FontWeight','bold','FontSize',13,'Color',plt.f50.all.Color);
    text((ax.XLim(2)-ax.XLim(1))*.01+ax.XLim(1),(ax.YLim(2)-ax.YLim(1))*(.92)+ax.YLim(1),['Spring: ',blanks(4),'y = ',num2str(comp.b_sp(2),'%5.3f'),'x',num2str(comp.b_sp(1),'%+4.1f'),' R^2=',num2str(comp.stats_sp(1),'%0.3f'),'. Mean abs diff: ',num2str(nanmean(abs(comp.x_sp-comp.y_sp)),'%0.1f'),'ppm'],'FontWeight','bold','FontSize',13,'Color',plt.f50.sp.Color);
    text((ax.XLim(2)-ax.XLim(1))*.01+ax.XLim(1),(ax.YLim(2)-ax.YLim(1))*(.89)+ax.YLim(1),['Summer: ',blanks(1),'y = ',num2str(comp.b_su(2),'%5.3f'),'x',num2str(comp.b_su(1),'%+4.1f'),' R^2=',num2str(comp.stats_su(1),'%0.3f'),'. Mean abs diff: ',num2str(nanmean(abs(comp.x_su-comp.y_su)),'%0.1f'),'ppm'],'FontWeight','bold','FontSize',13,'Color',plt.f50.su.Color);
    text((ax.XLim(2)-ax.XLim(1))*.01+ax.XLim(1),(ax.YLim(2)-ax.YLim(1))*(.86)+ax.YLim(1),['Fall: ',blanks(9),'y = ',num2str(comp.b_fa(2),'%5.3f'),'x',num2str(comp.b_fa(1),'%+4.1f'),' R^2=',num2str(comp.stats_fa(1),'%0.3f'),'. Mean abs diff: ',num2str(nanmean(abs(comp.x_fa-comp.y_fa)),'%0.1f'),'ppm'],'FontWeight','bold','FontSize',13,'Color',plt.f50.fa.Color);
    text((ax.XLim(2)-ax.XLim(1))*.01+ax.XLim(1),(ax.YLim(2)-ax.YLim(1))*(.83)+ax.YLim(1),['Winter: ',blanks(4),'y = ',num2str(comp.b_wi(2),'%5.3f'),'x',num2str(comp.b_wi(1),'%+4.1f'),' R^2=',num2str(comp.stats_wi(1),'%0.3f'),'. Mean abs diff: ',num2str(nanmean(abs(comp.x_wi-comp.y_wi)),'%0.1f'),'ppm'],'FontWeight','bold','FontSize',13,'Color',plt.f50.wi.Color);
    ln = lsline;
    for j = 1:length(ln); ln(j).LineWidth = 2; end
    grid on
    title('Percentile background comparison')
    xlabel([replace(city,'_',' '),' provided background'])
    ylabel(['Percentile background (',bg.co2_pct_str,')'])
    axis equal
    ax.FontWeight = 'Bold'; ax.FontSize = 14;
    
    plt.save_percentile_comparison = 'n';
    if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_percentile_comparison,'y'))
        export_fig(fullfile(readFolder,city,[city,'_img_percentile_comparison_',species,'_',bg.co2_pct_str,'.jpg']),'-r200','-p0.01',fx)
    end
end


%% Comparison of various background calculations

site = 'co2_background';

fx = figure(100); fx.Color = [1 1 1]; clf; hold on

%plot(tUTC,reshape(co2l1(ctCityLon,ctCityLat,:),size(tUTC,1),1),'c-')
%plot(tUTC,reshape(co2l2(ctCityLon,ctCityLat,:),size(tUTC,1),1),'g-')
%plot(tUTC,reshape(co2l4(ctCityLon,ctCityLat,:),size(tUTC,1),1),'c-')
plt.f100.ctl3 = plot(tUTC,reshape(co2l3(ctCityLon,ctCityLat,:),size(tUTC,1),1),'-','Color',[1,.6,.6]); 
%plot(tUTC,reshape(co2l5(ctCityLon,ctCityLat,:),size(tUTC,1),1),'c-')
%plot(tUTC,reshape(co2l10(ctCityLon,ctCityLat,:),size(tUTC,1),1),'y-')

plt.f100.city_bg = plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species),'-','Color',[.5,.5,1],'LineWidth',1);
plt.f100.city_bg_th = plot(c.th_t,c.th_sp,'-','LineWidth',3,'Color',[0,0,.8]);
plt.f100.ct_th = plot(c.ct_th_t,c.ct_th_sp,'-','LineWidth',3,'Color',[.8,0,0]); % Thoning curve of CT lvl 4

if strcmp(stilt_bg.plot,'y')
    plt.f100.stilt_bg = plot(stilt_bg.dtUTC,stilt_bg.co2,'k-','LineWidth',1,'MarkerSize',15);
    stilt_bg.co2_sp = ppval(csaps(datenum(stilt_bg.dtUTC),stilt_bg.co2,0.0001),datenum(stilt_bg.dtUTC));
    plt.f100.stilt_bg_sp = plot(stilt_bg.dtUTC,stilt_bg.co2_sp,'k-','LineWidth',3);
end
%plt.f100.bg_min = plot(bg.dtUTC,bg.co2_min,'c-','LineWidth',3);
plt.f100.bg_pct = plot(bg.dtUTC,bg.co2_pct,'g-','LineWidth',3);

% plt.f100.l = [plt.f100.city_bg_th,plt.f100.ct_th,plt.f100.stilt_bg,plt.f100.stilt_bg_sp,plt.f100.bg_pct];
% plt.f100.n = {[city_long_name ' bg'],'CT2017-lvl3','STILT','STILT-spline',[num2str(pct),'th% of ',num2str(winDay),'day city min']}; % Legend labels and names

plt.f100.l = [plt.f100.city_bg_th,plt.f100.ct_th,plt.f100.bg_pct];
plt.f100.n = {[city_long_name ' bg'],'CT2017-lvl3',[num2str(pct),'th% of ',num2str(winDay),'day city min']}; % Legend labels and names

% This shows which site has the hourly min value from the network.
% plt.marker_options = {'o','+','*','x','s','d','^','v','>','<','p'};
% for ind = 1:size(bg.co2_all,2); plt.f100.bg_pct_ID(ind) = plot(bg.dtUTC(bg.co2_min_ind(:,ind)),bg.co2_pct(bg.co2_min_ind(:,ind),1),plt.marker_options{rem(ind-1,length(plt.marker_options))+1},'LineWidth',2); end
% plt.f100.l = [plt.f100.l, plt.f100.bg_pct_ID];
% plt.f100.n = [plt.f100.n, replace(site_codes(1:size(bg.co2_all,2))','_',' ')];

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
%xlim([datetime(2014,7,1),datetime(2017,7,1)])

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
bar(categorical(replace(site_codes(1:size(bg.co2_all,2))','_',' ')),nansum(bg.co2_min_ind,1))
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
for jj = 1:length(site_codes)
    %site = 'COM_co2_45m';
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once'))
        plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species),'k-','LineWidth',2)
    else
        plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species))
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
%if strcmp(city,'salt_lake_city'); xlim([datetime(2002,1,1),datetime(2018,1,1)]); end
%if strcmp(city,'indianapolis'); xlim([datetime(2013,1,1),datetime(2019,1,1)]); end
hold off; grid on;ylabel([upper(species),' (ppm)']);
%legend([replace(site_codes,'_',' ');'bg smooth';'CT2017 lvl4 sm'],'Location','NorthWest')
legend([replace(site_codes,'_',' ');'bg smooth';[num2str(pct),'th% of ',num2str(winDay),'day city min']],'Location','NorthWest')
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


for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    
    t = co2_usa.(city).(site).time;
    data = co2_usa.(city).(site).(species);
    
    c.(site).data = data(and(t>c.bg_t(1),t<c.bg_t(end))); % trimming so that the data only covers the background.
    c.(site).t = t(and(t>c.bg_t(1),t<c.bg_t(end)));
    c.(site).excess = c.(site).data-interp1(datenum(c.bg_t),c.bg_sp,datenum(c.(site).t));
end

%%
fx = figure(2); fx.Color = [1 1 1]; clf; hold on
title([city_long_name,' ',upper(species),' excess - All sites'],'FontSize',35,'FontWeight','Bold')
for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    plot(c.(site).t,c.(site).excess) % Excess CO2
end
%plot(c.th_t,c.th_sp,'b-','LineWidth',2)
hold off; grid on;ylabel([upper(species),' (ppm)']);
legend(replace(site_codes,'_',' '),'Location','NorthWest')
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

for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    c.(site).diel = nan(24,1);
    for hh = 1:24
        c.(site).diel(hh,1) = nanmean(c.(site).excess(hour(c.(site).t+site_utc2lst/24)==hh-1));
    end
end

%% Diel plot (with option to subselect for an inlet max height)
fx = figure(3); fx.Color = [1 1 1]; clf; hold on

% SET THIS PARAMETER:
inlet_max_height = nan; % max inlet height to include. Set to nan for all sites.

if isnan(inlet_max_height)
    title([city_long_name,' ',upper(species),' diel - All sites'],'FontSize',35,'FontWeight','Bold')
else
    title([city_long_name,' ',upper(species),' diel - <',num2str(inlet_max_height),'m sites'],'FontSize',35,'FontWeight','Bold')
end
plotted_cities = {};
for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if str2double(co2_usa.(city).(site).global_attributes.site_inlet_height)>inlet_max_height; continue; end % only the 10m sites
    plotted_cities = [plotted_cities;site];
    plot((0:23)',c.(site).diel,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
hold off; grid on;
ylabel(['Excess ',upper(species),' (ppm)']); xlabel('Hour')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(site_codes,'_',' '),'Location','NorthWest')
if strcmp(city,'indianapolis'); ylim([-3,40]); end

plt.save_diel_excess = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_diel_excess,'y'))
    if isnan(inlet_max_height)
        export_fig(fullfile(readFolder,city,[city,'_img_diel_',species,'_excess.jpg']),'-r300','-p0.01',fx)
    else
        export_fig(fullfile(readFolder,city,[city,'_img_diel_',species,'_excess_',num2str(inlet_max_height),'m_sites.jpg']),'-r300','-p0.01',fx)
    end
end


%% Seasonal excess
for jj = 1:length(site_codes)
    site = site_codes{jj,1};
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
for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if any(isnan(c.(site).monthly)); continue; end
    plotted_cities = [plotted_cities;site];
    plot((1:12)',c.(site).monthly,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
ylabel(['Excess ',upper(species),' (ppm)']); xlabel('Month')
xlim([1,12])
hold off; grid on;
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(site_codes,'_',' '),'Location','NorthWest')
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
for jj = 1:length(site_codes)
    site = site_codes{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if any(isnan(c.(site).monthly_midafternoon)); continue; end
    plotted_cities = [plotted_cities;site];
    plot((1:12)',c.(site).monthly_midafternoon,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
ylabel(['Excess ',upper(species),' (ppm)']); xlabel('Month')
xlim([1,12])
hold off; grid on;
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(site_codes,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
ylim([-5,40])
plt.save_monthly_midafternoon_excess = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_monthly_midafternoon_excess,'y'))
    export_fig(fullfile(readFolder,city,[city,'_img_monthly_midafternoon_',species,'_excess.jpg']),'-r300','-p0.01',fx)
end








