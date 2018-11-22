% clear;
% load steadypoint01.mat;
% B=B(1:20000,:);
T0=288.15;%标准大气总温，单位K，开氏温度
P0=1.013e3;%标准大气压，单位MBar,百帕
Br(:,[1 18 19 20])=[B(:,1) B(:,18) B(:,19) B(:,20)];
EGTr=[];WFr=[];N1r=[];N2r=[];
for i=1:3
    Br(:,1+i)=B(:,1+i);
    Br(:,5+i)=B(:,5+i);
    Br(:,9+i)=B(:,9+i);
    Br(:,13+i)=B(:,13+i);
    EGTr=[EGTr;Br(:,1+i)];
    WFr=[WFr;Br(:,5+i)];
    N1r=[N1r;Br(:,9+i)];
    N2r=[N2r;Br(:,13+i)];
end
Xr=[EGTr,WFr,N1r,N2r];
Xr(Xr(:,3)<75,:)=[];
% Xr(Xr(:,1)>1000,:)=[];
% Xr(Xr(:,2)>5000,:)=[];
% Xr(Xr(:,3)>120,:)=[];
% Xr(Xr(:,4)>120,:)=[];
Xr(isnan(Xr(:,3)),:)=[];
figure(1)
subplot(3,1,3)
y1=polyfit(Xr(:,3),Xr(:,1),2);
plot(Xr(:,3),Xr(:,1),'.r',Xr(:,3),polyval(y1,Xr(:,3)),'.b');
legend('Measure','model');
xlabel('N1r');
ylabel('EGTr');
grid on;
rmse1=norm(polyval(y1,Xr(:,3))-Xr(:,1))/sqrt(length(Xr)-1);

subplot(3,1,1)
y2=polyfit(Xr(:,3),Xr(:,2),2);
plot(Xr(:,3),Xr(:,2),'.r',Xr(:,3),polyval(y2,Xr(:,3)),'.b');
xlabel('N1r');
ylabel('FFr');
grid on;
rmse2=norm(polyval(y2,Xr(:,3))-Xr(:,2))/sqrt(length(Xr)-1);
legend('Measure','model');
% y1=polyfit(Xr(:,3),Xr(:,1),1);

subplot(3,1,2)
y3=polyfit(Xr(:,3),Xr(:,4),2);
plot(Xr(:,3),Xr(:,4),'.r',Xr(:,3),polyval(y3,Xr(:,3)),'.b');
xlabel('N1r');
ylabel('N2r');
grid on;
rmse3=norm(polyval(y3,Xr(:,4))-Xr(:,1))/sqrt(length(Xr)-1);
legend('Measure','model');
