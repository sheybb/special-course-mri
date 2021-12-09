function create_directory(parent_folder, folder_name)
% CREATE_FOLDERS creates all the directories needed. It first checks if it
% already exits anf if not it creates it and adds it to the path.
%   Input:
%       - path: parent Folder
%       - dir_name: folder Name

if ~exist(strcat(parent_folder, folder_name), 'dir')
       mkdir(parent_folder, folder_name)
end
addpath(genpath(strcat(parent_folder, folder_name))); 
end