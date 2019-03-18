function di2=contrast_2D(A)

% load('PET_CT_lung10.mat');
% X=CT10_normalization(:,:,90);
%%
% for m=1:41
% A=X(:,:,m).*255;
%  A=X;
a=min(min(A));
b=max(max(A));
c=0.23;
d=0.68;
% a1=0.0;b1=255.0;
% c1=30;d1=170;
n1=find(A>=a&A<c);
n2=find(A>=c&A<d);
n3=find(A>=d&A<b);
di2=A;
% di2(n1)=(A(n1)-a)*(c1-a1)/(c-a)+a1;
di2(n1)=imadjust(A(n1), [],[],0.75);
% di2(n2)=(A(n2)-c)*(d1-c1)/(d-c)+c1;
di2(n2)=imadjust(A(n2), [],[],0.85);
% di2(n3)=(A(n3)-d)*(b1-d1)/(b-d)+d1;
di2(n3)=imadjust(A(n3), [],[],1.35);

% figure,imshow(di2)
% end
% figure,imshow(A(:,:,29))