% clear;
%加载数据

%% 添加噪声，形成余度,单余度传感器生成伪余度统一处理
[totaltime,ntotalA]=size(A);
Data2Sensor_Normal=[A A];
Data2Sensor_Normal(:,S_2hr)=Data2Sensor_Normal(:,S_2hr)+Normal_Noise_Level*randn(totaltime,length(S_2hr))*diag(DataJudgement(2,S_2hr));
% Data2Sensor_Normal=[Data2Sensor_Normal A(:,S_1hr)];

%%注入故障
Data2Sensor_Fault=Data2Sensor_Normal;


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
Data2Sensor_Fault(:,ntotalA+S_1hr)=Data2Sensor_Fault(:,S_1hr);