function [whisker_raw_pad, whisker_smooth_pad, whisker_raw_long, whisker_smooth_long] = whisking(root_folder, save_folder, mouse, date, run)

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

whikser_signal=[];
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

%% Trigger signal - currently disabled - triggering is done with pupil 

% Uncomment if Basler camera does not trigger on time
% trigger = trigger_detection(root_folder, filenames);
% whisker_triggered = nonzeros(whisker_signal.*trigger);
% whisker_final = whisker_triggered;