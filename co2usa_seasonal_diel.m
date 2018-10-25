clear all
close all
set(0,'DefaultFigureWindowStyle','docked')

eval('co2usa_load_netCDF')


c.sp = d.(city).background_co2.Variables(3).Data;
c.t = d.(city).background_co2.Variables(1).Data;

bgTh = thoningCurveFit([datenum(c.t),c.sp],4);

c.th_t = datetime(bgTh.smooth(:,1),'ConvertFrom','datenum');
c.th_sp = bgTh.smooth(:,2);

%%

%site_min_height_index = false(length(d.(city).site_names),1);
%site_min_height_index([1,4,7,11,12]



%%
fx = figure(1); fx.Color = [1 1 1]; clf; hold on
title([replace(city,'_',' '),' ',upper(species),' - All sites'],'FontSize',35,'FontWeight','Bold')
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
hold off; grid on;ylabel(upper(species));
legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

plt.save_overview_w_background = 'y';
if strcmp(plt.save_overview_w_background,'y')
    export_fig(fullfile(readFolder,city,[city,'_img_overview_w_background_',species,'.jpg']),'-r300','-p0.01',fx)
end


%%

fx = figure(2); fx.Color = [1 1 1]; clf; hold on
title([replace(city,'_',' '),' ',upper(species),' excess - All sites'],'FontSize',35,'FontWeight','Bold')
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    i_species = strcmp({d.(city).(site).Variables.Name},species);
    i_time = strcmp({d.(city).(site).Variables.Name},'time');
    
    t = d.(city).(site).Variables(i_time).Data;
    data = d.(city).(site).Variables(i_species).Data;
    
    c.(site).data = data(and(t>c.th_t(1),t<c.th_t(end))); % trimming so that the data only covers the background.
    c.(site).t = t(and(t>c.th_t(1),t<c.th_t(end)));
    c.(site).excess = c.(site).data-interp1(datenum(c.th_t),c.th_sp,datenum(c.(site).t));
    
%    plot(t,data)
    plot(c.(site).t,c.(site).excess) % Excess CO2
end
%plot(c.th_t,c.th_sp,'b-','LineWidth',2)
hold off; grid on;ylabel(upper(species));
legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

plt.save_overview_w_background = 'y';
if strcmp(plt.save_overview_w_background,'y')
    export_fig(fullfile(readFolder,city,[city,'_img_overview_excess_',species,'.jpg']),'-r300','-p0.01',fx)
end

%% Diel averages
site_utc2lst = str2num(d.(city).(d.(city).site_names{1,1}).Attributes(11).Value);

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
title([replace(city,'_',' '),' ',upper(species),' diel - All sites'],'FontSize',35,'FontWeight','Bold')
plotted_cities = {};
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    %if str2double(d.(city).(site).Attributes(8).Value)>15; continue; end
    plotted_cities = [plotted_cities;site];
    plot((0:23)',c.(site).diel,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
hold off; grid on;
ylabel(upper(species)); xlabel('Hour')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')

plt.save_diel_excess = 'n';
if strcmp(plt.save_diel_excess,'y')
    export_fig(fullfile(readFolder,city,[city,'_img_diel_',species,'_excess.jpg']),'-r300','-p0.01',fx)
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
title([replace(city,'_',' '),' ',upper(species),' excess monthly average - All sites'],'FontSize',35,'FontWeight','Bold')
plotted_cities = {};
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if any(isnan(c.(site).monthly)); continue; end
    plotted_cities = [plotted_cities;site];
    plot((1:12)',c.(site).monthly,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
ylabel('Excess CO2 (ppm)'); xlabel('Month')
xlim([1,12])
hold off; grid on;
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

plt.save_monthly_excess = 'y';
if strcmp(plt.save_monthly_excess,'y')
    export_fig(fullfile(readFolder,city,[city,'_img_monthly_',species,'_excess.jpg']),'-r300','-p0.01',fx)
end


%% Seasonal plot of mid-afternoon concentrations
fx = figure(5); fx.Color = [1 1 1]; clf; hold on
title([replace(city,'_',' '),' ',upper(species),' excess monthly mid-afternoon (12-17 LST) average - All sites'],'FontSize',35,'FontWeight','Bold')
plotted_cities = {};
for jj = 1:length(d.(city).site_names)
    site = d.(city).site_names{jj,1};
    if ~isempty(regexp(site,'background','once')); continue; end
    if any(isnan(c.(site).monthly_midafternoon)); continue; end
    plotted_cities = [plotted_cities;site];
    plot((1:12)',c.(site).monthly_midafternoon,'.-','LineWidth',3,'MarkerSize',35) % Excess CO2
end
ylabel('Excess CO2 (ppm)'); xlabel('Month')
xlim([1,12])
hold off; grid on;
legend(replace(plotted_cities,'_',' '),'Location','NorthWest')
%legend(replace(d.(city).site_names,'_',' '),'Location','NorthWest')
xl = get(gca,'XLabel'); xlFontSize = get(xl,'FontSize'); xAX = get(gca,'XAxis'); yl = get(gca,'YLabel'); ylFontSize = get(yl,'FontSize'); yAX = get(gca,'YAxis');
xAX.FontSize = 25; yAX.FontSize = 25; yl.FontSize = 30; yl.FontWeight = 'Bold'; xl.FontWeight = 'Bold';

plt.save_monthly_midafternoon_excess = 'y';
if strcmp(plt.save_monthly_midafternoon_excess,'y')
    export_fig(fullfile(readFolder,city,[city,'_img_monthly_midafternoon_',species,'_excess.jpg']),'-r300','-p0.01',fx)
end








