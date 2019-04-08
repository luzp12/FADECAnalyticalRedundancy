time=1:10:floor(totaltime/10)*10;
figure(1)
 for AR_Sensor=1:ntotal/2
    subplot(4,2,AR_Sensor)
    plot(time,Data2Controller(time,AR_Sensor),'-black',time,Data2Sensor_Plot(time,AR_Sensor),'-r',time,Data2Sensor_Plot(time,AR_Sensor+ntotal/2),'-b');
    legend('Output','A','B');
%     xlim([1 k]);
 end

figure(2)
% for AR_Sensor=1:ntotal
    [xx,yy]=find(SensorFaultRecord==1);
plot( xx,yy,'*r');
xlim([1 k]);
ylim([1  ntotal]);
% title(num2str(AR_Sensor))
% end

AR_Sensor=FaultMode(1,1);
figure(3)
plot(time,Data2Controller(time,AR_Sensor),'-black',time,Data2Sensor_Plot(time,AR_Sensor),'-r',time,Data2Sensor_Normal(time,AR_Sensor),'-b','MarkerSize',1);
legend('Output','Fault','Normal');
% ylim([DataJudgement(1,AR_Sensor) 1.1*DataJudgement(2,AR_Sensor)]);
grid on;
xlim([10*m k]);