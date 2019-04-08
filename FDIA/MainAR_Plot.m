AR_Sensor=8;
figure(1)
% for AR_Sensor=1:n-1
    time=1:length(M(:,AR_Sensor));
% subplot(4,2,AR_Sensor)
plot(time,M(:,AR_Sensor),'-b',time,Mc(:,AR_Sensor),'-.r');

xlim([30 k]);
% end
legend('M','Mc');

figure(2)
for f2=1:n
subplot(4,2,f2)
plot( (Mc(:,f2)-M(:,f2))/DataJudgement(2,f2));
% legned('M','Mc');
xlim([30 k]);
end