figure(1)
plot(data(:,3),log10(data(:,4)),'^-r',data(:,3),log10(data(:,5)),'*-');
legend('SVT','Grouse');
xlabel('Sample Rate','FontName','Times New Roman','FontSize',14);
ylabel('log(RMSE)','FontName','Times New Roman','FontSize',14);
xlim([0.2 0.9]);
set(gca, 'XTick',0.2:0.1:0.9)
set(gca,'XTickLabel',{'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'});
% set(gca,'XTickLabel',{'1¡Á1','2¡Á2','5¡Á5','5¡Á10','10¡Á10','10¡Á20'});



figure(2)
plot(data(:,3),data(:,6),'^-r',data(:,3),data(:,7),'*-');
legend('SVT','Grouse');
xlabel('Sample Rate','FontName','Times New Roman','FontSize',14);
ylabel('\Delta_{r}','FontName','Times New Roman','FontSize',14);
% set(gca, 'XTick',1:6)
%set(gca,'XTickLabel',{'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'});
ylim([0 4]);
set(gca, 'YTick',0:4)
xlim([0.2 0.9]);
set(gca, 'XTick',0.2:0.1:0.9)
set(gca,'XTickLabel',{'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'});



figure(3)
plot(data(:,3),data(:,8),'^-r',data(:,3),data(:,9),'*-');
legend('SVT','Grouse');
xlabel('Sample Rate','FontName','Times New Roman','FontSize',14);
ylabel('Run time t /s ','FontName','Times New Roman','FontSize',14);
xlim([0.2 0.9]);
set(gca, 'XTick',0.2:0.1:0.9)
set(gca,'XTickLabel',{'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'});
% set(gca,'XTickLabel',{'1¡Á1','2¡Á2','5¡Á5','5¡Á10','10¡Á10','10¡Á20'});