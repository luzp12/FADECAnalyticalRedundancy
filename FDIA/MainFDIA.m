clear;
close all;
%载入原始数据
load Data00.mat;
load DataJudgement.mat;
A=A(:,1:8);


%设置故障部位和模式:部位，模式，故障时间
%部位：'N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA'，'N1','N2','FF','EGT','TAT','PT'
%模式：1：偏置 2：漂移 3：误差
FaultMode=[1 2;1 1 ;60 100];%
%生成余度数据、注入故障
Data2Sensor;
%传感器故障记录矩阵
SensorFaultRecord=zeros(size( Data2Sensor_Fault));
%定义传感器数目
n2hr=6;
n1hr=2;
npla=0;
ntotal=2*n2hr+n1hr+npla;
%%初始化参数
%总变量数,根据n载入数据
%M=A(3000:6000,1:n);
%参数矩阵周期数,子空间维数,初始化子空间
m1=30;maxrank1=4;
m2=30;maxrank2=7;
U1 =orth(randn(m1,maxrank1));
U2 =orth(randn(m2,maxrank2));
% %预测对象，设置观测矩阵
% % Omega1=ones(m,n);
% % Omega(m,AR_Sensor)=0;
% %权重系数矩阵
 Psai0=diag([ones(1,m1)]);
% 
% %%开始仿真
% Mc=M;
Data2Controller=Data2Sensor_Fault(:,1:n2hr+n1hr+npla);
NoUpdate=[];
for k=m1:totaltime%length(Data2Sensor_Fault)
  
  %==================FDIA Step1:VOTE==================
  %计算比较结果
  Com_Result=(Data2Sensor_Fault(k,1:n2hr)- Data2Sensor_Fault(k,1+n2hr+n1hr+npla:2*n2hr+n1hr+npla))./DataJudgement(2,1:n2hr);
  %疑似故障部位:故障记录矩阵两个余度对应的位置都置0.5
  VotedSensor=find(abs(Com_Result)>0.02);
  SensorFaultRecord(k,[VotedSensor VotedSensor+n2hr+n1hr+npla])=0.5;
  %参数测量矩阵输出值：两个余度的平均值
  Data2Controller(k,1:n2hr)=mean([Data2Sensor_Fault(k,1:n2hr);Data2Sensor_Fault(k,1+n2hr+n1hr+npla:2*n2hr+n1hr+npla)]);
  
  %==================FDIA Step2:AR for Sensors with 2 Hard Redundancy==================
  
  Mk1= Data2Controller(k-m1+1:k,1:n2hr);
  if isempty(VotedSensor)~=1
      %归一化
      [NMk1,minMk1,maxMk1]=NormalData(Mk1);
      %设置观测矩阵
      Omega1=ones(m1,n2hr);
      Omega1(m1,VotedSensor)=0;
      Omega1(m1-3:m1-1,:)=Omega1(m1-3:m1-1,:)-(SensorFaultRecord(k-3:k-1,1:n2hr)+SensorFaultRecord(k-3:k-1,1+n2hr+n1hr+npla:2*n2hr+n1hr+npla));
      [NMkc1,U1]=ARbyGROUSE(U1,NMk1,Omega1,maxrank1,Psai0,[]);
      %反归一化
      [Mkc1]=AntiNormalData(NMkc1,minMk1,maxMk1);

      for s2n=VotedSensor
          if abs(Mkc1(m1,s2n)-Data2Sensor_Fault(k,s2n))<abs(Mkc1(m1,s2n)-Data2Sensor_Fault(k,s2n+n2hr+n1hr+npla))
          Data2Controller(k,s2n)=Data2Sensor_Fault(k,s2n);
          SensorFaultRecord(k,s2n)=0;
          SensorFaultRecord(k,s2n+n2hr+n1hr+npla)=1;
              if sum(SensorFaultRecord(k-1:k,s2n+n2hr+n1hr+npla))==2
               Data2Sensor_Fault(k+1:totaltime,s2n+n2hr+n1hr+npla)=Data2Sensor_Fault(k+1:totaltime,s2n);
              end
          else
          Data2Controller(k,s2n)=Data2Sensor_Fault(k,s2n+n2hr+n1hr+npla);
          SensorFaultRecord(k,s2n)=1;
          SensorFaultRecord(k,s2n+n2hr+n1hr+npla)=0;
              if sum(SensorFaultRecord(k-1:k,s2n))==2
               Data2Sensor_Fault(k+1:totaltime,s2n)=Data2Sensor_Fault(k+1:totaltime,s2n+n2hr+n1hr+npla);
              end
          end
      end
  end
 %==================FDIA Step3:AR for Sensors with 1 Hard Redundancy==================
    Mk2= Data2Controller(k-m2+1:k,1:n2hr+n1hr);
    %归一化
    [NMk2,minMk2,maxMk2]=NormalData(Mk2);
    %设置观测矩阵
    Omega2=ones(m2,n2hr+n1hr);
    Omega2(m2,n2hr+1:n2hr+n1hr)=zeros(1,n1hr);
    Omega2(m2-1,n2hr+1:n2hr+n1hr)=Omega2(m2-1,n2hr+1:n2hr+n1hr)-SensorFaultRecord(k-1,n2hr+1:n2hr+n1hr);
    [NMkc2,U2]=ARbyGROUSE(U2,NMk2,Omega2,maxrank2,Psai0,NoUpdate);
    %反归一化
    [Mkc2]=AntiNormalData(NMkc2,minMk2,maxMk2);

     for s3n=n2hr+1:n2hr+n1hr
          if abs(Mkc2(m2,s3n)-Data2Sensor_Fault(k,s3n))/DataJudgement(2,s3n)>0.02&&isempty(find(NoUpdate==s3n))==1
              SensorFaultRecord(k,s3n)=1;
              if sum(SensorFaultRecord(k-2:k,s3n))==2
                  k
                  NoUpdate=[NoUpdate s3n]
                  Data2Controller(k,s3n)=Mkc2(m2,s3n);
                  S_Sensor=1:n2hr+n1hr;
                  S_Sensor(NoUpdate)=[];
                  H=Data2Controller(k-50:k-2,S_Sensor)\Data2Controller(k-50:k-2,s3n);
              end 
          elseif isempty(find(NoUpdate==s3n))~=1
              
              Ms3nH=Data2Controller(k-50:k-2,S_Sensor)*H;
              Data2Controller(k,s3n)=Ms3nH(49,1);
          end
     end












    
    
    
%     %提取参数矩阵
%   Mk=M(k-m+1:k,:);
%   %归一化
%   [NMk,minMk,maxMk]=NormalData(Mk);
%   %设置
%   [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0);
%   %反归一化
%   [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
%   Mc(k,AR_Sensor)=Mkc(m,AR_Sensor);
end
MainFDIA_Plot;