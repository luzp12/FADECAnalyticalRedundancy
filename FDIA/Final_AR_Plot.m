close all;
nx=1
% DataJudgement=[DataJudgement(:,1:8) [0;0.25]];
label={'n_{1}','n_{2}','W_{f}','EGT','T_{t1}','P_{t1}','OIP','OIT'};
ts=m+10:ttotal-0;
figure(1)
step=floor(ttotal/200)*2;
time=1:length(M1);
time1=[step:2*step:8000 8000+step:step:floor(length(M1)/step)*step];
time2=time1-step/2;
plot(time1,M1(time1,nx),'^-b','MarkerFaceColor','b')
hold on;
plot(time2,M2(time2,nx),'d-r','MarkerFaceColor','r');
plot(time,A(time,nx),'-black','LineWidth',1.4);
gca1=legend('GROUSE','线性回归','实际','Location','NorthWest');
set(gca1,'FontSize',8);
if tfault<=ttotal
plot([tfault tfault],[0 1000],'--');
text(tfault,A(tfault,nx)*1.05,'故障发生','horiz','left','vert','bottom')
ylim([0.95*min(A(:,nx)) 1.1*max(A(:,nx))]);
end
xlim([m+10 ttotal-10]);
grid on;
xlabel('周期')
ylabel(label(nx));
set(gcf,'unit','centimeters','position',[10 5 13 10]);
figure(2)
ErrorM=[(M1(:,nx)-A(:,nx))/DataJudgement(2,nx) (M2(:,nx)-A(:,nx))/DataJudgement(2,nx)];

plot(ts,ErrorM(ts,1),'^-b','MarkerFaceColor','b');
hold on;
plot(ts,ErrorM(ts,2),'d-r','MarkerFaceColor','r');
gca2=legend('GROUSE','线性回归','Location','NorthWest');
set(gca2,'FontSize',8);

if tfault<=ttotal
plot([tfault tfault],[-100 100],'--');
text(tfault,ErrorM(tfault,1)+0.005,'故障发生','horiz','left','vert','bottom')
ylim([1.05*min(min(ErrorM)) 1.1*max(max(ErrorM))+0.005]);
end
xlim([m+10 ttotal-10]);
grid on;
xlabel('周期')
ylabel(strcat(label(nx),'相对误差'));

figure(3)
ErrorM_mean=mean(abs([(M1(ts,:)-A(ts,:))./repmat(DataJudgement(2,:),length(ts),1) (M2(ts,:)-A(ts,:))./repmat(DataJudgement(2,:),length(ts),1)]));
ErrorM_meany=[ErrorM_mean(1,1:n)' ErrorM_mean(1,1+n:2*n)' ];
bar(ErrorM_meany);
tick={'N_{1}','N_{2}','W_{f}','EGT','T_{t1}','P_{t1}','OIP','OIT'};
settick('x',tick);
% set(gca,'XTick',1:8);
% set(gca,'XTickLabel',{'N_{1}','N_{2}','W_{f}','EGT','T_{t1}','P_{t1}','OIP','OIT'});
gca3=legend('GROUSE','线性回归','Location','NorthWest');
set(gca3,'FontSize',8);
ylabel('平均相对误差');


% set(gca3,'YTickLabel',tick);
figure(4)
ErrorM_max=max(abs([(M1(ts,:)-A(ts,:))./repmat(DataJudgement(2,:),length(ts),1) (M2(ts,:)-A(ts,:))./repmat(DataJudgement(2,:),length(ts),1)]));
ErrorM_maxy=[ErrorM_max(1,1:n)' ErrorM_max(1,1+n:2*n)' ];
bar(ErrorM_maxy);
gca4=legend('GROUSE','线性回归','Location','NorthWest');
set(gca4,'FontSize',8);
ylabel('最大相对误差');
settick('x',tick);



% figure(3)
% plot(time,M1(:,nx),'-b',time,M2(:,nx),'-r',time,A(:,nx),'-black');
% legend('GROUSE','在线拟合','实际');
% xlim([m+10 ttotal-10]);

figure(5)
ErrorP1=reshape(((M1(ts,:)-A(ts,:))./repmat(DataJudgement(2,:),length(ts),1)),length(ts)*n,1);
ErrorP1=roundn(ErrorP1,-3);
ErrorP2=reshape(((M2(ts,:)-A(ts,:))./repmat(DataJudgement(2,:),length(ts),1)),length(ts)*n,1);
ErrorP2=roundn(ErrorP2,-3);
table1=tabulate(ErrorP1);
table2=tabulate(ErrorP2);
plot(table1(:,1),log10(table1(:,3)/100),'b');
hold on;
plot(table2(:,1),log10(table2(:,3)/100),'r');
grid on;
ylim([-5 0]);
Ytick=-4:0;
set(gca,'Yticklabel',{'','','0.0001','','0.001','','0.01','','0.1','','1'});
gca5=legend('GROUSE','线性回归','Location','NorthWest');
set(gca5,'FontSize',8);
xlabel('相对误差')
ylabel('出现频率')

set(gcf,'unit','centimeters','position',[10 5 13 10]);

fprintf('GROUSE Error>>>mean: %d , max: %d,\n',mean(abs(ErrorM(ts,1))),max(abs(ErrorM(ts,1))));
fprintf('OMIK Error>>>mean: %d , max: %d,\n',mean(abs(ErrorM(ts,2))),max(abs(ErrorM(ts,2))));
