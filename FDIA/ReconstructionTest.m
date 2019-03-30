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
ab(:,nx)
%����۲�ĵ���������
M=A;
%tfault����֮�����ݶ�ʧ
tfault=10000;
M(tfault:length(M),nx)=0;
P=10^6.*eye(7,7);
%%��ʼ����
for k=1:length(M)
  %������δ����ʱ�����ÿ������˲�����ģ��
  if k <tfault&&abs((M(k,nx)-[M(k,1:6) 1]*ab(:,nx)))>0.01*DataJudgement(2,nx)
    %====����ģ�Ͳ���====
    %���� A: x=Ax,7*7
    Aab=eye(7,7);
    %����H: z=Hx+e,1*7
    H=[M(k,1:6) 1];
    %====������������====
    Q=0*eye(7,7);
    R=0.001;
    %====����Э�������Pguess:7*7====
    Pguess=Aab*P*Aab'+Q;
    %====��������K:====
    K=Pguess*H'/(H*Pguess*H'+R);
    %====����Э�������====
    P=(eye(7)-K*H)*Pguess;     
    %====״̬����====
    ab(:,nx)=ab(:,nx)+K*(M(k,nx)-H*ab(:,nx));
    %�����Ϸ���ʱ�����õ�ǰģ�Ͳ����ع��ź�
    
  end
  M(k,nx)=[M(k,1:6) 1]*ab(:,nx);
end

figure(1)
time=1:length(M);

plot(time,M(:,nx),'-b',time,A(:,nx),'-r',time,(A(:,RXY(1,nx))-RXY(3,nx))/RXY(2,nx),'-black');

legend('���ģ��','ʵ��','��̬ģ��');

figure(2)
plot( [(M(:,nx)-A(:,nx))/DataJudgement(2,nx)  ((A(:,RXY(1,nx))-RXY(3,nx))/RXY(2,nx)-A(:,nx))/DataJudgement(2,nx) ]);
legend('������','��̬���');