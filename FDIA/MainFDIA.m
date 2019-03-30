clear;
close all;
%����ԭʼ����
load Data00.mat;
load DataJudgement.mat;
A=A(:,1:8);


%���ù��ϲ�λ��ģʽ:��λ��ģʽ������ʱ��
%��λ��'N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA'��'N1','N2','FF','EGT','TAT','PT'
%ģʽ��1��ƫ�� 2��Ư�� 3�����
FaultMode=[1 2;1 1 ;60 100];%
%����������ݡ�ע�����
Data2Sensor;
%���������ϼ�¼����
SensorFaultRecord=zeros(size( Data2Sensor_Fault));
%���崫������Ŀ
n2hr=6;
n1hr=2;
npla=0;
ntotal=2*n2hr+n1hr+npla;
%%��ʼ������
%�ܱ�����,����n��������
%M=A(3000:6000,1:n);
%��������������,�ӿռ�ά��,��ʼ���ӿռ�
m1=30;maxrank1=4;
m2=30;maxrank2=7;
U1 =orth(randn(m1,maxrank1));
U2 =orth(randn(m2,maxrank2));
% %Ԥ��������ù۲����
% % Omega1=ones(m,n);
% % Omega(m,AR_Sensor)=0;
% %Ȩ��ϵ������
 Psai0=diag([ones(1,m1)]);
% 
% %%��ʼ����
% Mc=M;
Data2Controller=Data2Sensor_Fault(:,1:n2hr+n1hr+npla);
NoUpdate=[];
for k=m1:totaltime%length(Data2Sensor_Fault)
  
  %==================FDIA Step1:VOTE==================
  %����ȽϽ��
  Com_Result=(Data2Sensor_Fault(k,1:n2hr)- Data2Sensor_Fault(k,1+n2hr+n1hr+npla:2*n2hr+n1hr+npla))./DataJudgement(2,1:n2hr);
  %���ƹ��ϲ�λ:���ϼ�¼����������ȶ�Ӧ��λ�ö���0.5
  VotedSensor=find(abs(Com_Result)>0.02);
  SensorFaultRecord(k,[VotedSensor VotedSensor+n2hr+n1hr+npla])=0.5;
  %���������������ֵ��������ȵ�ƽ��ֵ
  Data2Controller(k,1:n2hr)=mean([Data2Sensor_Fault(k,1:n2hr);Data2Sensor_Fault(k,1+n2hr+n1hr+npla:2*n2hr+n1hr+npla)]);
  
  %==================FDIA Step2:AR for Sensors with 2 Hard Redundancy==================
  
  Mk1= Data2Controller(k-m1+1:k,1:n2hr);
  if isempty(VotedSensor)~=1
      %��һ��
      [NMk1,minMk1,maxMk1]=NormalData(Mk1);
      %���ù۲����
      Omega1=ones(m1,n2hr);
      Omega1(m1,VotedSensor)=0;
      Omega1(m1-3:m1-1,:)=Omega1(m1-3:m1-1,:)-(SensorFaultRecord(k-3:k-1,1:n2hr)+SensorFaultRecord(k-3:k-1,1+n2hr+n1hr+npla:2*n2hr+n1hr+npla));
      [NMkc1,U1]=ARbyGROUSE(U1,NMk1,Omega1,maxrank1,Psai0,[]);
      %����һ��
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
    %��һ��
    [NMk2,minMk2,maxMk2]=NormalData(Mk2);
    %���ù۲����
    Omega2=ones(m2,n2hr+n1hr);
    Omega2(m2,n2hr+1:n2hr+n1hr)=zeros(1,n1hr);
    Omega2(m2-1,n2hr+1:n2hr+n1hr)=Omega2(m2-1,n2hr+1:n2hr+n1hr)-SensorFaultRecord(k-1,n2hr+1:n2hr+n1hr);
    [NMkc2,U2]=ARbyGROUSE(U2,NMk2,Omega2,maxrank2,Psai0,NoUpdate);
    %����һ��
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












    
    
    
%     %��ȡ��������
%   Mk=M(k-m+1:k,:);
%   %��һ��
%   [NMk,minMk,maxMk]=NormalData(Mk);
%   %����
%   [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0);
%   %����һ��
%   [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
%   Mc(k,AR_Sensor)=Mkc(m,AR_Sensor);
end
MainFDIA_Plot;