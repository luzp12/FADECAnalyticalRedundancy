figure(1)
plot(0:6,log10(data(:,4)),'^-r',0:6,log10(data(:,5)),'*-');
set(gcf,'unit','normalized','position',[0.2,0.2,0.24,0.24])
legend('SVT','Grouse');
xlabel('Rank','FontName','Times New Roman','FontSize',14);
ylabel('log(RMSE)','FontName','Times New Roman','FontSize',14);
set(gca, 'XTick',0:6)
set(gca,'XTickLabel',{'1','2','5','8','10','15','20'});
% set(gca,'XTickLabel',{'1¡Á1','2¡Á2','5¡Á5','5¡Á10','10¡Á10','10¡Á20'});



figure(2)
plot(0:6,data(:,6),'^-r',0:6,data(:,7),'*-');
set(gcf,'unit','normalized','position',[0.2,0.2,0.24,0.24])
legend('SVT','Grouse');
xlabel('Rank','FontName','Times New Roman','FontSize',14);
ylabel('\Delta_{r}','FontName','Times New Roman','FontSize',14);
% set(gca, 'XTick',1:6)
%set(gca,'XTickLabel',{'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'});
ylim([0 6]);
set(gca, 'YTick',0:6)
set(gca, 'XTick',0:6)
set(gca,'XTickLabel',{'1','2','5','8','10','15','20'});



figure(3)
plot(0:6,data(:,8),'^-r',0:6,data(:,9),'*-');
set(gcf,'unit','normalized','position',[0.2,0.2,0.24,0.24])
legend('SVT','Grouse');
xlabel('Rank','FontName','Times New Roman','FontSize',14);
ylabel('Run time t /s ','FontName','Times New Roman','FontSize',14);
set(gca, 'XTick',0:6)
set(gca,'XTickLabel',{'1','2','5','8','10','15','20'});
% set(gca,'XTickLabel',{'1¡Á1','2¡Á2','5¡Á5','5¡Á10','10¡Á10','10¡Á20'});