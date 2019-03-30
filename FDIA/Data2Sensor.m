% clear;
%加载数据

%% 添加噪声，形成余度
[totaltime,ntotal]=size(A);
Normal_Noise_Level=0.0001;
Data2Sensor_Normal=[A A(:,1:6)]+Normal_Noise_Level*randn(totaltime,ntotal+6)*diag(mean([A A(:,1:6)]));


%%注入故障
Data2Sensor_Fault=Data2Sensor_Normal;

%设置故障强度
lb=0.08;%偏置 
ld=0.01;%漂移
ln=500*Normal_Noise_Level;%噪声
if isempty(FaultMode)~=1
for i=1:length(FaultMode(1,:))
  FaultLength=FaultMode(3,i):length(Data2Sensor_Fault);
  switch    FaultMode(2,i)
      case 1
      Data2Sensor_Fault(FaultLength, FaultMode(1,i))=Data2Sensor_Fault(FaultLength, FaultMode(1,i))+lb*DataJudgement(2, FaultMode(1,i));
      case 2
      Data2Sensor_Fault(FaultLength, FaultMode(1,i))=Data2Sensor_Fault(FaultLength, FaultMode(1,i))+ld*DataJudgement(2, FaultMode(1,i))*(FaultLength-FaultMode(3,i))';
      case 3
      Data2Sensor_Fault(FaultLength, FaultMode(1,i))=Data2Sensor_Fault(FaultLength, FaultMode(1,i))+ln*DataJudgement(2, FaultMode(1,i))*randn(length(FaultLength),1);   
  end
end
end
% plot([Data2Sensor_Fault(:,FaultMode(1,1)) Data2Sensor_Normal(:,FaultMode(1,1))])
