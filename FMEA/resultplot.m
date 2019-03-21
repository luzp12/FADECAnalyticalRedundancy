figure(1)
x1=[[1:5:41] [2:5:42]];
x2=[[3:5:43] [4:5:44] [5:5:45]];
plot(x1,rank2(x1),'bo',x2,rank2(x2),'ro',[1:45],40*ones(45,1),'black--');

set(gca,'Xtick',[0:5:45],'Ytick',[0:40:120]);
xlabel('���ϱ��');
ylabel('RPN');
legend('Ӳ����','������');
% set(gca,'YTickLabel',{'10','40','70','100','130'}) ;
% x=find(rank2>40);
% 
% str=[num2str(x)]; %repmat(':',length(x),1) num2str(rank2(x))
% 
%  text(x',rank2(x)+(rem(x,2)-0.5)*10,cellstr(str)');
figure(2)
scatter3(rank15(:,2),rank15(:,3),rank15(:,4),'ro');
xlabel('O');
ylabel('S');
zlabel('D');
xlim([1 10]);
ylim([1 10]);
zlim([1 10]);
str=['3';' ,4';'5';'10';'13';'14';'15';'33';'34';'  ,35';'     ,38';'        ,39';'           ,40';'              ,43';'                 ,44';'                    ,45'];
text(rank15(:,2),rank15(:,3)+rem(rank15(:,1),2)*0,rank15(:,4)+rem(rank15(:,1),2)*0,str);
