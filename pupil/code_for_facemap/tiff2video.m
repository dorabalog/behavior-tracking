%% Convert tiff files to video avi format

close all 
clear all
clc

%% Mouse data

date = 'datex';
mouse = 'mousex';
run = 'run0x';

%% Set up directories

root_folder = uigetdir('/projectnb/devorlab/emart/2023/1p/');
save_folder = '/projectnb/devorlab/dbalog/behavior_analysis/pupil_dilation/videos/';
if ~isfolder(save_folder)
    mkdir(save_folder); 
end
save_filename = strcat(mouse, '_', date, '_', run, '.avi');

%% Sort Files

% Natural-Order Filename Sort - MATLAB FCN
% alphanumeric sort of filenames
filenames = natsortfiles(dir(root_folder));

%% Create video

v = VideoWriter([save_folder filesep save_filename],'Motion JPEG AVI'); %'Uncompressed AVI'
v.FrameRate = 10; % camera acquisition frame rate
open(v);

framenr = 0;
tic
% skipping first 2 iterations on purpose - tiff file names are '.' & '..'
for k=3:(size(struct2table(filenames), 1)-1)
     run_path = strcat(root_folder, filesep, filenames(k).name);
     t = Tiff(run_path,'r');
     imageData = im2uint8(read(t));
     % writeVideo(v,imageData);
     % Black Frame Elimination
     % NOTE: a more reliable method should be implemented if needed
     if max(imageData(:)) > 5
        writeVideo(v,imageData);
        framenr = framenr+1;
     end
end
close(v);
toc
disp(framenr)
