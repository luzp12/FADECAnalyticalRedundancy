%�������߽�ģ������Ч����
%��һ��Ч����������ҪԶѷ��GROUSE�����߶���������������Ƶģ����Ƕ��ӿռ����ⷽʽ��һ����

clear;
close all;
%��������
load Data01.mat;
load DataJudgement.mat;
load RXY.mat;
load ab.mat

%�ܱ�����,����n��������
n=8;
nx=8;
%����۲�ĵ���������
A=A(:,:);
M=A;
%tfault����֮�����ݶ�ʧ
tfault=10000;
% M(tfault:length(M),nx)=0;
P=10^6.*eye(8,8);
m=30;
%%��ʼ����
sx=[1:n];
sx(nx)=[];
% sx=1:6;
ab=ones(8,1);
ab=[A(1:100,sx) ones(100,1)]\A(1:100,nx);
for k=m:length(M)
  %������δ����ʱ�����ÿ������˲�����ģ��
%   if  abs((A(k,nx)-[A(k,ns) 1]*ab))>0.01*DataJudgement(2,nx)
    %====����ģ�Ͳ���====
    %���� A: x=Ax,7*7
    Mk=A(k-m+1:k,:);
    [NMk,minMk,maxMk]=NormalData(Mk);
%     NMk=Mk;
    Aab=eye(8,8);
    %����H: z=Hx+e,1*7
    H=[NMk(1:m-1,sx) ones(m-1,1)];
    %====������������====
    Q=0.001*eye(8,8);
    R=0.001*eye(29,29);
    %====����Э�������Pguess:7*7====
    Pguess=Aab*P*Aab'+Q;
    %====��������K:====
    K=Pguess*H'/(H*Pguess*H'+R);
    %====����Э�������====
    P=(eye(8)-K*H)*Pguess;     
    %====״̬����====
    ab=ab+K*(NMk(1:m-1,nx)-H*ab);
    %�����Ϸ���ʱ�����õ�ǰģ�Ͳ����ع��ź�
    
%   end
  
%   ab=[NMk(1:m-1,sx) ones(m-1,1)]\NMk(1:m-1,nx);
  NMk(m,nx)=[NMk(m,sx) 1]*ab;
  [Mkc]=AntiNormalData(NMk,minMk,maxMk);
%   Mkc=NMk;
  M(k,nx)=Mkc(m,nx);
  
end

figure(1)
time=1:length(M);

plot(time,M(:,nx),'-b',time,A(:,nx),'-r');

legend('���ģ��','ʵ��');
xlim([m+10 length(M)]);
figure(2)
plot( (M(:,nx)-A(:,nx))/DataJudgement(2,nx));
legend('������','��̬���');
xlim([m+10 length(M)]);