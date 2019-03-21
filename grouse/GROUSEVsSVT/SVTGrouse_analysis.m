figure(1)

% plot(1:7,log10(data(:,3)),'or',1:7,log10(data(:,4)),'*b');
bar([log10(data(:,3))+16 log10(data(:,4))+16]);
legend('SVT','Grouse');
xlabel('算例类型','FontName','Times New Roman','FontSize',14);
ylabel('log(RMSE)','FontName','Times New Roman','FontSize',14);
set(gca, 'XTick',1:7)
set(gca,'XTickLabel',{'1' '2','3','4','5','6','7'});
set(gca, 'YTick',0:2:18)
set(gca,'YTickLabel',num2str([-16:2:2]'));
grid on;

% figure(2)
% 
% plot(1:7,data(:,5),'^-r',1:7,data(:,6),'*-');
% legend('SVT','Grouse');
% xlabel('n_{1}×n_{2} /(100×100)','FontName','Times New Roman','FontSize',14);
% ylabel('\Delta_{r}','FontName','Times New Roman','FontSize',14);
% set(gca, 'XTick',1:7)
% set(gca,'XTickLabel',{'0.5×0.5''1×1','2×2','5×5','5×10','10×10','10×20'});
% ylim([0 7]);
% set(gca, 'YTick',0:7)



figure(3)

bar([data(:,7) data(:,8)]);
legend('SVT','Grouse');
xlabel('算例类型','FontName','Times New Roman','FontSize',14);
ylabel('RT /s ','FontName','Times New Roman','FontSize',14);
set(gca, 'XTick',1:7)
set(gca,'XTickLabel',{'1' '2','3','4','5','6','7'});
grid on;
%ylim([0 6]);
%set(gca, 'YTick',0:6)