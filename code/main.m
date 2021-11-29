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
            data_rs = rescale_data(dicomread(file.name),info,Files(k).name);
            data_cell_rs{i,str2double(idx{2})} = data_rs;
            tip_angles(j) = info.FlipAngle;
            TR(j) = info.RepetitionTime;
            j = j + 1;
        end
    end
end

% Create t' series Volumes balloon phantom
data1_rs_balloon_mag = creatingVolume(data_cell_rs, [185;214], 'magnitude');
data1_rs_balloon_ph = creatingVolume(data_cell_rs, [185;214], 'phase');
data2_rs_balloon_mag = creatingVolume(data_cell_rs, [155;184], 'magnitude');
data2_rs_balloon_ph = creatingVolume(data_cell_rs, [155;184], 'phase');
data3_rs_balloon_mag = creatingVolume(data_cell_rs, [125;154], 'magnitude');
data3_rs_balloon_ph = creatingVolume(data_cell_rs, [125;154], 'phase');

%%%%%%%%%%%%%% Visualization balloon %%%%%%%%%%%%%%%%%%
figure, sliceViewer(data1_rs_balloon_mag, 'DisplayRange', []);
figure, sliceViewer(data2_rs_balloon_mag, 'DisplayRange', []);
figure, sliceViewer(data3_rs_balloon_mag, 'DisplayRange', []);
figure, sliceViewer(data1_rs_balloon_ph, 'DisplayRange', []);
figure, sliceViewer(data2_rs_balloon_ph, 'DisplayRange', []);
figure, sliceViewer(data3_rs_balloon_ph, 'DisplayRange', []);

% Create t' series Volumes tube phantom
data1_rs_tube_mag = creatingVolume(data_cell_rs, [31;50], 'magnitude');
data1_rs_tube_ph = creatingVolume(data_cell_rs, [31;50], 'phase');
data2_rs_tube_mag = creatingVolume(data_cell_rs, [51;70], 'magnitude');
data2_rs_tube_ph = creatingVolume(data_cell_rs, [51;70], 'phase');
data3_rs_tube_mag = creatingVolume(data_cell_rs, [71;90], 'magnitude');
data3_rs_tube_ph = creatingVolume(data_cell_rs, [71;90], 'phase');

%%%%%%%%%%%%%% Visualization tube %%%%%%%%%%%%%%%%%%
figure, sliceViewer(data1_rs_tube_mag, 'DisplayRange', []);
figure, sliceViewer(data2_rs_tube_mag, 'DisplayRange', []);
figure, sliceViewer(data3_rs_tube_mag, 'DisplayRange', []);
figure, sliceViewer(data1_rs_tube_ph, 'DisplayRange', []);
figure, sliceViewer(data2_rs_tube_ph, 'DisplayRange', []);
figure, sliceViewer(data3_rs_tube_ph, 'DisplayRange', []);
