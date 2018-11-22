% function [T48,Nlnew,Nhnew]   = CF600Model(Rundata,T,N1r,N2r,WFr,EGTr,N1model)
clear;
close all;
load 'abcd1120.mat';%1113�ᷢɢ����
load 'AR_test1120.mat';
load 'steadyreflection1112.mat';
%% ��������
% Simulationtime step=0.25;%������
Ar_test=Ar_test(1:3000,:);
%%��ʼ��
EGTrnew=Ar_test(1,1);
N1rnew=Ar_test(1,3);
N2rnew=Ar_test(1,4);
Ar_model=zeros(length(Ar_test),4);
% Ar_model(1,:)=Ar_test(1,:);
N1rmodel=Ar_test(1,3);

% ѭ���������
for t=1:length(Ar_test)
%% ����ת��������
N1r=N1rnew;
N2r=N2rnew;
EGTr=EGTrnew;
WFr=Ar_test(t,2);
% WFr=32.2082+floor(t/50)*0.2;
%% ȷ��ģ�Ͳ���
%���㵱ǰN1r��Ӧ����ֵ̬��EGTr��WFr��N2r.
EGTrsteady=y1(1,1)*N1r^2+y1(1,2)*N1r+y1(1,3);
WFrsteady=y2(1,1)*N1r^2+y2(1,2)*N1r+y2(1,3);
N2rsteady=y3(1,1)*N1r^2+y3(1,2)*N1r+y3(1,3);

%ͨ��EGTr��WFr��N2r��ֵ̬�뵱ǰֵ�Ա��жϵ�ǰ״̬�Ƿ�Ϊ��̬:��ֵ2%
%���ǣ���ģ�Ͳ����滻Ϊ��ǰN1r��Ӧ�Ĳ�������������֮ǰ����
if max(abs([(EGTr-EGTrsteady)/EGTrsteady (WFr-WFrsteady)/WFrsteady (N2r-N2rsteady)/N2rsteady]))<0.1
N1rmodel=N1r;  
end

%����ȷ����N1model��ֵ����ģ�Ͳ���
P_ABCD=zeros(1,9);
for i=1:9
    P_ABCD(i)=interp1(abcd(:,1),abcd(:,i+1),50,'spline');
end
%% ģ�ͼ���
%������̬��׼��
EGTrmodel=y1(1,1)*N1rmodel^2+y1(1,2)*N1rmodel+y1(1,3);
WFrmodel=y2(1,1)*N1rmodel^2+y2(1,2)*N1rmodel+y2(1,3);
N2rmodel=y3(1,1)*N1rmodel^2+y3(1,2)*N1rmodel+y3(1,3);

%����ƫ����du(k)��dx(k)��dy(k)
dumodel=WFr-WFrmodel;
dxmodel=[N1r-N1rmodel;N2r-N2rmodel];

%����dx(k+1)��dy(k)

dx1model=[P_ABCD(1:3);P_ABCD(4:6)]*[dxmodel;dumodel];
%dx1model=[-3.8557,1.4467,1;0.4690,-4.7081,1]*[dxmodel;dumodel];
dymodel=P_ABCD(7:9)*[dxmodel;dumodel];

%% ���������
EGTrnew=EGTrmodel+dymodel;
N1rnew=N1rmodel+dx1model(1);
N2rnew=N2rmodel+dx1model(2);
Ar_model(t,:)=[EGTrnew WFr N1r N2r];
end

figure(1)
label={'EGT{_r}','FF{_r}','N1{_r}','N2{_r}'};
corrresult=zeros(4,1);
xtime=(1:length(Ar_model)).*0.25;
for i=1:4
    subplot(2,2,i)
    h1=plot(xtime,Ar_test(:,i),'black');
%     xlim([100,length(Ar_model)]);
    hold on;
    
    [AX,h2,h3]=plotyy(xtime,Ar_model(:,i),xtime,(Ar_model(:,i)-Ar_test(:,i))./Ar_test(:,i));
    set(h2,'color','red');
    set(h3,'color','blue','linestyle','--');
    h=[h1 h2 h3];
    legend(h,'Measure','Model','error')
    grid on;
    xlabel('Time');
    ylabel(label(i));
%     xlim([100,length(Ar_model)]);
    corrresult(i)=corr(Ar_model(:,i),Ar_test(:,i),'type','Spearman');
    
end

% [~,lambda]=eig([P_ABCD(1),P_ABCD(2);P_ABCD(4),P_ABCD(5)]);
% % [~,lambda]=eig([-3.8557,1.4467;0.4690,-4.7081]);
% rou=max(max(abs(lambda)))



