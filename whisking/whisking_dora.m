
%% Create whisking signals

close all
clear all
clc

%% Mouse data

date = 'datex';
mouse = 'mousex';
run = 'run0x';

%% Set up directories

root_folder = uigetdir('/projectnb/devorlab/'); % choose the tiff folder
save_folder = '/projectnb/devorlab/dbalog/';
if ~isfolder(save_folder) 
    mkdir(save_folder)
end

%% Sort Files

% Natural-Order Filename Sort - MATLAB FCN
% alphanumeric sort of filenames
filenames = natsortfiles(dir(root_folder));

%% select whisker ROIs

run_path = strcat(root_folder,filesep, filenames(100).name);
t = Tiff(run_path,'r');
imageData = im2uint8(read(t));

figure, imshow(imageData)
title('Select ROI around long whiskers')
r = drawrectangle('Color','r');
roi1 = r.Position;

figure, imshow(imageData)
title('Select ROI around whisker pad')
r2 = drawrectangle('Color','r');
roi2 = r2.Position;

roi = [roi1; roi2];

%% Motion energy movie

answer = input('Do you want to create a motion energy movie? Yes=1 No=0\n');
if answer ==1
   motion_energy_smooth(root_folder, save_folder, roi, date, mouse, run);
elseif answer==0
    disp('Ok, your loss')
end

%% Calculate whisker signal

whisker_signal = [0 0 0]; % initialize first 3 values because we're starting the fro loop from 3
for k = 3: (size(struct2table(filenames), 1)-1)  
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
            img_show = abs(Icropped - img_prev);
            img_show2 = abs(Icropped2 - img_prev2);
            img_show3 = abs(smooth2d((Icropped - img_prev),5));
            img_show4 = abs(smooth2d((Icropped2 - img_prev2),5));
            if sum(img_show(:)) ~= 0
                whisker_signal(k) = sum(img_show(:));
                whisker_signal2(k) = sum(img_show2(:));
                whisker_signal3(k) = sum(img_show3(:));
                whisker_signal4(k) = sum(img_show4(:));
            end
            img_prev = Icropped;
            img_prev2 = Icropped2;
    end
end

%% Rescale & smooth whisker signal

whisker_smooth_long = rescale(smooth1d(whisker_signal,40)); % Anna's smoothing fcn
whisker_raw_long = rescale(whisker_signal);

whisker_smooth_pad = rescale(smooth1d(whisker_signal2,40)); % Anna's smoothing fcn
whisker_raw_pad = rescale(whisker_signal2);

whisker_smooth_long2 = rescale(smooth1d(whisker_signal3,40)); % Anna's smoothing fcn
whisker_raw_long2 = rescale(whisker_signal);

whisker_smooth_pad2 = rescale(smooth1d(whisker_signal4,40)); % Anna's smoothing fcn
whisker_raw_pad2 = rescale(whisker_signal2);

%% Plot whisker signal

figure
subplot(2,2,1)
plot(1:length(whisker_smooth_long), whisker_smooth_long)
hold on 
plot(1:length(whisker_raw_long), whisker_raw_long)
title('Long whiskers')

subplot(2,2,2)
plot(1:length(whisker_smooth_pad), whisker_smooth_pad)
hold on 
plot(1:length(whisker_raw_pad), whisker_raw_pad)
title('Whisker pad')

subplot(2,2,3)
plot(1:length(whisker_smooth_long2), whisker_smooth_long2)
hold on 
plot(1:length(whisker_raw_long2), whisker_raw_long2)
title('Long whiskers - smooth')

subplot(2,2,4)
plot(1:length(whisker_smooth_pad2), whisker_smooth_pad2)
hold on 
plot(1:length(whisker_raw_pad2), whisker_raw_pad2)
title('Whisker pad - smooth')

%% Choose method

answer = input('Choose whisker signal: Long=1 Pad=0')
switch answer
    case answer==1
        clear whisker_rescaled_pad whisker_smooth_pad whikser_raw_pad
        whisker_raw = whikser_raw_long;
        whisker_smooth = whisker_smooth_long;
    case answer==0
        clear whisker_rescaled_long whisker_smooth_long
        whisker_raw = whisker_raw_pad;
        whisker_smooth = whisker_smooth_pad;
end

%% Trigger signal

% Uncomment if Basler camera does not trigger on time
% trigger = trigger_detection(root_folder, filenames);
% whisker_triggered = nonzeros(whisker_signal.*trigger);
% whisker_final = whisker_triggered;

%% Save mat file

w=1;
clear 
save([save_mat, [mouse, '_', date, '_', run]]),'.mat';

%% Bin whisker signal

threshold = input("Input a thresholding value [0 1]\n");
whisker_bins = thresholding(whisker_rescaled, threshold);

%% Whisker movie

save_filename = strcat(mouse, '_', date, '_', run,'.avi');

v = VideoWriter([save_movie filesep save_filename],'Motion JPEG AVI');
v.FrameRate = 10;
open(v);

f = figure();

for k = 3: (size(struct2table(filenames), 1)-1)  
    run_path = strcat(root_folder, filesep, filenames(k).name);
    t = Tiff(run_path,'r');
    imageData = im2uint8(read(t));
    ax1 = subplot(4,1,1)
    imshow(imageData)
    title(strcat(strrep(mouse,'_','-'), '-', date, '-',run))

    ax2 = subplot(4,1,2)
    plot(1:length(whisker_rescaled_long), whisker_rescaled_long, 'Color','r')
    xline(k)
    xlim('tight')
    title('Long whiskers')

    ax3 = subplot(4,1,3)
    plot(1:length(whisker_rescaled2), whisker_rescaled2, 'Color','b')
    xline(k)
    xlim('tight')
    title('Whisker pad')

    ax4 = subplot(4,1,4)
    plot(1:length(whisker_bins), whisker_bins, "Color", "g")
    xline(k)
    xlim('tight')
    ylim([0 1])
    title(strcat('Threshold at: ', sprintf('%.2f', threshold)))

    frame = getframe(f);
    writeVideo(v,frame);

end

close(v);