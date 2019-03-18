clear all;
%%single mat2nii
% a=load('G:\compare\fusion_6.mat');
% b=a.f; 
% c=make_nii(b);
% save_nii(c,'G:\learning_process\19.3_DL_500_questions\review\compare\fusion_6.nii.gz');


path = 'F:\my_data\brats18_training\LGG'
dirfile = dir(path);
filename={dirfile.name};
for i=3:length(filename)
    dirzip=dir(fullfile(path, filename{i}, '*.mat'))
    zipname={dirzip.name};
        for j=1:length(zipname)
            mat=load(fullfile(path,filename{i},zipname{j}(1:end-3)));
            b=mat.f;
            c=make_nii(b);
            savepath=fullfile(path,filename{i},strcat(zipname{j}(1:end-4),'.nii.gz'))
            save_nii(c,savepath)
        end

end
