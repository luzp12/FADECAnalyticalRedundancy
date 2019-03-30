clear;
%��������
load Data00.mat;
load DataJudgement.mat;
M=A;
[mA,nA]=size(A);
DataJudgement=DataJudgement(:,1:nA);
%%����1��������ȷ���
 A=A*diag(1./DataJudgement(2,:));
rankA=ones(length(A),1);
 for i=1:length(A)-29
     rankA(i,1)=rank(A(i:i+29,:),0.005);
 end
figure(1)
plot(rankA,'or');
% legend('N1','N2','FF','EGT','TAT','PT','OIP','OIT','VIB','PLA');

%%����2������Է���
acoor=corrcoef(A);
%��ֵ��ʹͼ�ι��ȸ���Ȼ
x=1:length(acoor);
x1=1:0.01:length(acoor);
[x2,y2]=meshgrid(x1,x1);
acoor1=interp2(x,x,acoor,x2,y2,'cubic');

figure(2)
imagesc(1:10,1:10,acoor1); axis xy;
% colormap(gray(256));
colorbar;
% mesh(acoor1);

%%������ʼ�ľ���ֵab*X(1:6)==>X(7/8)
ab=zeros(7,8);
ab(:,7)=[M(:,1:6) ones(mA,1)]\M(:,7);
ab(:,8)=[M(:,1:6) ones(mA,1)]\M(:,8);

figure(3)
plot(1:mA,M(:,7),'.r',1:mA,[M(:,1:6) ones(mA,1)]*ab(:,7),'.b');
legend('7','7���');

figure(4)
plot(1:mA,M(:,8),'.r',1:mA,[M(:,1:6) ones(mA,1)]*ab(:,8),'.b');
legend('8','8���');
save('ab.mat','ab');




