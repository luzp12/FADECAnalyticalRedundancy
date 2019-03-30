clear;
close all;
%��������
load Data01.mat;
load DataJudgement.mat;
load RXY.mat;
nx=8;
%�ܱ�����,����n��������
AR_Sensor=nx;
n=8;
M=A(:,1:n);
Data=M;
Mc=zeros(size(M));
%1:n-1
%��������������,�ӿռ�ά��,��ʼ���ӿռ�
m=30;maxrank=6;
U =orth(randn(m,maxrank));
%Ԥ��������ù۲����
Omega=ones(m,n);
% Omega(m,AR_Sensor)=0;
%Ȩ��ϵ������
Psai0=diag([ones(1,m)]);
%  Psai0=diag([1:0.04:2.16]);
P=10^6.*eye(m-1,m-1);
NoUpdate=[];
%%��ʼ����
% M(20*m:length(M),nx)=0;
Mc=M;
for k=m:length(M)
  %��ȡ��������
  if k<20*m
  AR_Sensor=[];
  else
  AR_Sensor=nx;
  end
%       if m-k+20*m>=1
%       Omega(m-k+20*m,AR_Sensor)=0;
%       else
%           NoUpdate=nx;
%       end
%   end
%   S_Sensor=1:8;
%   S_Sensor(AR_Sensor)=[];
  Mk=M(k-m+1:k,:);
  if k>=20*m
  Mk(m,AR_Sensor)=(Data(k,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor);
  end
  %��һ��
  [NMk,minMk,maxMk]=NormalData(Mk);
  %����
  
  [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,[]);
  %����һ��
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  Mc(k-m+1:k,:)=Mkc;
  M(k,AR_Sensor)=Mc(k,AR_Sensor);
%  if k>=20*m
%   Mguess=(Data(1:20*m-1,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor);
%   Mguessk=(Data(k,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor);
% %   ab=[Mc(1:20*m-1,AR_Sensor) Mguess]\M(1:20*m-1,AR_Sensor);
%     ab=[1 ;0];
%   M(k,AR_Sensor)=[Mkc(m,AR_Sensor) Mguessk]*ab;
%  else
%      M(k,AR_Sensor)=Mkc(m,AR_Sensor);
%  end
 
%   if k>=20*m
%     %===============�������˲���=================
%     %  STEP1:����ģ�Ͳ���
%     %���� A: x=Ax
%     U1=U(1:m-1,:);
%     U2=U(2:m,:);
%     A=U2/(U1'*U1)*U1';
% %     U2=U(m,:);
% %     A=[zeros(m-2,1) eye(m-2,m-2);U2/(U1'*U1)*U1'];
%     [~,lambda]=eig(A);
%     rou=max(max(abs(lambda)));
%     %����H: z=Hx+e
%     H=[zeros(1,m-2) RXY(2,AR_Sensor)];%RXY(2,AR_Sensor)*eye(m-1,m-1);
%     %     %�������
%     Q=10*diag([zeros(1,m-2) 1]);%1*eye(m-1,m-1);
% %     R=diag([ones(1,m-2) 1]);%0.5*eye(m-1,m-1);
%     R=1;
% 
%     %����Э�������Pguess:m-1*m-1
%     
%     Pguess=A*P*A'+Q;
% 
%     %��������K:
%     K=Pguess*H'/(H*Pguess*H'+R);
%     %����Э�������
%     P=(eye(m-1)-K*H)*Pguess;     
% 
% %     %״̬����
%     M_guess=A*M(k-m+1:k-1,AR_Sensor);%Ms3nH(49,1);
%     M_update=M_guess+K*(Data(k,RXY(1,AR_Sensor))-RXY(3,AR_Sensor)-H*M_guess(1:m-1,1));
% 
%     M(k,nx)=M_update(m-1,1);
%     M(1:20*m-1,:)=Data(1:20*m-1,:);
%   end
end
ny=RXY(1,AR_Sensor);
% 
%  Mguess=(Data(m:length(M),RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor);
%  ab=[Mc(m:length(M),AR_Sensor) ]\(M(m:length(M),AR_Sensor)-0.9*Mguess);

figure(1)
% for AR_Sensor=1:n-1
    time=1:length(M(:,AR_Sensor));
% subplot(4,2,AR_Sensor)
plot(time,Mc(:,AR_Sensor),'.g',time,M(:,AR_Sensor),'-b',time,Data(:,AR_Sensor),'-r',time,(M(:,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor),'-black');

xlim([20*m k-m]);
% ylim([min(Data(:,AR_Sensor))  max(Data(:,AR_Sensor))])
% end
legend('����','�˲�����','ʵ��','��̬ģ��');

figure(2)
plot( [(M(:,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor)  ((Data(:,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor) ]);
 legend('�˲�����','��̬ģ��');
xlim([20*m  k-m]);

% fprintf('Average error of KF ��%d \n',norm(abs((M(:,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor)))/length(time));
% fprintf('Max error of KF ��%d \n',max(abs((M(:,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor))));
% fprintf('Average error of SM ��%d \n',norm( abs(((M(:,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor)))/length(time));
% fprintf('Max error of SM ��%d \n',max( abs(((M(:,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor))));