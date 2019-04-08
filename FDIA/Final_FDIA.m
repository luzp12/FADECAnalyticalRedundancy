%======��ʼ������������======
clear;
close all;
%����ԭʼ����
load Data02.mat;
load DataJudgement.mat;
% load ab.mat;
A=A(150:18501,1:8);
DataJudgement=[DataJudgement DataJudgement];

%======���ù��ϲ�λ��ģʽ======
%��ʽ����λ��ģʽ������ʱ��
%��λ��'N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA'��'N1','N2','FF','EGT','TAT','PT'
%ģʽ��1��ƫ�� 2��Ư�� 3�����
tfault=[5000 10000 15000];
FaultMode=[7;1;tfault(2)]

%======���ù���ǿ��=======
lb=0.06;%ƫ�� 
ld=0.00005;%Ư��
Normal_Noise_Level=0.0001;%��������ǿ��
ln=500*Normal_Noise_Level;%����

%======����������ݣ�ע�����======
%���崫������Ŀ
n2hr=6;
n1hr=2;
npla=0;

ntotal=2*(n2hr+n1hr+npla);
S_2hr=[1 2 3 4 5 6];
S_1hr=[7 8];
% S_2hr2=n2hr+n1hr+npla+1:2*n2hr+n1hr+npla;
Data2Sensor;

%���������ϼ�¼����
SensorFaultRecord=zeros(size( Data2Sensor_Fault));
NoUpdate=[];

%%��ʼ������
%�ܱ�����,����n��������
%��������������,�ӿռ�ά��,��ʼ���ӿռ�
m=30;maxrank=6;
U=orth(randn(m,maxrank));
U1=orth(randn(m,maxrank));
w=zeros(maxrank,ntotal/2);
% %Ȩ��ϵ������
Psai0=diag([ones(1,m)]);
Data2Sensor_Plot=Data2Sensor_Fault;
Data2Controller=zeros(totaltime,n2hr+n1hr+npla);
Data2Controller(1:m-1,:)=Data2Sensor_Fault(1:m-1,1:n2hr+n1hr+npla);
%%��ʼ����
for k=m:totaltime%length(Data2Sensor_Fault)
  
  %==================FDIA Step1:VOTE==================
  %����ȽϽ��
  Com_Result=(Data2Sensor_Fault(k,1:ntotal/2)- Data2Sensor_Fault(k,ntotal/2+1:ntotal))./DataJudgement(2,1:ntotal/2);
  %���ƹ��ϲ�λ:���ϼ�¼����������ȶ�Ӧ��λ�ö���0.5
  VotedSensor=find(abs(Com_Result)>0.02);
  SensorFaultRecord(k,[VotedSensor VotedSensor+ntotal/2])=0.5;
  %���������������ֵ��������ȵ�ƽ��ֵ
  Data2Controller(k,1:ntotal/2)=mean([Data2Sensor_Fault(k,1:ntotal/2);Data2Sensor_Fault(k,ntotal/2+1:ntotal)]);
  
  %==================FDIA Step2:AR for Sensors ==================
  Mk=Data2Controller(k-m+1:k,1:ntotal/2);
  %��һ��
  [NMk,minMk,maxMk]=NormalData(Mk,Mk(1:m,:));
  %���ù۲����
  Omega=ones(size(Mk));
  Omega(m,[VotedSensor S_1hr])=0;
  Omega(m-3:m-1,[VotedSensor S_1hr])=Omega(m-3:m-1,[VotedSensor S_1hr])-repmat(max(SensorFaultRecord(k-3:k-1,[VotedSensor S_1hr])),3,1);
  %�������
  [NMkc,U,~]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,NoUpdate);
  %����һ��
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  
  
  [NMk,minMk,maxMk]=NormalData(Mk,DataJudgement(:,1:ntotal/2));
  [~,U1,W]=ARbyGROUSE(U1,NMk,Omega,maxrank,Psai0,NoUpdate);
  %����˫��ȹ���
  for s2n=VotedSensor
      %B�źŹ���
      if abs(Mkc(m,s2n)-Data2Sensor_Fault(k,s2n))<abs(Mkc(m,s2n)-Data2Sensor_Fault(k,ntotal/2+s2n))
      %�ع��ź�
      Data2Controller(k,s2n)=Data2Sensor_Fault(k,s2n);
      %��¼������Ϣ
      SensorFaultRecord(k,s2n)=0;
      SensorFaultRecord(k,ntotal/2+s2n)=1;
          %�������ڹ���ʱ��ȷ�Ϲ���
          if sum(SensorFaultRecord(k-3:k,ntotal/2+s2n))>=3||sum(SensorFaultRecord(k-9:k,ntotal/2+s2n))>=6
              %ȷ�Ϲ��Ϻ����ε��ô�����
              Data2Sensor_Fault(k+1:totaltime,ntotal/2+s2n)=Data2Sensor_Fault(k+1:totaltime,s2n);
              S_1hr=[S_1hr s2n];
              S_2hr(S_2hr==s2n)=[];
              fprintf('>>>Fault:%d   >>>  Time:%d\n',ntotal/2+s2n,k);
          end
       %A�źŹ���
      else
          %�ع��ź�
          Data2Controller(k,s2n)=Data2Sensor_Fault(k,ntotal/2+s2n);
          %��¼������Ϣ
          SensorFaultRecord(k,s2n)=1;
          SensorFaultRecord(k,ntotal/2+s2n)=0;
          %�������ڹ���ʱ��ȷ�Ϲ���
          if sum(SensorFaultRecord(k-3:k,s2n))>=3||sum(SensorFaultRecord(k-9:k,s2n))>=6
              %ȷ�Ϲ��Ϻ����ε��ô�����
              Data2Sensor_Fault(k+1:totaltime,s2n)=Data2Sensor_Fault(k+1:totaltime,ntotal/2+s2n);
              S_1hr=[S_1hr s2n];
              S_2hr(S_2hr==s2n)=[];
              fprintf('>>>Fault:%d   >>>  Time:%d\n',s2n,k);
          end
      end
  end
 %������ȹ���
  for s1n=S_1hr
      %1:��������ȱȽ�������ֵ�ҹ���δ��ȷ��ʱ
      if abs(Mkc(m,s1n)-Data2Controller(k,s1n))/DataJudgement(2,s1n)>0.05&&isempty(find(NoUpdate==s1n,1))==1
          k
          %��¼������Ϣ
          SensorFaultRecord(k,s1n)=1;
          %�ع�����
          Data2Controller(k,s1n)=Mkc(m,s1n);%(+Data2Controller(k,s1n))/2;
          
          %ȷ�Ϲ��ϣ�4������
          if sum(SensorFaultRecord(k-3:k,s1n))>=3||sum(SensorFaultRecord(k-9:k,s1n))>=6
              NoUpdate =[NoUpdate s1n]
              w(:,s1n)=W(:,s1n);
              fprintf('>>>Fault:%d   >>>  Time:%d\n',s1n,k);
          end 
      %2:�����ϱ�ȷ��ʱ��4������
      elseif isempty(find(NoUpdate==s1n,1))~=1
          %�ع����� 
          ReconstructData=U1*w;
          ReconstructData=AntiNormalData(ReconstructData,minMk,maxMk);
          Data2Controller(k,s1n)=ReconstructData(m,s1n);
      %3���޹���ʱ
      else
      end
 end
end
MainFDIA_Plot;