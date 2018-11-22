clear;
path = 'D:\FADECAnalyticalRedundancy\data\Tail_687_2\';
fext = '*.mat';
dt = dir([path fext]);
pt = {dt.name};
N=12;
B=[];
T0=288.15;%标准大气总温，单位K，开氏温度
P0=1.013;%标准大气压，单位MBar,百帕
for k = 1:602
    load(dt(k).name);
    M=length(ECYC_1.data);
        A=zeros(M,N);
        % B=zeros(100,N);
        %将目标变量提取到A矩阵
        A(:,1)=ECYC_1.data;
        A(:,2)=ECYC_2.data;
        A(:,3)=ECYC_3.data;
        A(:,4)=ECYC_4.data;
        A(:,5)=EHRS_1.data;
        A(:,6)=EHRS_2.data;
        A(:,7)=EHRS_3.data;
        A(:,8)=EHRS_4.data;
        A(:,9)=ESN_1.data;
        A(:,10)=ESN_2.data;
        A(:,11)=ESN_3.data;
        A(:,12)=ESN_4.data;
        B=[B;max(A)];
%         if max(A(:,9:12)>0)
end
% B=B(2:length(B),:);

%%结论：#4发动机运行时长与前三个不同，建模时剔除
figure(1)
subplot(1,2,1)
plot(1:length(B),B(:,1),1:length(B),B(:,2),'^',1:length(B),B(:,3),'*',1:length(B),B(:,4));
ylabel('ECYC');
xlabel('Flight Number');
legend('#1','#2','#3','#4');
xlim([1 100]);

subplot(1,2,2)
plot(1:length(B),B(:,5),1:length(B),B(:,6),'^',1:length(B),B(:,7),'*',1:length(B),B(:,8));
ylabel('EHRS');
xlabel('Flight Number');
legend('#1','#2','#3','#4');
xlim([1 100]);
figure(2)
plot(1:length(B),B(:,9),1:length(B),B(:,10),1:length(B),B(:,11),1:length(B),B(:,12));
ylabel('ESN');
xlabel('Flight Number');
legend('#1','#2','#3','#4');
ylim([7700 8200]);

