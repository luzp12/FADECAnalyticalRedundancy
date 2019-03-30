clear;
close all;
load DataJudgement.mat;
addpath('../data/Tail_687_2');
path = 'D:\FADECAnalyticalRedundancy\data\Tail_687_2\';
fext = '*.mat';
dt = dir([path fext]);
pt = {dt.name};
RXY=zeros(3,8);
T0=288.15;%标准大气总温，单位K，开氏温度
P0=1.013e3;%标准大气压，单位MBar,百帕
%%只加载第一次飞行数据即可
nA=8;
DataJudgement=DataJudgement(:,1:nA);
DataSteady=zeros(100000:nA);
Dk=0;
for k =1:200
   
    load(dt(k).name);
    if max(TAS.data)>200
    M=length(FF_1.data);
    A=zeros(M,nA);
    %数据加载，同时插值
    A(:,1)=[N1_1.data];%N1_2.data ;N1_3.data ;N1_4.data];
    A(:,2)=[N2_1.data];%N2_2.data ;N2_3.data ;N2_4.data];
    A(:,3)=[FF_1.data];%FF_2.data ;FF_3.data ;FF_4.data];
    A(:,4)=[EGT_1.data];%EGT_2.data;EGT_3.data;EGT_4.data]+273.15;
    A(:,5)=repmat(interp1(1:length(TAT.data),TAT.data,0.25:0.25:length(TAT.data),'spline'),1,1)'+273.15;
    A(:,6)=repmat(interp1(1:length(PT.data),PT.data,0.5:0.5:length(PT.data),'spline'),1,1)';
    A(:,7)=interp1(1:length(OIP_1.data),OIP_1.data ,0.25:0.25:length(OIP_1.data),'spline');
    A(:,8)=interp1(1:length(OIT_1.data),OIT_1.data,0.25:0.25:length(OIT_1.data),'spline')+273.15;
    A=A(find(A(:,1)>50),:);
    M=length(A); 
    %寻找稳态点
    Fn=40;
    for i=1:floor(M/Fn);
        Amean=mean(A(Fn*(i-1)+1:Fn*i,:));
        %当该组矩阵Fn*nA的所有元素的最大相对误差小于2%时，认为发动机处于稳态
       if max(max(abs((A(Fn*(i-1)+1:Fn*i,:)-repmat(Amean,Fn,1))./repmat(DataJudgement(2,1:nA),Fn,1))))<0.02
           Dk=Dk+1;
           DataSteady(Dk,:)=Amean;
       end
    end
    else
    k
    end 
end
DataSteady=DataSteady(1:Dk,:);
%%方便观察数据，归一化后绘图
figure(1)
plot(DataSteady*diag(1./DataJudgement(2,1:nA)));
legend('N1','N2','FF','EGT','TAT','PT','OIP','OIT');

coor=corrcoef(DataSteady);
%%OIP
nx=7;ny=find(abs(coor(nx,1:6))==max(abs(coor(nx,1:6))))
rxy7=polyfit(DataSteady(:,nx),DataSteady(:,ny),1);
figure(2)
plot(DataSteady(:,nx),DataSteady(:,ny),'.r',DataSteady(:,nx),rxy7(1,1).*DataSteady(:,nx)+rxy7(1,2),'.b');
title('OIP')
rmse=norm(polyval(rxy7,DataSteady(:,nx))-DataSteady(:,ny))/sqrt(Dk)
RXY(:,nx)=[ny;rxy7'];
%OIT
nx=8;ny=find(abs(coor(nx,1:6))==max(abs(coor(nx,1:6))))
rxy8=polyfit(DataSteady(:,nx),DataSteady(:,ny),1);
figure(3)
plot(DataSteady(:,nx),DataSteady(:,ny),'.r',DataSteady(:,nx),rxy8(1,1).*DataSteady(:,nx)+rxy8(1,2),'.b');
title('OIT')
rmse=norm(polyval(rxy8,DataSteady(:,nx))-DataSteady(:,ny))/sqrt(Dk)
RXY(:,nx)=[ny;rxy8'];


DataSteadyR=DataSteady;
%相似变换
% 'N1','N2','FF','EGT','TAT','PT','OIP','OIT';
 DataSteadyR(:,1)=DataSteady(:,1).*(T0./DataSteady(:,5)).^0.5;
 DataSteadyR(:,2)=DataSteady(:,2).*(T0./DataSteady(:,5)).^0.5;
 DataSteadyR(:,3)=DataSteady(:,3).*(T0./DataSteady(:,5)).^0.5.*P0./DataSteady(:,6);
 DataSteadyR(:,4)=DataSteadyR(:,4).*(T0./DataSteady(:,5));
 DataSteadyR(:,5)=T0;
 DataSteadyR(:,6)=P0;
 DataSteadyR(:,7)=DataSteady(:,7).*P0./DataSteady(:,6);
 DataSteadyR(:,8)=DataSteady(:,8).*(T0./DataSteady(:,5));
coorR=corrcoef(DataSteadyR);
coorall=corrcoef([DataSteady DataSteadyR]);
%  
nx=7;ny=8;find(abs(coorR(nx,1:6))==max(abs(coorR(nx,1:6))))
rxy7r=polyfit(DataSteadyR(:,nx),DataSteadyR(:,ny),1);
figure(4)
plot(DataSteadyR(:,nx),DataSteadyR(:,ny),'.r',DataSteadyR(:,nx),rxy7r(1,1).*DataSteadyR(:,nx)+rxy7r(1,2),'.b');
title('OIP-R')
rmse=norm(polyval(rxy7r,DataSteadyR(:,nx))-DataSteadyR(:,ny))/sqrt(Dk)
%OIT
nx=8;ny=7;find(abs(coorR(nx,1:6))==max(abs(coorR(nx,1:6))))
rxy8r=polyfit(DataSteadyR(:,nx),DataSteadyR(:,ny),1);
figure(5)
plot(DataSteadyR(:,nx),DataSteadyR(:,ny),'.r',DataSteadyR(:,nx),rxy8r(1,1).*DataSteadyR(:,nx)+rxy8r(1,2),'.b');
title('OIT-R')
rmse=norm(polyval(rxy8r,DataSteadyR(:,nx))-DataSteadyR(:,ny))/sqrt(Dk)
save('RXY.mat','RXY');