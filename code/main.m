clear
clc
addpath(genpath('special-course-mri\'))
run('configuration_file');

%% LOADING AND PROCESSING RF HEATING II DATA
path = strcat(path_raw_data, data);
Files = dir(path);
numfiles = length(Files);

j = 1;
for k = 1:numfiles 
  data_files = dir(strcat(path_raw_data, '\',Files(k).name,'/*.IMA'));
  idx = strsplit(Files(k).name, '_0');
    for i = 1:length(data_files)
        for file = data_files'
            data_cell{i,str2double(idx{2})} = dicomread(file.name);
            info = dicominfo(file.name);
            TE = info.EchoTime;
            data_rs = rescale_data(dicomread(file.name),info,Files(k).name);
            data_cell_rs{i,str2double(idx{2})} = data_rs;
            tip_angles(j) = info.FlipAngle;
            TR(j) = info.RepetitionTime;
            j = j + 1;
        end
    end
end

create_directory(strcat(path_program, '\results\mat\'),idx);

% Create t' series Volumes balloon phantom
data1_rs_balloon_mag = creatingVolume(data_cell_rs, [185;214], 'magnitude');
data1_rs_balloon_ph = creatingVolume(data_cell_rs, [185;214], 'phase');
data2_rs_balloon_mag = creatingVolume(data_cell_rs, [155;184], 'magnitude');
data2_rs_balloon_ph = creatingVolume(data_cell_rs, [155;184], 'phase');
data3_rs_balloon_mag = creatingVolume(data_cell_rs, [125;154], 'magnitude');
data3_rs_balloon_ph = creatingVolume(data_cell_rs, [125;154], 'phase');

%%%%%%%%%%%%%% Visualization balloon %%%%%%%%%%%%%%%%%%
figure, sliceViewer(data1_rs_balloon_mag, 'DisplayRange', []);
figure, sliceViewer(data1_rs_balloon_ph, 'DisplayRange', []);

% Create t' series Volumes tube phantom
data1_rs_tube_mag = creatingVolume(data_cell_rs, [31;50], 'magnitude');
data1_rs_tube_ph = creatingVolume(data_cell_rs, [31;50], 'phase');
data2_rs_tube_mag = creatingVolume(data_cell_rs, [51;70], 'magnitude');
data2_rs_tube_ph = creatingVolume(data_cell_rs, [51;70], 'phase');
data3_rs_tube_mag = creatingVolume(data_cell_rs, [71;90], 'magnitude');
data3_rs_tube_ph = creatingVolume(data_cell_rs, [71;90], 'phase');

%%%%%%%%%%%%%% Visualization tube %%%%%%%%%%%%%%%%%%
figure, sliceViewer(data1_rs_tube_mag, 'DisplayRange', []);
figure, sliceViewer(data1_rs_tube_ph, 'DisplayRange', []);

% Create a mask to select the ROI
% Threshold mask balloon
mask_th_balloon = create_mask_threshold (data1_rs_balloon_mag, 'balloon');
figure, sliceViewer(mask_th_balloon, 'DisplayRange', []);

% Threshold mask tube
mask_th_tube = create_mask_threshold (data1_rs_tube_mag, 'tube');
figure, sliceViewer(mask_th_tube, 'DisplayRange', []);

path_mat_files = strcat(path_program, '\results\mat');
save(strcat(path_mat_files,'\',idx,'\','_data2.mat'), 'data_cell','data_cell_rs',...
    'data1_rs_balloon_mag','data2_rs_balloon_mag','data2_rs_balloon_mag',...
    'data1_rs_balloon_ph','data2_rs_balloon_ph','data3_rs_balloon_ph',...
    'data1_rs_tube_mag','data2_rs_tube_mag','data2_rs_tube_mag',...
    'data1_rs_tube_ph','data2_rs_tube_ph','data3_rs_tube_ph',...
    'mask_th_balloon','mask_th_tube','TE');

%% %%%%%%%%%%%% Processing part %%%%%%%%%%%%%%%%%%
close all
clc

data_balloon_ph = {data1_rs_balloon_ph;data2_rs_balloon_ph;data3_rs_balloon_ph};
data_tube_ph = {data1_rs_tube_ph;data2_rs_tube_ph;data3_rs_tube_ph};

% 1. Apply the mask to the phase images to remove the background
data_rs_balloon_ph_no_background = applying_mask_remove_background(data_balloon_ph,mask_th_balloon);
data_rs_tube_ph_no_background = applying_mask_remove_background(data_tube_ph,mask_th_tube);

%%%%%%%%%%%% Correct phase jumps due to be close to (-pi,pi) %%%%%%%%%%%%
% Scale the images prior to correct the phases to (-pi,pi) and correct them
minVal = double(min(data1_rs_tube_ph(:)));
maxVal = double(max(data1_rs_tube_ph(:)));

phase_difference_data1_balloon = correcting_phases(data_rs_balloon_ph_no_background{1},minVal,maxVal) + pi;
phase_difference_data2_balloon = correcting_phases(data_rs_balloon_ph_no_background{2},minVal,maxVal) + pi;
phase_difference_data3_balloon = correcting_phases(data_rs_balloon_ph_no_background{3},minVal,maxVal) + pi;

phase_difference_data1_tube = correcting_phases(data_rs_tube_ph_no_background{1},minVal,maxVal) + pi;
phase_difference_data2_tube = correcting_phases(data_rs_tube_ph_no_background{2},minVal,maxVal) + pi;
phase_difference_data3_tube = correcting_phases(data_rs_tube_ph_no_background{3},minVal,maxVal) + pi;

% figure, sliceViewer(phase_difference_data1_balloon, 'DisplayRange', [-1 1]);

%% %%%%%%%%%%%% Temperature change %%%%%%%%%%%%%%%%%%%
close all
clc

diff_phase_tube = phase_difference_data3_tube - phase_difference_data1_tube;
% diff_phase_tube(diff_phase_tube<-0.1745) = diff_phase_tube(diff_phase_tube<-0.1745) + 2*pi;
% Pass to degrees
% diff_phase_tube = diff_phase_tube*180/pi;

alpha = 0.01 ;  % temperature dependent coefficient (ppm/°C)
Bo = 3;
gamma = 42.6;
fo  =  gamma* Bo;
TE_s = TE;
var_T_tube = diff_phase_tube / (alpha * fo * TE_s);
cmap = parula(256);
figure,  sliceViewer(var_T_tube,'Colormap',cmap);
figure,  imagesc(var_T_tube(:,:,6));
colorbar;

diff_phase_balloon = phase_difference_data3_balloon - phase_difference_data1_balloon;
% diff_phase_balloon(diff_phase_balloon<-0.1745) = diff_phase_balloon(diff_phase_balloon<-0.1745) + 2*pi;
% Pass to degrees
% diff_phase_balloon = diff_phase_balloon*180/pi;

var_T_balloon = diff_phase_balloon / (alpha * fo * TE_s);
cmap = parula(256);
figure,  sliceViewer(var_T_balloon,'Colormap',cmap);
figure,  imagesc(var_T_balloon(:,:,6));
colorbar;

%%%%% Figure: temperature maps
figure
for i = 1:size(var_T_balloon,3)-1
    j = i + 1;
    nexttile
    imagesc(var_T_balloon(:,:,j));
%     caxis([-0.5 0.5]);
    colorbar;
    j = j + 1;
end

figure
for i = 1:size(var_T_tube,3)-1
    j = i + 1;
    nexttile
    imagesc(var_T_tube(:,:,j));
%     caxis([-0.5 0.5]);
    colorbar;
    j = j + 1;
end

%% %%%%%% Figure on top of magnitude image %%%%%%%%%
close all
clc

create_directory(strcat(path_program, '\results\figures\'),idx);

figure,
subplot(1,2,1)
imshow(data1_rs_balloon_mag(:,:,6), []) 
red = cat(3, ones(size(data1_rs_balloon_mag(:,:,6))),...
    zeros(size(data1_rs_balloon_mag(:,:,6))), zeros(size(data1_rs_balloon_mag(:,:,6)))); 
blue = cat(3, zeros(size(data1_rs_balloon_mag(:,:,6))),...
    zeros(size(data1_rs_balloon_mag(:,:,6))), ones(size(data1_rs_balloon_mag(:,:,6)))); 
hold on 
h = imshow(red); 
hold off 
I = var_T_balloon(:,:,6);
I_high = I;
I_high(I<0) = 0;
set(h, 'AlphaData', I_high) 
hold on 
h = imshow(blue); 
I_low = I;
I_low(I>0) = 0;
hold off 
set(h, 'AlphaData', -I_low) 

subplot(1,2,2)
imagesc(var_T_balloon(:,:,6)) 
% caxis([-0.5 0.5]);
colorbar;

figure,
subplot(1,2,1)
imshow(data1_rs_tube_mag(:,:,6), []) 
red = cat(3, ones(size(data1_rs_tube_mag(:,:,6))),...
    zeros(size(data1_rs_tube_mag(:,:,6))), zeros(size(data1_rs_tube_mag(:,:,6)))); 
blue = cat(3, zeros(size(data1_rs_tube_mag(:,:,6))),...
    zeros(size(data1_rs_tube_mag(:,:,6))), ones(size(data1_rs_tube_mag(:,:,6)))); 
hold on 
h = imshow(red); 
hold off 
I = var_T_tube(:,:,6);
I_high = I;
I_high(I<0) = 0;
set(h, 'AlphaData', I_high) 
hold on 
h = imshow(blue); 
I_low = I;
I_low(I>0) = 0;
hold off 
set(h, 'AlphaData', -I_low) 

subplot(1,2,2)
imagesc(var_T_tube(:,:,6)) 
% caxis([-0.5 0.5]);
colorbar;

%% Temperature plots over the time to evaluate the respone to heating
% Pixel to consider: [255,259] 
temp_change_px_prev = phase_difference_data1_tube(259,255,:);
for i = 1:length(temp_change_px_prev)
    temp_change_px_vector(i) = temp_change_px_prev(1,1,i);
end
figure, plot(temp_change_px_vector)

temp_change_px_heating = phase_difference_data2_tube(259,255,:);
for i = 1:length(temp_change_px_heating)
    temp_change_px_vector_heating(i) = temp_change_px_heating(1,1,i);
end
figure, plot(temp_change_px_vector_heating)

temp_change_px_after_heating = phase_difference_data3_tube(259,255,:);
for i = 1:length(temp_change_px_after_heating)
    temp_change_px_vector_after_heating(i) = temp_change_px_after_heating(1,1,i);
end
figure, plot(temp_change_px_vector_after_heating)

temp_change_1 = cat(2, temp_change_px_vector,temp_change_px_vector_heating,temp_change_px_vector_after_heating);
figure, plot(temp_change_1)
title('Tª change over pixel 259,255')


%% Pixel to consider: [257,253] 
temp_change_px_prev = phase_difference_data1_tube(253,257,:);
for i = 1:length(temp_change_px_prev)
    temp_change_px_vector(i) = temp_change_px_prev(1,1,i);
end
figure, plot(temp_change_px_vector)

temp_change_px_heating = phase_difference_data2_tube(253,257,:);
for i = 1:length(temp_change_px_heating)
    temp_change_px_vector_heating(i) = temp_change_px_heating(1,1,i);
end
figure, plot(temp_change_px_vector_heating)

temp_change_px_after_heating = phase_difference_data3_tube(253,257,:);
for i = 1:length(temp_change_px_after_heating)
    temp_change_px_vector_after_heating(i) = temp_change_px_after_heating(1,1,i);
end
figure, plot(temp_change_px_vector_after_heating)

temp_change_2 = cat(2, temp_change_px_vector,temp_change_px_vector_heating,temp_change_px_vector_after_heating);
figure, plot(temp_change_2)
title('Tª change over pixel 257,253')

%% Pixel to consider: [257,251] 
temp_change_px_prev = phase_difference_data1_tube(251,257,:);
for i = 1:length(temp_change_px_prev)
    temp_change_px_vector(i) = temp_change_px_prev(1,1,i);
end

temp_change_px_heating = phase_difference_data2_tube(251,257,:);
for i = 1:length(temp_change_px_heating)
    temp_change_px_vector_heating(i) = temp_change_px_heating(1,1,i);
end

temp_change_px_after_heating = phase_difference_data3_tube(251,257,:);
for i = 1:length(temp_change_px_after_heating)
    temp_change_px_vector_after_heating(i) = temp_change_px_after_heating(1,1,i);
end
figure, plot(temp_change_px_vector_after_heating)

temp_change_3 = cat(2, temp_change_px_vector,temp_change_px_vector_heating,temp_change_px_vector_after_heating);
figure, plot(temp_change_3)
title('Tª change over pixel 257,251')

%% Pixel to consider: [258,251] 
temp_change_px_prev = phase_difference_data1_tube(251,258,:);
for i = 1:length(temp_change_px_prev)
    temp_change_px_vector(i) = temp_change_px_prev(1,1,i);
end

temp_change_px_heating = phase_difference_data2_tube(251,258,:);
for i = 1:length(temp_change_px_heating)
    temp_change_px_vector_heating(i) = temp_change_px_heating(1,1,i);
end

temp_change_px_after_heating = phase_difference_data3_tube(251,258,:);
for i = 1:length(temp_change_px_after_heating)
    temp_change_px_vector_after_heating(i) = temp_change_px_after_heating(1,1,i);
end
figure, plot(temp_change_px_vector_after_heating)

temp_change_4 = cat(2, temp_change_px_vector,temp_change_px_vector_heating,temp_change_px_vector_after_heating);
figure, plot(temp_change_4)
title('Tª change over pixel 258,251')

%% Pixel to consider: [267,267] 
temp_change_px_prev = phase_difference_data1_tube(267,267,:);
for i = 1:length(temp_change_px_prev)
    temp_change_px_vector(i) = temp_change_px_prev(1,1,i);
end

temp_change_px_heating = phase_difference_data2_tube(267,267,:);
for i = 1:length(temp_change_px_heating)
    temp_change_px_vector_heating(i) = temp_change_px_heating(1,1,i);
end

temp_change_px_after_heating = phase_difference_data3_tube(267,267,:);
for i = 1:length(temp_change_px_after_heating)
    temp_change_px_vector_after_heating(i) = temp_change_px_after_heating(1,1,i);
end
figure, plot(temp_change_px_vector_after_heating)

temp_change_5 = cat(2, temp_change_px_vector,temp_change_px_vector_heating,temp_change_px_vector_after_heating);
figure, plot(temp_change_5)
title('Tª change over pixel 258,251')
%% Mean tº change
temp_change = [temp_change_1; temp_change_2; temp_change_3; temp_change_4; temp_change_5];
temp_change = mean(temp_change,1);
figure, plot(temp_change)
title('Tª change over the time')
