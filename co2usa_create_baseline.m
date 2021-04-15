clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

cities = {
    %'boston'
    %'indianapolis'
    %'northeast_corridor'
    'salt_lake_city'
    %'los_angeles'
    %'san_francisco_baaqmd'
    %'san_francisco_beacon'
    %'portland'
    %'toronto'
};

species_to_load = {'co2'};%,'ch4','co'};

currentFolder = pwd;
readFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_output','netCDF_formatted_files');
save_overview_image = 'n';
co2_usa = co2usa_load_netCDF(cities,species_to_load,readFolder,save_overview_image);

plt.save_all_figures = 'n';

for species_index = 1:length(species_to_load)
species = species_to_load{species_index};

for ii = 1:size(cities,1)
city = cities{ii,1};

% Uppercase city name:
city_long_name = replace(city,'_',' '); city_long_name([1,regexp(city_long_name,' ')+1]) = upper(city_long_name([1,regexp(city_long_name,' ')+1]));

site_codes = fieldnames(co2_usa.(city)); site_codes = site_codes(contains(site_codes,[species,'_']));

if isempty(site_codes); continue; end

% co2_usa.(city).site_codes{1,1} to site_codes{1}
% co2_usa.(city).site_codes{1} to site_codes{1}
% co2_usa.(city).site_codes to site_codes
% Variables(i_time).Data to time
% Variables(i_species).Data to (species)
% delete all i_time, i_species

site_utc2lst = str2double(co2_usa.(city).(site_codes{1}).global_attributes.site_utc2lst);

if strcmp(co2_usa.(city).(site_codes{1}).attributes.(species).units,'micromol mol-1')
    units_display_name = 'ppm';
elseif strcmp(co2_usa.(city).(site_codes{1}).attributes.(species).units,'nanomol mol-1')
    units_display_name = 'ppb';
end

writeFolder = fullfile(currentFolder(1:regexp(currentFolder,'gcloud.utah.edu')+14),'data','co2-usa','synthesis_analysis','baseline');

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
bg.dtUTC = (t_start:hours(1):t_end)';
bg.co2_all = nan(length(bg.dtUTC),length(site_codes));
for jj = 1:length(site_codes)
    site = site_codes{jj,1}; if ~isempty(regexp(site,'background','once')); continue; end
    [~,ia,ib] = intersect(datenum(bg.dtUTC),datenum(co2_usa.(city).(site).time));
    bg.co2_all(ia,jj) = co2_usa.(city).(site).(species)(ib);
end

bg.number_of_sites = sum(~isnan(bg.co2_all),2);


%% Data provider background (if it is available)

if isfield(co2_usa.(city),[species,'_background'])% any(strcmp(site_codes,[species,'_background']))% any(strcmp(city,{'indianapolis','boston','salt_lake_city','los_angeles'}))
    site = [species,'_background'];
    %i_time = strcmp({co2_usa.(city).(site).Variables.Name},'time');
    %i_species = strcmp({co2_usa.(city).(site).Variables.Name},species);
    [~,ia,ib] = intersect(co2_usa.(city).(site).time,bg.dtUTC);
    bg.co2_provider_background = nan(size(bg.dtUTC));
    bg.co2_provider_background(ib) = co2_usa.(city).(site).(species)(ia);
else
    bg.co2_provider_background = nan(size(bg.dtUTC));
end


%%
% Minimum value at every hour
bg.co2_min = nanmin(bg.co2_all,[],2);

% This limits the data to daytime hours only. Doing that gives essentially the same thing, but you have to increase the pct. 
%bg.co2_min(or(hour(bg.dtUTC+site_utc2lst/24)<12,hour(bg.dtUTC+site_utc2lst/24)>17)) = nan;

%[~,bg.co2_min_ind,~] = find(bg.co2_all==bg.co2_min); % This is the index indicating which site is being used as the min background site.
bg.co2_min_ind = bg.co2_all==bg.co2_min; % This is the index indicating which site is being used as the min background site.

% There are some hours without a min value, and some where multiple sites have the same min value. This finds the site names for each hour (picking the last site if a duplicate exists) 
bg.co2_min_site = cell(size(bg.co2_min,1),1);
for i = 1:length(site_codes)
    bg.co2_min_site(bg.co2_min_ind(:,i)) = site_codes(i);
end
bg.co2_min_site(cellfun(@isempty,bg.co2_min_site)) = {''};

% finds the column number (although I'm not using this)
% [icol,irow] = find(bg.co2_min_ind'); % Indices of the row (hours) & col (sites)
% [irow,iuni,~] = unique(irow); icol = icol(iuni); % Finds the unique rows (picking the first site for any place where there are duplicates)
% bg.co2_min_site_ind = nan(size(bg.co2_min));
% bg.co2_min_site_ind(any(bg.co2_min_ind,2)) = icol; % Assigning the site name index to each row with a min value.

% Find the daily min value (using LST to define the day)
bg.dtLST = bg.dtUTC+(site_utc2lst/24);
foo = timetable(bg.dtLST,bg.co2_min);
fmin = retime(foo,'daily','min'); % Finds the daily min
[~,ib] = ismember(dateshift(bg.dtLST,'start','day'),fmin.Time); % Indices to apply the daily min to every hour of the day.
bg.co2_daily_min = fmin.Var1(ib);
clear('foo','fmin')

%% Calculate the running percintile of co2_min
bg.co2_pct = nan(size(bg.co2_min));
tic

if strcmp(city,'boston'); pct = 55; winDay = 1; % determined on 2020-07-02
elseif strcmp(city,'indianapolis'); pct = 40; winDay = 0.25; % determined on 2020-07-02
elseif strcmp(city,'northeast_corridor'); pct = 30; winDay = .5; % determined on 2020-08-26
elseif strcmp(city,'salt_lake_city'); pct = 5; winDay = 3; % determined on 2020-07-02
%elseif strcmp(city,'salt_lake_city'); pct = 20; winDay = 3; % test
elseif strcmp(city,'los_angeles'); pct = 30; winDay = 3; % determined on 2020-08-26
elseif strcmp(city,'san_francisco_baaqmd'); pct = 20; winDay = 3; % determined on 2020-08-26
elseif strcmp(city,'san_francisco_beacon'); pct = 20; winDay = 3; % determined on 2020-08-26
elseif strcmp(city,'portland'); pct = 20; winDay = 3; % determined on 2020-08-26
elseif strcmp(city,'toronto'); pct = 20; winDay = 3; % determined on 2020-08-26
else; pct = 40; winDay = 0.5;
end

win = 24*winDay; dim = length(i-win:i+win)*size(bg.co2_all,2);
for i = win+1:length(bg.co2_pct)-win-1
    bg.co2_pct(i) = prctile(bg.co2_min(i-win:i+win),pct);
end
bg.co2_pct_str = [num2str(pct),'percentile-',num2str(winDay),'dayWindow'];
toc

% Plot of all sites & background:

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
plot(bg.dtUTC,bg.co2_pct,'g-','LineWidth',3);
plot(bg.dtUTC,bg.co2_daily_min,'-','Color',[.5,.5,.5],'LineWidth',1);

%ylim([350,750])
hold off; grid on;ylabel([upper(species),' (ppm)']);
legend([replace(site_codes,'_',' ');bg.co2_pct_str;'Daily min'],'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
%datetick('x','yyyy','keepticks')

plt.save_overview_w_background = 'n';
if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_overview_w_background,'y'))
    export_fig(fullfile(writeFolder,city,[city,'_img_overview_w_background_w_pct_',species,'.jpg']),'-r300','-p0.01',fx)
end




% Scatter plot of percentile background vs. city provided background

if isfield(co2_usa.(city),[species,'_background'])
    site = [species,'_background'];
    %i_time = strcmp({co2_usa.(city).(site).Variables.Name},'time');
    %i_species = strcmp({co2_usa.(city).(site).Variables.Name},species);
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
    %ylim([360,450])
    ylim([floor(nanmin([comp.x_all;comp.y_all])/10)*10, ceil(nanmax([comp.x_all;comp.y_all])/10)*10]);
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
        export_fig(fullfile(writeFolder,city,[city,'_img_percentile_comparison_',species,'_',bg.co2_pct_str,'.jpg']),'-r200','-p0.01',fx)
    end

    %% Comparison of various background calculations
    site = [species,'_background'];
    %i_species = strcmp({co2_usa.(city).(site).Variables.Name},species);
    %i_time = strcmp({co2_usa.(city).(site).Variables.Name},'time');
    fx = figure(100); fx.Color = [1 1 1]; clf; hold on
    plt.f100.city_bg = plot(co2_usa.(city).(site).time,co2_usa.(city).(site).(species),'-','Color',[.5,.5,1],'LineWidth',5);
    plt.f100.bg_pct = plot(bg.dtUTC,bg.co2_pct,'g-','LineWidth',3);
    plot(bg.dtUTC,bg.co2_provider_background,'r.-')
    set(gca,'FontSize',16,'FontWeight','bold')
    title([city_long_name,' ',upper(species),' - Background comparison'],'FontSize',35,'FontWeight','Bold')
    ylabel('CO_2 (ppm)'); hold off; grid on
    plt.save_background_comparison = 'n';
    if or(strcmp(plt.save_all_figures,'y'),strcmp(plt.save_background_comparison,'y'))
        export_fig(fullfile(writeFolder,city,[city,'_img_background_comparison_',species,'_',num2str(pct),'pct',num2str(winDay),'dayCityMin.jpg']),'-r300','-p0.01',fx)
        %export_fig(fullfile(writeFolder,city,[city,'_img_background_comparison_',species,'_lvl_all.jpg']),'-r300','-p0.01',fx)
    end
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
    export_fig(fullfile(writeFolder,city,[city,'_img_min_value_contribution_',species,'.jpg']),'-r300','-p0.01',fx)
end

%% Save data

plt.save_percentile_background = 'n';
if strcmp(plt.save_percentile_background,'y')
    fn = fullfile(writeFolder,['co2usa_baseline_',species,'_',city,'.xlsx']);
    fprintf('SAVING %s BASELINE FILE...',fn)
%     xlswrite(fullfile(writeFolder,city,[city,'_pct_bg_',num2str(pct),'percentile_',num2str(winDay),'dayWindow.xlsx']),...
%         [{'Time UTC','Year','Month','Day','Hour','Min','Sec','CO2 ppm (network minimum)',['CO2 ppm (',bg.co2_pct_str,')']};...
%         cellstr(datestr(bg.dtUTC,'yyyy-mm-dd HH:MM:ss +00:00')),num2cell([datevec(bg.dtUTC),bg.co2_min,bg.co2_pct])],['A1:I',num2str(length(bg.dtUTC)+1,'%0.0f')]);
    xlswrite(fn,...
        [{'Time UTC','Year','Month','Day','Hour','Min','Sec',...
        'Site name with hourly network minimum',...
        [species,' ',units_display_name,' (hourly network minimum)'],...
        [species,' ',units_display_name,' (',bg.co2_pct_str,')'],...
        [species,' ',units_display_name,' (daily network minimum)'],...
        [species,' ',units_display_name,' (provider background if available)'],...
        'number of measurement sites'};...
        cellstr(datestr(bg.dtUTC,'yyyy-mm-dd HH:MM:ss +00:00')),num2cell(datevec(bg.dtUTC)),cellstr(bg.co2_min_site),num2cell([bg.co2_min,bg.co2_pct,bg.co2_daily_min,bg.co2_provider_background,bg.number_of_sites])],['A1:M',num2str(length(bg.dtUTC)+1,'%0.0f')]);
    fprintf('Done.\n')
end


end
end