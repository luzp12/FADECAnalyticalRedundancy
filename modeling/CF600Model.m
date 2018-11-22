% function [T48,Nlnew,Nhnew]   = CF600Model(Rundata,T,N1r,N2r,WFr,EGTr,N1model)
clear;
close all;
load 'abcd1120.mat';%1113会发散！！
load 'AR_test1120.mat';
load 'steadyreflection1112.mat';
%% 参数设置
% Simulationtime step=0.25;%仿真间隔
Ar_test=Ar_test(1:3000,:);
%%初始化
EGTrnew=Ar_test(1,1);
N1rnew=Ar_test(1,3);
N2rnew=Ar_test(1,4);
Ar_model=zeros(length(Ar_test),4);
% Ar_model(1,:)=Ar_test(1,:);
N1rmodel=Ar_test(1,3);

% 循环仿真计算
for t=1:length(Ar_test)
%% 处理转换输入量
N1r=N1rnew;
N2r=N2rnew;
EGTr=EGTrnew;
WFr=Ar_test(t,2);
% WFr=32.2082+floor(t/50)*0.2;
%% 确定模型参数
%计算当前N1r对应的稳态值：EGTr、WFr、N2r.
EGTrsteady=y1(1,1)*N1r^2+y1(1,2)*N1r+y1(1,3);
WFrsteady=y2(1,1)*N1r^2+y2(1,2)*N1r+y2(1,3);
N2rsteady=y3(1,1)*N1r^2+y3(1,2)*N1r+y3(1,3);

%通过EGTr、WFr、N2r稳态值与当前值对比判断当前状态是否为稳态:阈值2%
%若是，则将模型参数替换为当前N1r对应的参数，否则沿用之前参数
if max(abs([(EGTr-EGTrsteady)/EGTrsteady (WFr-WFrsteady)/WFrsteady (N2r-N2rsteady)/N2rsteady]))<0.1
N1rmodel=N1r;  
end

%根据确定的N1model插值计算模型参数
P_ABCD=zeros(1,9);
for i=1:9
    P_ABCD(i)=interp1(abcd(:,1),abcd(:,i+1),50,'spline');
end
%% 模型计算
%计算稳态基准点
EGTrmodel=y1(1,1)*N1rmodel^2+y1(1,2)*N1rmodel+y1(1,3);
WFrmodel=y2(1,1)*N1rmodel^2+y2(1,2)*N1rmodel+y2(1,3);
N2rmodel=y3(1,1)*N1rmodel^2+y3(1,2)*N1rmodel+y3(1,3);

%计算偏差量du(k)、dx(k)、dy(k)
dumodel=WFr-WFrmodel;
dxmodel=[N1r-N1rmodel;N2r-N2rmodel];

%计算dx(k+1)、dy(k)

dx1model=[P_ABCD(1:3);P_ABCD(4:6)]*[dxmodel;dumodel];
%dx1model=[-3.8557,1.4467,1;0.4690,-4.7081,1]*[dxmodel;dumodel];
dymodel=P_ABCD(7:9)*[dxmodel;dumodel];

%% 更新输出量
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



