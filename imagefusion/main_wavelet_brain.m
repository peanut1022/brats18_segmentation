clear all;clc
%% 数据导入
path = 'F:\my_data\Brats18TrainingData\HGG'
dirfile = dir(path);
filename={dirfile.name};
for i=3:length(filename)
    dirmat=dir(fullfile(path, filename{i}, '*.mat'));
    brain_name={dirmat.name};
%     for j=1:length(brain_name)
    brain_flair=cell2mat(struct2cell(load(fullfile(path,filename{i},brain_name{1}))));
    brain_t1=cell2mat(struct2cell(load(fullfile(path,filename{i},brain_name{2}))));
    brain_t1ce=cell2mat(struct2cell(load(fullfile(path,filename{i},brain_name{3}))));
    brain_t2=cell2mat(struct2cell(load(fullfile(path,filename{i},brain_name{4}))));
    
    f1 = mat2gray(brain_flair);
    f1 = im2double(f1);
        
    f2 = mat2gray(brain_t1);
    f2 = im2double(f2);

    f3 = mat2gray(brain_t1ce);
    f3 = im2double(f3);

    f4 = mat2gray(brain_t2);
    f4 = im2double(f4);
%% 小波分解
% [af, sf] = farras;  

wt1= dwt3(f1,'db3');
wt2= dwt3(f2,'db3');
wt3= dwt3(f3,'db3');
wt4= dwt3(f4,'db3');

[L11_1,L12_1,L21_1,L22_1]=wt1.dec{:,:,1};
[L11_2,L12_2,L21_2,L22_2]=wt2.dec{:,:,1};
[L11_3,L12_3,L21_3,L22_3]=wt3.dec{:,:,1};
[L11_4,L12_4,L21_4,L22_4]=wt4.dec{:,:,1};

[L1,H1,V1,D1]=wt1.dec{:,:,2};
[L2,H2,V2,D2]=wt2.dec{:,:,2};
[L3,H3,V3,D3]=wt3.dec{:,:,2};
[L4,H4,V4,D4]=wt4.dec{:,:,2};

%% 系数融合
% 低频加权
L11=0.1.*L11_1+0.1.*L11_2+0.4.*L11_3+0.4.*L11_4;
L12=0.1.*L12_1+0.1.*L12_2+0.4.*L12_3+0.4.*L12_4;
L21=0.1.*L21_1+0.1.*L21_2+0.4.*L21_3+0.4.*L21_4;
L22=0.1.*L22_1+0.1.*L22_2+0.4.*L22_3+0.4.*L22_4;

%高频加权
w1=exp(abs(L1-mean2(L1))-std2(L1));
w2=exp(abs(L2-mean2(L2))-std2(L2));
w3=exp(abs(L3-mean2(L3))-std2(L3));
w4=exp(abs(L4-mean2(L4))-std2(L4));
L=(w1./(w1+w2+w3+w4+eps)).*L1+(w2./(w1+w2+w3+w4+eps)).*L2+(w3./(w1+w2+w3+w4+eps)).*L3+(w4./(w1+w2+w3+w4+eps)).*L4;
clear w1;clear w2;clear w3;clear w4;

w1=exp(abs(H1-mean2(H1))-std2(H1));
w2=exp(abs(H2-mean2(H2))-std2(H2));
w3=exp(abs(H3-mean2(H3))-std2(H3));
w4=exp(abs(H4-mean2(H4))-std2(H4));
H=(w1./(w1+w2+w3+w4+eps)).*H1+(w2./(w1+w2+w3+w4+eps)).*H2+(w3./(w1+w2+w3+w4+eps)).*H3+(w4./(w1+w2+w3+w4+eps)).*H4;
clear w1;clear w2;clear w3;clear w4;

w1=exp(abs(V1-mean2(V1))-std2(V1));
w2=exp(abs(V2-mean2(V2))-std2(V2));
w3=exp(abs(V3-mean2(V3))-std2(V3));
w4=exp(abs(V4-mean2(V4))-std2(V4));
V=(w1./(w1+w2+w3+w4+eps)).*V1+(w2./(w1+w2+w3+w4+eps)).*V2+(w3./(w1+w2+w3+w4+eps)).*V3+(w4./(w1+w2+w3+w4+eps)).*V4;
clear w1;clear w2;clear w3;clear w4;

w1=exp(abs(D1-mean2(D1))-std2(D1));
w2=exp(abs(D2-mean2(D2))-std2(D2));
w3=exp(abs(D3-mean2(D3))-std2(D3));
w4=exp(abs(D4-mean2(D4))-std2(D4));
D=(w1./(w1+w2+w3+w4+eps)).*D1+(w2./(w1+w2+w3+w4+eps)).*D2+(w3./(w1+w2+w3+w4+eps)).*D3+(w4./(w1+w2+w3+w4+eps)).*D4;

%% 小波重构
wt.sizeINI=wt1.sizeINI;
wt.filters=wt1.filters;
wt.mode=wt1.mode;

wt.dec{1,1,1}=L11;
wt.dec{1,2,1}=L21;
wt.dec{2,1,1}=L12;
wt.dec{2,2,1}=L22;
wt.dec{1,1,2}=L;
wt.dec{1,2,2}=V;
wt.dec{2,1,2}=H;
wt.dec{2,2,2}=D;

f=idwt3(wt); 
  for j =1:155
      f(:,:,j)=imadjust(f(:,:,j),[],[],1.5);
  end
savepath=fullfile(path,filename{i},strcat(brain_name{2}(1:end-6),'fusion'))
save(savepath,'f')
end
