%在线回归方法
%======初始化，载入数据======
clear;
close all;
%载入原始数据
load Data02.mat;
load DataJudgement.mat;
% load ab.mat;
A=A(:,1:8);
DataJudgement=[DataJudgement DataJudgement];

%======设置故障部位和模式======
%格式：部位，模式，故障时间
%部位：'N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA'，'N1','N2','FF','EGT','TAT','PT'
%模式：1：偏置 2：漂移 3：误差
tfault=[3000 10000 16000];
FaultMode=[1;2 ;tfault(1)]

%======设置故障强度=======
lb=0.07;%偏置 
ld=0.00001;%漂移
Normal_Noise_Level=0.0001;%正常噪声强度
ln=500*Normal_Noise_Level;%噪声

%======生成余度数据，注入故障======
%定义传感器数目
n2hr=6;
n1hr=2;
npla=0;

ntotal=2*(n2hr+n1hr+npla);
S_2hr=1:n2hr;
S_1hr=n2hr+1:n2hr+n1hr;
% S_2hr2=n2hr+n1hr+npla+1:2*n2hr+n1hr+npla;
Data2Sensor;

%传感器故障记录矩阵
SensorFaultRecord=zeros(size( Data2Sensor_Fault));
FaultSensor=[];
NormalSensor=S_2hr;

%%初始化参数
%总变量数,根据n载入数据
%参数矩阵周期数,子空间维数,初始化子空间
m=30;maxrank=6;
U=orth(randn(m,maxrank));
w=zeros(maxrank,ntotal/2);
ab=zeros(length(NormalSensor)+1,ntotal/2);
% %权重系数矩阵
Psai0=diag([ones(1,m)]);
Data2Sensor_Plot=Data2Sensor_Fault;
Data2Controller=zeros(totaltime,n2hr+n1hr+npla);
Data2Controller(1:10*m-1,:)=Data2Sensor_Fault(1:10*m-1,1:n2hr+n1hr+npla);
P=repmat(10^6.*eye(n2hr+1,n2hr+1),1,1,ntotal/2);
%%开始仿真
for k=10*m:totaltime%length(Data2Sensor_Fault)
  
  %==================FDIA Step1:VOTE==================
  %计算比较结果
  Com_Result=(Data2Sensor_Fault(k,1:ntotal/2)- Data2Sensor_Fault(k,ntotal/2+1:ntotal))./DataJudgement(2,1:ntotal/2);
  %疑似故障部位:故障记录矩阵两个余度对应的位置都置0.5
  VotedSensor=find(abs(Com_Result)>0.02);
  SensorFaultRecord(k,[VotedSensor VotedSensor+ntotal/2])=0.5;
  %参数测量矩阵输出值：两个余度的平均值
  Data2Controller(k,1:ntotal/2)=mean([Data2Sensor_Fault(k,1:ntotal/2);Data2Sensor_Fault(k,ntotal/2+1:ntotal)]);
  
  %==================FDIA Step2:AR for Sensors ==================
  Mk=Data2Controller(k-m+1:k,1:ntotal/2);
  %归一化
  [NMk,minMk,maxMk]=NormalData(Mk,Mk);
  %设置观测矩阵
  Omega=ones(size(Mk));
  Omega(m,[VotedSensor S_1hr])=0;
  Omega(m-3:m-1,[VotedSensor S_1hr])=Omega(m-3:m-1,[VotedSensor S_1hr])-repmat(max(SensorFaultRecord(k-3:k-1,[VotedSensor S_1hr])),3,1);
  %矩阵填充
  [NMkc,U,W]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,FaultSensor);
  %反归一化
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  %处理双余度故障
  for s2n=VotedSensor
      %B信号故障
      if abs(Mkc(m,s2n)-Data2Sensor_Fault(k,s2n))<abs(Mkc(m,s2n)-Data2Sensor_Fault(k,ntotal/2+s2n))
      %重构信号
      Data2Controller(k,s2n)=Data2Sensor_Fault(k,s2n);
      %记录故障信息
      SensorFaultRecord(k,s2n)=0;
      SensorFaultRecord(k,ntotal/2+s2n)=1;
          %连续周期故障时，确认故障
          if sum(SensorFaultRecord(k-3:k,ntotal/2+s2n))>=3||sum(SensorFaultRecord(k-9:k,ntotal/2+s2n))>=6
              %确认故障后，屏蔽掉该传感器
              Data2Sensor_Fault(k+1:totaltime,ntotal/2+s2n)=Data2Sensor_Fault(k+1:totaltime,s2n);
              S_1hr=[S_1hr s2n];
              S_2hr(S_2hr==s2n)=[];
              fprintf('>>>Fault:%d   >>>  Time:%d\n',ntotal/2+s2n,k);
          end
       %A信号故障
      else
          %重构信号
          Data2Controller(k,s2n)=Data2Sensor_Fault(k,ntotal/2+s2n);
          %记录故障信息
          SensorFaultRecord(k,s2n)=1;
          SensorFaultRecord(k,ntotal/2+s2n)=0;
          %连续周期故障时，确认故障
          if sum(SensorFaultRecord(k-3:k,s2n))>=3||sum(SensorFaultRecord(k-9:k,s2n))>=6
              %确认故障后，屏蔽掉该传感器
              Data2Sensor_Fault(k+1:totaltime,s2n)=Data2Sensor_Fault(k+1:totaltime,ntotal/2+s2n);
              S_1hr=[S_1hr s2n];
              S_2hr(S_2hr==s2n)=[];
              fprintf('>>>Fault:%d   >>>  Time:%d\n',s2n,k);
          end
      end
  end
 %处理单余度故障
  for s1n=S_1hr
      %1:当解析余度比较误差超出阈值且故障未被确定时
      if abs(Mkc(m,s1n)-Data2Controller(k,s1n))/DataJudgement(2,s1n)>0.05&&isempty(find(FaultSensor==s1n,1))==1
          k
          %记录故障信息
          SensorFaultRecord(k,s1n)=1;
          %重构故障
          Data2Controller(k,s1n)=Mkc(m,s1n);%+Data2Controller(k,s1n))/2;
          
          %确认故障：4个周期
          if sum(SensorFaultRecord(k-3:k,s1n))>=3||sum(SensorFaultRecord(k-9:k,s1n))>=6
              FaultSensor =[FaultSensor s1n]
%               NormalSensor(NormalSensor==s1n)=[];
              w(:,s1n)=W(:,s1n);
              fprintf('>>>Fault:%d   >>>  Time:%d\n',s1n,k);
               %更新拟合模型
              
          end 
      %2:当故障被确定时，4个周期
      elseif isempty(find(FaultSensor==s1n,1))~=1
          %重构故障 
           Data2Controller(k,s1n)=[Data2Controller(k,NormalSensor)./DataJudgement(2,NormalSensor) 1]*ab(1:length(NormalSensor)+1,s1n)*DataJudgement(2,s1n);
      %3：无故障时
      else
          
%                    P=10^6.*eye(length(NormalSensor)+1,length(NormalSensor)+1);  
                    NormalSensor=S_2hr;
%                   if abs(Data2Controller(kk,s1n)-[Data2Controller(kk,S_2hr) 1]*ab(1:length(S_2hr)+1,s1n))>0.02*DataJudgement(2,s1n)
                    %====计算模型参数====
                    %计算 A: x=Ax,7*7
                    Aab=eye(length(NormalSensor)+1,length(NormalSensor)+1);
                    %计算H: z=Hx+e,1*7
                    H=[Data2Controller(k,NormalSensor)./DataJudgement(2,NormalSensor) 1];
                    %====定义噪声参数====
                    Q=0*eye(length(NormalSensor)+1,length(NormalSensor)+1);
                    R=0.001;
                    %====估计协方差矩阵Pguess:7*7====
                    Pguess=Aab*P(1:length(NormalSensor)+1,1:length(NormalSensor)+1,s1n)*Aab'+Q;
                    %====计算增益K:====
                    K=Pguess*H'/(H*Pguess*H'+R);
                    %====更新协方差矩阵====
                    P(1:length(NormalSensor)+1,1:length(NormalSensor)+1,s1n)=(eye(length(NormalSensor)+1)-K*H)*Pguess;     
                    %====状态更新====
                    ab(1:length(NormalSensor)+1,s1n)=ab(1:length(NormalSensor)+1,s1n)+K*(Data2Controller(k,s1n)/DataJudgement(2,s1n)-H*ab(1:length(NormalSensor)+1,s1n));
                    %当故障发生时，利用当前模型产生重构信号
%                   end
      end
 end
end
MainFDIA_Plot;