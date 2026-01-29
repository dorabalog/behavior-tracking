function [trigger] = trigger_detection(root_folder, filenames)

%% Choose ROI and save mask

run_path = strcat(root_folder,filesep, filenames(500).name); % displayed frame number can be ajdusted (ex. 500-> 1053)
t = Tiff(run_path,'r');
imageData = im2uint8(read(t));
figure, imshow(imageData)
roi = drawrectangle('Color','r'); % draw an ellipse around the laser signal

mask = createMask(roi);

%% Create LED flickering signal

LED = [];
for k=3:(size(struct2table(filenames), 1)-1)
     run_path = strcat(root_folder, filesep, filenames(k).name);
     t = Tiff(run_path,'r');
     imageData = im2uint8(read(t)); % read tiff file
     if max(imageData(:)) > 5 % skips black frames
        imageData(~mask) = 0; % overlay mask on image
        img_values = imageData(imageData>=1); % leave behind zero values (non-ROI pixels)
        LED(1,k-2) = max(img_values(:)); % take max value in chosen ROI
     end
end

%% Create trigger file

LED2 = LED;
LED2(LED>254) = 1;
LED2(LED<=245) = 0;
trigger = LED2;

