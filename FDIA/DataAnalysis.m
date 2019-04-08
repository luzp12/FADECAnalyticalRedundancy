clear;
%��������
load Data02.mat;
load DataJudgement.mat;
A=A(:,1:8);
% DataJudgement=[DataJudgement(:,1:8) [0;0.25]];
M=A;
[mA,nA]=size(A);
% DataJudgement=DataJudgement(:,1:nA);
%%����1��������ȷ���
 A=A*diag(1./DataJudgement(2,:));
rankA=ones(length(A),1);
 for i=1:length(A)-29
     s=svd(A(i:i+29,:));
     tol=0.0001*max(s);
     rankA(i,1)=sum(s>tol);
     
 end
figure(1)
rankA=rankA(1:mA-30,1);
table=tabulate(rankA);
% rank1=min(table(:,1)):0.01:max(table(:,1));
% prank=interp(rank1)
plot(table(:,1),table(:,3)/100,'d-b','MarkerFaceColor','b');
tick={'N{_1}','N{_2}','W{_f}','EGT','T{_t1}','P{_t1}','OIP','OIT'};%,'VIB','PLA');
ylabel('����Ƶ��');
xlabel('����ֵ����M(k)����');
%%����2������Է���
acoor=corrcoef(A);
%��ֵ��ʹͼ�ι��ȸ���Ȼ
x=1:length(acoor);
x1=1:1:length(acoor);
[x2,y2]=meshgrid(x1,x1);
acoor1=interp2(x,x,acoor,x2,y2,'cubic');
grid on;

figure(2)
imagesc(1:8,1:8,acoor1); axis xy;
% colormap(gray(256));
colorbar;
% mesh(acoor1);
set(gca,'XTick',1:8);
set(gca,'YTick',1:8);

ylabel('�������');
xlabel('�������');
% set(gca,'XTickLabel',tick);
% set(gca,'YTickLabel',tick);

%%������ʼ�ľ���ֵab*X(1:6)==>X(7/8)
% ab=zeros(7,8);
% ab(:,7)=[M(:,1:6) ones(mA,1)]\M(:,7);
% ab(:,8)=[M(:,1:6) ones(mA,1)]\M(:,8);
% figure(3)
% plot(1:mA,M(:,7),'.r',1:mA,[M(:,1:6) ones(mA,1)]*ab(:,7),'.b');
% legend('7','7���');
% 
% figure(4)
% plot(1:mA,M(:,8),'.r',1:mA,[M(:,1:6) ones(mA,1)]*ab(:,8),'.b');
% legend('8','8���');
% save('ab.mat','ab');

figure(3)
plot(A(:,1:7),'LineWidth',2);
legend('n_{1,n}','n_{2,n}','W_{f,n}','EGT{_n}','T_{t1,n}','P_{t1,n}','OIP_n')
hold on;

plot(A(:,8),'m','LineWidth',2);
legend('n_{1,n}','n_{2,n}','W_{f,n}','EGT{_n}','T_{t1,n}','P_{t1,n}','OIP_n','OIT_n');
xlabel('����');
xlim([0 mA+1]);
ylabel('��һ������ֵ');
grid on;



