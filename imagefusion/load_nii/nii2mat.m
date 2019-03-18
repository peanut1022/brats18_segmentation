clear all;
% % single nii2mat
% a = load_nii('F:\my_data\Brats18TrainingData\HGG\Brats18_2013_10_1\Brats18_2013_10_1_t1.nii.gz')
% t1 = a.img;
% brain_t1 = mat2gray(t1);


path = 'F:\my_data\Brats18TrainingData\HGG'
dirfile = dir(path);
filename={dirfile.name};
for i=3:length(filename)
     dirzip=dir(fullfile(path, filename{i}, '*.gz'))
    zipname={dirzip.name};
        for j=1:length(zipname)
            %gunzip(fullfile(path,filename{i},zipname{j}));
            nii=load_nii(fullfile(path,filename{i},zipname{j}));
            zipname{j}(1:end-3)
            a=nii.img;
            %strcat(zipname{j}(1:end-7),'.mat')=a
            savepath=fullfile(path,filename{i},strcat(zipname{j}(1:end-7),'.mat'))
            save(savepath,'a')
        end

end

