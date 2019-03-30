% clear;
%��������

%% ����������γ����
[totaltime,ntotal]=size(A);
Normal_Noise_Level=0.0001;
Data2Sensor_Normal=[A A(:,1:6)]+Normal_Noise_Level*randn(totaltime,ntotal+6)*diag(mean([A A(:,1:6)]));


%%ע�����
Data2Sensor_Fault=Data2Sensor_Normal;

%���ù���ǿ��
lb=0.08;%ƫ�� 
ld=0.01;%Ư��
ln=500*Normal_Noise_Level;%����
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
