function [] = movie(root_folder, save_folder, date, mouse, run,  pupil, whisker, bins, time)

filenames = natsortfiles(dir(root_folder));

%% select ROI for movie

run_path = strcat(root_folder,filesep, filenames(100).name);
t = Tiff(run_path,'r');
imageData = im2uint8(read(t));
figure, imshow(imageData)
title('Choose ROI for movie') % it will not affect the pupil and whisker computation
r = drawrectangle('Color','r');
roi = r.Position;
disp('Adjust ROI, press enter to continue')
pause

%% Make movie

save_movie = strcat(save_folder, 'movies/');
if ~isfolder(save_movie) 
    mkdir(save_movie)
end
save_filename = strcat(mouse, '_', date, '_', run, '_complete_comparison','.avi');

close all

v = VideoWriter([save_movie filesep save_filename],'Motion JPEG AVI'); % 'Uncompressed AVI' 'Motion JPEG AVI'
v.FrameRate = 10;
open(v);

f = figure('Position',[0 0 1500 1500]);

for k = 1: (size(struct2table(filenames), 1)-2) 
    run_path = strcat(root_folder, filesep, filenames(k+2).name);
    t = Tiff(run_path,'r');
    imageData = im2uint8(read(t));
    Icropped = imcrop(imageData,roi);

    ax1 = subplot(2,2,1);
    imshow(Icropped);
    title(strcat(strrep(mouse,'_','-'), '-', date, '-',run));

    ax2 = subplot(2,2,2);

    plot(time, whisker, "Color", "b");
    xline(time(k));
    xlim('tight');
    title('Whisking');
    xlabel('time [s]');
    ylabel('speed [%]');

    ax3 = subplot(2,2,3);
    plot(time, pupil, "Color", "r");
    xline(time(k));
    xlim('tight');
    title('Pupil');
    xlabel('time [s]');
    ylabel('dilation [%]');

    ax4 = subplot(2,2,4);
    plot(time, bins,':');
    xline(time(k));
    ylim([0 2])
    xlim('tight');
    title('Bins');
    xlabel('time [s]');
    ylabel('on/off');

    frame = getframe(f);
    writeVideo(v,frame);

end
close(v);