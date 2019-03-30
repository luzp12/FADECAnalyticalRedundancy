time=1:10:floor(k/10)*10;
figure(1)
 for AR_Sensor=S_2hr1
    subplot(4,2,AR_Sensor)
    plot(time,Data2Controller(time,AR_Sensor),'-black',time,Data2Sensor_Fault(time,S_2hr1(AR_Sensor)),'-r',time,Data2Sensor_Fault(time,S_2hr2(AR_Sensor)),'-b');
    legend('Output','A','B');
 end
 for AR_Sensor=S_1hr
    subplot(4,2,AR_Sensor)
    plot(time,Data2Controller(time,AR_Sensor),'-black',time,Data2Sensor_Fault(time,AR_Sensor),'-r',time,Data2Sensor_Normal(time,AR_Sensor),'-b');
    legend('Output','A','Normal');
    xlim([30 k]);
 end

figure(2)
for AR_Sensor=1:n2hr+n1hr+npla+n2hr
    [xx,yy]=find(SensorFaultRecord==1);
plot( xx,yy,'*r');
xlim([30 k]);
ylim([1  n2hr+n1hr+npla+n2hr]);
% title(num2str(AR_Sensor))
end

AR_Sensor=FaultMode(1,2);
figure(3)
plot(time,Data2Controller(time,AR_Sensor),'-black',time,Data2Sensor_Fault(time,AR_Sensor),'-r',time,Data2Sensor_Normal(time,AR_Sensor),'-b','MarkerSize',1);
legend('Output','Fault','Normal');
ylim([DataJudgement(1,AR_Sensor) 1.5*DataJudgement(2,AR_Sensor)]);
