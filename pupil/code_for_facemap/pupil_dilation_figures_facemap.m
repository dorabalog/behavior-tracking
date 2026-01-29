close all
clear all
clc

%% Mouse data

date = '9-16-22';
mouse = 'Thy1_94';
run = 'run03';

%% Load data

root_folder = '/projectnb/devorlab/dbalog/pupil_dilation/comp files/';
save_folder = '/projectnb/devorlab/dbalog/pupil_dilation/comp files/';

data = load(strcat(root_folder, mouse, '_', date, '_', run,'_proc.mat'));

%% Extract values

pupil_area = filloutliers(data.pupil{1,1}.area,"previous","percentiles",[1 99]);
smooth_area = filloutliers(data.pupil{1,1}.area_smooth,"previous","percentiles",[1 99]);
framenr = 1: length(pupil_area);

%% Plot results
mouse2 = strrep(mouse,'_','-');

figure(1)
plot(framenr,pupil_area)
title(strcat(mouse2, '-', date, '-',run,' Raw signal'))
%print('-dpng', [save_folder, filesep, [mouse, '_', date, '_', run, '_raw']]);
figure(2)
plot(framenr, smooth_area)
title(strcat(mouse2, '-', date, '-',run, ' Smoothed signal'))
%print('-dpng', [save_folder, filesep, [mouse, '_', date, '_', run, '_smooth']]);
figure(3)
plot(framenr,pupil_area)
hold on
plot(framenr,smooth_area)
legend ('raw', 'smooth', 'Location','best')
title(strcat(mouse2, '-', date, '-',run))
print('-dpng', [save_folder, filesep, [mouse, '_', date, '_', run, '_rawVSsmooth']]);

area_norm = ((pupil_area)-min(pupil_area))./(max(pupil_area) - min(pupil_area));
smooth_norm = ((smooth_area)-min(smooth_area))./(max(smooth_area) - min(smooth_area));

figure(4)
plot(framenr,area_norm)
hold on
plot(framenr,smooth_norm)
legend ('raw', 'smooth', 'Location','best')
title(strcat(mouse2, '-', date, '-',run))
print('-dpng', [save_folder, filesep, [mouse, '_', date, '_', run, '_rawVSsmooth_norm']]);

%% Before & After Outlier filtering

pupil_outliers = data.pupil{1,1}.area;
smooth_outliers = data.pupil{1,1}.area_smooth;

figure(5)
plot(framenr,pupil_outliers)
hold on
plot(framenr,pupil_area)
legend ('with outliers', 'without outliers', 'Location','best')
title(strcat(mouse2, '-', date, '-',run))