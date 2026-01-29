%% Create whisking signals

close all
clear all
clc

% Last edit: 14 July 2023 - Dora Balog %%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Mouse data

date = '23-07-20';
mouse = 'Thy1_153_No_Cone';
run = 'run04';

%% Set up directories

root_folder = uigetdir('/projectnb/devorlab/pdoran/1P/23-07-20/Thy1_153_No_Cone/basler/Run3/'); % choose fodler that contains tiff files
save_folder = '/projectnb/devorlab/dbalog/test/'; % adjust to save in your folder!
if ~isfolder(save_folder) 
    mkdir(save_folder)
end

%% Sort Files

% Natural-Order Filename Sort - MATLAB FCN
% alphanumeric sort of filenames
filenames = natsortfiles(dir(root_folder));

%% Select whisker ROIs

run_path = strcat(root_folder,filesep, filenames(floor(length(filenames)/2)).name); % displays frame from the middle of the recording
t = Tiff(run_path,'r');
imageData = im2uint8(read(t));

figure, imshow(imageData)
title('Select ROI around long whiskers')
r = drawrectangle('Color','r');
roi1 = r.Position;
disp('After adjusting the ROI, press enter to continue')
pause

figure, imshow(imageData)
title('Select ROI around whisker pad')
r2 = drawrectangle('Color','r');
roi2 = r2.Position;
disp('After adjusting the ROI, press enter to continue')
pause
disp('Calculating...')

roi = [roi1; roi2];

close all

%% Motion energy movie - currently disabled

% answer = input('Do you want to create a motion energy movie? Yes=1 No=0\n');
% if answer ==1
%    motion_energy(root_folder, save_folder, roi, date, mouse, run);
% elseif answer==0
%     disp('Ok, your loss')
% end

%% Calculate whisker signal

whisker_signal=[];
whisker_signal2=[];
for k = 3: (size(struct2table(filenames), 1))  
    run_path = strcat(root_folder, filesep, filenames(k).name);
    t = Tiff(run_path,'r');
    imageData = im2uint8(read(t));
    Icropped = imcrop(imageData,roi1);
    Icropped2 = imcrop(imageData,roi2);
    switch k
        case 3
            img_prev = Icropped;
            img_prev2 = Icropped2;
        otherwise
            img_show = abs(Icropped - img_prev); % motion energy - difference of two consecutive frames
            img_show2 = abs(Icropped2 - img_prev2);
            %if sum(img_show(:)) ~= 0
                whisker_signal(k-2) = sum(img_show(:));
                whisker_signal2(k-2) = sum(img_show2(:));
            %end
            img_prev = Icropped;
            img_prev2 = Icropped2;
    end
end

clear Icropped Icropped2 imageData img_prev img_prev2 img_show img_show2

disp('Done whisking. Yay!')

%% Rescale & smooth whisker signal

whisker_smooth_long = real(rescale(smooth1d(whisker_signal,30))); % Anna's smoothing fcn
whisker_raw_long = rescale(whisker_signal);

whisker_smooth_pad = real(rescale(smooth1d(whisker_signal2,30))); % Anna's smoothing fcn
whisker_raw_pad = rescale(whisker_signal2);


%% Load trigger file

answer = input("Do you need to detect the trigger manually? yes=1, no=0\n");
if answer == 1
    trigger = trigger_detection(root_folder);
    trigger(trigger==0) = NaN;

    whisker_triggered1 = whisker_raw_long.*trigger;
    whisker_raw_long = whisker_triggered1(~isnan(whisker_triggered1));
    whisker_triggered2 = whisker_raw_pad.*trigger;
    whisker_raw_pad = whisker_triggered2(~isnan(whisker_triggered2));

    whisker_triggered_smooth1 = whisker_smooth_long.*trigger;
    whisker_smooth_long = whisker_triggered_smooth1(~isnan(whisker_triggered_smooth1));
    whisker_triggered_smooth2 = whisker_smooth_pad.*trigger;
    whisker_smooth_pad = whisker_triggered_smooth2(~isnan(whisker_triggered_smooth2));
    
    settings.trigger = 'yes';
elseif answer == 0
    disp('Amazing, less work for me!')
    %trigger=ones(1, length(pupil_raw));
    settings.trigger='no';
end

%% Choose whisker signal

whisker_smooth_long2 = smooth1d(whisker_smooth_long, 60);

figure
subplot(2,1,1)
plot(1:length(whisker_smooth_long2), whisker_smooth_long2)
xlim('tight')
%hold on 
%plot(1:length(whisker_raw_long), whisker_raw_long)
title('Long whiskers')

whisker_smooth_pad2 = smooth1d(whisker_smooth_pad,60);

subplot(2,1,2)
plot(1:length(whisker_smooth_pad2), whisker_smooth_pad2)
xlim('tight')
%hold on 
%plot(1:length(whisker_raw_pad), whisker_raw_pad)
title('Whisker pad')
%%
answer = input('Choose whisker signal for binning/thresholding: Long=1 Pad=0\n');
switch answer
    case answer==1
        whisker_smooth = whisker_smooth_long;
    case answer==0
        whisker_smooth = whisker_smooth_pad;
end

%% Bin whisker signal

threshold = input("Input a thresholding value between [0 1]:\n");
whisker_bins = thresholding(whisker_smooth, threshold);

%% Save .mat file

info.mouse = mouse;
info.date = date;
info.run = run;
clear mouse date run

settings.filenames = filenames;
settings.root_folder = root_folder;
settings.save_folder = save_folder;
settings.rois = roi;
clear filenames root_folder save_folder threshold trigger

clear whisker 
whisker.whisker_bins = whisker_bins;
whisker.whisker_raw_long = whisker_raw_long;
whisker.whisker_raw_pad = whisker_raw_pad;
whisker.whisker_smooth_long = whisker_smooth_long;
whisker.whisker_smooth_pad = whisker_smooth_pad;
clear whisker_bins whisker_raw_long whisker_raw_pad whisker_smooth_long whisker_smooth_pad
clear whisker_signal whisker_signal2 whisker_smooth whisker_raw whisker_triggered_smooth1 whisker_triggered_smooth2
clear answer k r r2 roi roi1 roi2 whisker_triggered1 whisker_triggered2 run_path t

save([settings.save_folder, [info.mouse, '_', info.date, '_', info.run],'_whisker.mat']);
disp('Done! Mat file saved.')
