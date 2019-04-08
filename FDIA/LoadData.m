clear;
close all;
addpath('../data/Tail_687_2');
load DataJudgement.mat;
path = 'D:\FADECAnalyticalRedundancy\data\Tail_687_2\';
fext = '*.mat';
dt = dir([path fext]);
pt = {dt.name};
% T0=288.15;%标准大气总温，单位K，开氏温度
% P0=1.013;%标准大气压，单位MBar,百帕
%%只加载第一次飞行数据即可
nA=8;
% DataJudgement=[DataJudgement(:,1:nA) [0;0.25]];
for k =33
    load(dt(k).name);
    M=length(FF_1.data);
    A=zeros(M,nA);
    %数据加载，同时插值
    A(:,1)=N1_1.data;
    A(:,2)=N2_1.data;
    A(:,3)=FF_1.data;
    A(:,4)=EGT_1.data+273.15;
    A(:,5)=interp1(1:length(TAT.data),TAT.data,0.25:0.25:length(TAT.data),'spline')+273.15;
    A(:,6)=interp1(1:length(PT.data),PT.data,0.5:0.5:length(PT.data),'spline');
    A(:,7)=interp1(1:length(OIP_1.data),OIP_1.data,0.25:0.25:length(OIP_1.data),'linear');
    A(:,8)=interp1(1:length(OIT_1.data),OIT_1.data,0.25:0.25:length(OIT_1.data),'spline')+273.15;
%     A(:,9)=PLA_1.data;
%     A(:,9)=smooth(VIB_1.data,30); 
%     A(:,9)=VIB_1.data; 
end 
%%方便观察数据，归一化后绘图
A=A(1500:22000,:);
close all;
figure(1)
plot(A(:,[1 2 3 4])*diag(1./DataJudgement(2,[1 2 3 4])));

hold on ;
plot(ALT.data/30000,'black');
plot(PLA_1.data/100,'yellow');
plot(MACH.data,'m');
legend('N1','N2','FF','EGT','ALT','PLA','MACH');%,'TAT','PT','OIP','OIT');
%%截取数据并保存，原始数据->提取->插值->截取
grid on;
figure(2)
plot(A(:,[6 7 8 ])*diag(1./DataJudgement(2,[6 7 8 ])));
legend('PT','OIP','OIT');
ylim([0.3 1.1])
%去除坏点
Fn=100;
for i=3000:length(A);
%     Amean=mean(A(i-Fn+1:i-1,:));
%     Asigma=std(A(i-Fn+1:i-1,:));
%      for k=6:nA
%         if abs(A(i,k)-Amean(1,k))>3*Asigma(1,k)
%                  A(i,k)= A(i-1,k);
%         end
%      end
    for k=6:nA
          if A(i,k)<DataJudgement(1,k)||A(i,k)>DataJudgement(2,k)||abs(A(i,k)-A(i-1,k))>0.015*DataJudgement(2,k)
             A(i,k)= A(i-1,k);
          end
    end
end


figure(3)
plot(A(:,[6 7 8 ])*diag(1./DataJudgement(2,[6 7 8])));
legend('PT','OIP','OIT');
 
A(:,7)=smooth(A(:,7),30);
A(:,8)=smooth(A(:,8),50);
% A(:,9)=smooth(A(:,9),50);

figure(4)
plot(A(:,[6 7 8])*diag(1./DataJudgement(2,[6 7 8])));
legend('PT','OIP','OIT');


%  save('Data02.mat','A');
 

%  figure(4)
% plot(A*diag(1./DataJudgement(2,:)));
% legend('N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA');

% DataJudgement=[mean(A);min(A);max(A)];