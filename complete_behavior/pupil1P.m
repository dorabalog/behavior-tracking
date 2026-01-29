function [pupil_raw, pupil_smooth, trigger] = pupil1P(root_folder)

%% Sort Files

% Natural-Order Filename Sort - MATLAB FCN
% alphanumeric sort of filenames

filenames = natsortfiles(dir(root_folder));

%% Choose ROI and save mask

run_path = strcat(root_folder,filesep, filenames(floor(length(filenames)/2)).name); % displays frame from the middle of the recording
t = Tiff(run_path,'r');
imageData = im2uint8(read(t));
figure, imshow(imageData)
title('Draw ellipse around the eye')
roi = drawellipse('Color','r'); % for best results put start and end points in the corners of the eye 
disp('Adjust ROI, press enter to continue')
pause
disp('Calculating...')

mask = createMask(roi);

%% Create pupil dilation signal

pupil_raw = [];
for k=3:(size(struct2table(filenames), 1)) % for loop starts from 3 for a reason
     run_path = strcat(root_folder, filesep, filenames(k).name);
     t = Tiff(run_path,'r');
     imageData = im2uint8(read(t)); % read tiff file
     if max(imageData(:)) > 5 % skips completely black frames
        im_tresh = imageData;
        im_tresh(imageData<25) = 255;
        im_tresh(~mask) = 0; % overlay mask on image
        img_values = im_tresh(im_tresh>=1); % leave behind zero values (non-ROI pixels)
        pupil_raw(1,k-2) = sum(img_values); % pupil area = sum of white pixels after binarization
     end
end

clear run_path t imageData im_tresh img_values

disp('Done. Yay!')

%% Filter pupil signal

%pupil_outlier = filloutliers(pupil_raw, 'previous','percentiles',[1 99]); % replaces outluiers with previous values
pupil_smooth = real(rescale(smooth1d(pupil_raw, 30))); % Anna's smoothing fcn
pupil_raw = rescale(pupil_raw);

%% Bin pupil signal - currently disabled

% threshold = input("Input a thresholding value between [0 1]:\n");
% pupil_bins = thresholding(pupil_raw, threshold);

%% Load trigger file

answer = input("Do you need to detect the trigger manually? yes=1, no=0\n");
if answer == 1
    trigger = trigger_detection(root_folder);
    trigger(trigger==0) = NaN;
    pupil_triggered = pupil_raw.*trigger;
    pupil_raw = pupil_triggered(~isnan(pupil_triggered));
    pupil_triggered_smooth = pupil_smooth.*trigger;
    pupil_smooth = pupil_triggered_smooth(~isnan(pupil_triggered_smooth));
elseif answer == 0
    disp('Amazing, less work for me!')
    trigger=ones(1, length(pupil_raw));
end
