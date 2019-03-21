clear;
path = 'D:\FADECAnalyticalRedundancy\data\Tail_687_2\';
fext = '*.mat';
dt = dir([path fext]);
pt = {dt.name};
N=4;
B=[];
T0=288.15;%标准大气总温，单位K，开氏温度
P0=1.013;%标准大气压，单位MBar,百帕
for k = 1:1
    load(dt(k).name);
    M=length(FF_1.data);
        A=zeros(M,N);
        % B=zeros(100,N);
        %将目标变量提取到A矩阵
        A(:,1)=N1_1.data;
        A(:,2)=FF_1.data./100;
        A(:,3)=interp1(1:length(OIP_1.data),OIP_1.data,0.25:0.25:length(OIP_1.data),'linear');
        A(:,4)=interp1(1:length(OIT_1.data),OIT_1.data,0.25:0.25:length(OIT_1.data),'linear');
        A(:,5)=VIB_1.data.*100;
        %A(:,6)=interp1(1:length(FIRE_1.data),FIRE_1.data,0.25:0.25:length(FIRE_1.data),'linear');
        A(:,6)=MACH.data.*100;
        A(:,7)=PLA_1.data./8;
        A(:,8)=interp1(1:length(PT.data),PT.data,0.5:0.5:length(PT.data),'linear')./10;
        A(:,9)=interp1(1:length(TAT.data),TAT.data,0.25:0.25:length(TAT.data),'linear');
        
end
A=A(3000:10000,:);
plot(A(:,[2 8 9]));
legend('N1','FF','OIP','OIT','VIB','MACH','PLA','PT','TAT');
acoor=corrcoef(A);