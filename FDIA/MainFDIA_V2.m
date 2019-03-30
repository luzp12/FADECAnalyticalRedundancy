clear;
close all;
%载入原始数据
load Data01.mat;
load DataJudgement.mat;
load ab.mat;
A=A(1:4000,1:8);


%设置故障部位和模式:部位，模式，故障时间
%部位：'N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA'，'N1','N2','FF','EGT','TAT','PT'
%模式：1：偏置 2：漂移 3：误差
FaultMode=[1 8;1 3 ;1000 1500];%
%生成余度数据、注入故障
Data2Sensor;
%传感器故障记录矩阵
SensorFaultRecord=zeros(size( Data2Sensor_Fault));
NoUpdate=[];
%定义传感器数目
n2hr=6;
n1hr=2;
npla=0;
ntotal=2*n2hr+n1hr+npla;
S_2hr1=1:n2hr;
S_1hr=n2hr+1:n2hr+n1hr;
S_2hr2=n2hr+n1hr+npla+1:2*n2hr+n1hr+npla;
%%初始化参数
%总变量数,根据n载入数据
%参数矩阵周期数,子空间维数,初始化子空间
m=30;maxrank=6;
U=orth(randn(m,maxrank));
% %权重系数矩阵
Psai0=diag([ones(1,m)]);
P=10^6.*eye(7,7);
% Data2Sensor_Plot=Data2Sensor_Fault;
Data2Controller=zeros(totaltime,n2hr+n1hr+npla);
Data2Controller(1:m-1,:)=Data2Sensor_Fault(1:m-1,1:n2hr+n1hr+npla);
%%开始仿真
for k=m:totaltime%length(Data2Sensor_Fault)
  
  %==================FDIA Step1:VOTE==================
  %计算比较结果
  Com_Result=(Data2Sensor_Fault(k,S_2hr1)- Data2Sensor_Fault(k,S_2hr2))./DataJudgement(2,1:n2hr);
  %疑似故障部位:故障记录矩阵两个余度对应的位置都置0.5
  VotedSensor=find(abs(Com_Result)>0.02);
  SensorFaultRecord(k,[VotedSensor VotedSensor+n2hr+n1hr+npla])=0.5;
  %参数测量矩阵输出值：两个余度的平均值
  Data2Controller(k,S_2hr1)=mean([Data2Sensor_Fault(k,S_2hr1);Data2Sensor_Fault(k,S_2hr2)]);
  Data2Controller(k,S_1hr)=Data2Sensor_Fault(k,S_1hr);
  %==================FDIA Step2:AR for Sensors ==================
  
  Mk= Data2Controller(k-m+1:k,1:n2hr+n1hr+npla);
  %归一化
  [NMk,minMk,maxMk]=NormalData(Mk);
  %设置观测矩阵
  Omega=ones(size(Mk));
  Omega(m,[VotedSensor S_1hr])=0;
  Omega(m-3:m-1,S_1hr)=Omega(m-3:m-1,S_1hr)-SensorFaultRecord(k-3:k-1,S_1hr);
  %矩阵填充
  [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,NoUpdate);
  %反归一化
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  %处理双余度故障
  for s2n=VotedSensor
      if abs(Mkc(m,s2n)-Data2Sensor_Fault(k,S_2hr1(s2n)))<abs(Mkc(m,s2n)-Data2Sensor_Fault(k,S_2hr2(s2n)))
      %重构信号
      Data2Controller(k,s2n)=Data2Sensor_Fault(k,S_2hr1(s2n));
      %记录故障信息
      SensorFaultRecord(k,S_2hr1(s2n))=0;
      SensorFaultRecord(k,S_2hr2(s2n))=1;
          %连续周期故障时，确认故障
          if sum(SensorFaultRecord(k-3:k,S_2hr2(s2n)))>=2||sum(SensorFaultRecord(k-9:k,S_2hr2(s2n)))>=6
              %确认故障后，屏蔽掉该传感器
              Data2Sensor_Fault(k+1:totaltime,S_2hr2(s2n))=Data2Sensor_Fault(k+1:totaltime,S_2hr1(s2n));
          end
      else
          %重构信号
          Data2Controller(k,s2n)=Data2Sensor_Fault(k,S_2hr2(s2n));
          %记录故障信息
          SensorFaultRecord(k,S_2hr1(s2n))=1;
          SensorFaultRecord(k,S_2hr2(s2n))=0;
          %连续周期故障时，确认故障
          if sum(SensorFaultRecord(k-3:k,S_2hr1(s2n)))>=2||sum(SensorFaultRecord(k-9:k,S_2hr1(s2n)))>=6
              %确认故障后，屏蔽掉该传感器
              Data2Sensor_Fault(k+1:totaltime,S_2hr1(s2n))=Data2Sensor_Fault(k+1:totaltime,S_2hr2(s2n));
          end
      end
  end
 %处理单余度故障
  for s1n=S_1hr
      %1:当解析余度比较误差超出阈值且故障未被确定时
      if abs(Mkc(m,s1n)-Data2Sensor_Fault(k,s1n))/DataJudgement(2,s1n)>0.04&&isempty(find(NoUpdate==s1n,1))==1
          k
          %记录故障信息
          SensorFaultRecord(k,s1n)=1;
          %重构故障
          Data2Controller(k,s1n)=[Data2Controller(k,1:6) 1]*ab(:,s1n);
          %确认故障：4个周期
          if sum(SensorFaultRecord(k-3:k,s1n))==4
              NoUpdate=[NoUpdate s1n]
          end 
      %2:当故障被确定时，4个周期
      elseif isempty(find(NoUpdate==s1n,1))~=1
          %重构故障
          Data2Controller(k,s1n)=[Data2Controller(k,1:6) 1]*ab(:,s1n);
      %3：无故障时
      else
        %更新拟合模型
          if abs((Data2Controller(k,s1n))-[Data2Controller(k,S_2hr1) 1]*ab(:,s1n))>0.02*DataJudgement(2,s1n)
            %====计算模型参数====
            %计算 A: x=Ax,7*7
            Aab=eye(7,7);
            %计算H: z=Hx+e,1*7
            H=[Data2Controller(k,S_2hr1) 1];
            %====定义噪声参数====
            Q=0*eye(7,7);
            R=0.001;
            %====估计协方差矩阵Pguess:7*7====
            Pguess=Aab*P*Aab'+Q;
            %====计算增益K:====
            K=Pguess*H'/(H*Pguess*H'+R);
            %====更新协方差矩阵====
            P=(eye(7)-K*H)*Pguess;     
            %====状态更新====
            ab(:,s1n)=ab(:,s1n)+K*(Data2Controller(k,s1n)-H*ab(:,s1n));
            %当故障发生时，利用当前模型产生重构信号
          end   
      end
 end
end
MainFDIA_Plot;