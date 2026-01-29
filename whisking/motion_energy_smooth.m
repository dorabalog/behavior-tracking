function [] = motion_energy_smooth(root_folder, save_folder, roi, date, mouse, run)

filenames = natsortfiles(dir(root_folder));

%% Motion energy movie

save_movie = strcat(save_folder, 'movies/');
if ~isfolder(save_movie) 
    mkdir(save_movie)
end
save_filename = strcat(mouse, '_', date, '_', run,'_mot_energy.avi');

v = VideoWriter([save_movie filesep save_filename],'Motion JPEG AVI'); 
v.FrameRate = 10;
open(v);

f = figure();

for k = 3: (size(struct2table(filenames), 1)-1)  
    run_path = strcat(root_folder, filesep, filenames(k).name);
    t = Tiff(run_path,'r');
    imageData = im2uint8(read(t));
    Icropped = imcrop(imageData,roi(1, :));
    Icropped2 = imcrop(imageData,roi(2, :));
    switch k
        case 3
            img_prev = Icropped;
            img_prev2 = Icropped2;
        otherwise
            img_show = abs(smooth2d((Icropped - img_prev),3));
            img_show2 = abs(smooth2d((Icropped2 - img_prev2),3));
            if sum(img_show(:)) ~= 0
                subplot(1,2,1)
                imagesc(img_show);
                title('Long whiskers')
                subplot(1,2,2)
                imagesc(img_show2);
                title('Whisker pad')
            end
            img_prev = Icropped;
            img_prev2 = Icropped2;
    end
    
    frame = getframe(f);
    writeVideo(v,frame);

end
close(v);

out = 1;