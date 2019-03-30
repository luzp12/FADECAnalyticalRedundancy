clear;
close all;
%����ԭʼ����
load Data01.mat;
load DataJudgement.mat;
load ab.mat;
A=A(1:4000,1:8);


%���ù��ϲ�λ��ģʽ:��λ��ģʽ������ʱ��
%��λ��'N1','N2','FF','EGT','TAT','PT','OIP','OIT','PLA'��'N1','N2','FF','EGT','TAT','PT'
%ģʽ��1��ƫ�� 2��Ư�� 3�����
FaultMode=[1 8;1 3 ;1000 1500];%
%����������ݡ�ע�����
Data2Sensor;
%���������ϼ�¼����
SensorFaultRecord=zeros(size( Data2Sensor_Fault));
NoUpdate=[];
%���崫������Ŀ
n2hr=6;
n1hr=2;
npla=0;
ntotal=2*n2hr+n1hr+npla;
S_2hr1=1:n2hr;
S_1hr=n2hr+1:n2hr+n1hr;
S_2hr2=n2hr+n1hr+npla+1:2*n2hr+n1hr+npla;
%%��ʼ������
%�ܱ�����,����n��������
%��������������,�ӿռ�ά��,��ʼ���ӿռ�
m=30;maxrank=6;
U=orth(randn(m,maxrank));
% %Ȩ��ϵ������
Psai0=diag([ones(1,m)]);
P=10^6.*eye(7,7);
% Data2Sensor_Plot=Data2Sensor_Fault;
Data2Controller=zeros(totaltime,n2hr+n1hr+npla);
Data2Controller(1:m-1,:)=Data2Sensor_Fault(1:m-1,1:n2hr+n1hr+npla);
%%��ʼ����
for k=m:totaltime%length(Data2Sensor_Fault)
  
  %==================FDIA Step1:VOTE==================
  %����ȽϽ��
  Com_Result=(Data2Sensor_Fault(k,S_2hr1)- Data2Sensor_Fault(k,S_2hr2))./DataJudgement(2,1:n2hr);
  %���ƹ��ϲ�λ:���ϼ�¼����������ȶ�Ӧ��λ�ö���0.5
  VotedSensor=find(abs(Com_Result)>0.02);
  SensorFaultRecord(k,[VotedSensor VotedSensor+n2hr+n1hr+npla])=0.5;
  %���������������ֵ��������ȵ�ƽ��ֵ
  Data2Controller(k,S_2hr1)=mean([Data2Sensor_Fault(k,S_2hr1);Data2Sensor_Fault(k,S_2hr2)]);
  Data2Controller(k,S_1hr)=Data2Sensor_Fault(k,S_1hr);
  %==================FDIA Step2:AR for Sensors ==================
  
  Mk= Data2Controller(k-m+1:k,1:n2hr+n1hr+npla);
  %��һ��
  [NMk,minMk,maxMk]=NormalData(Mk);
  %���ù۲����
  Omega=ones(size(Mk));
  Omega(m,[VotedSensor S_1hr])=0;
  Omega(m-3:m-1,S_1hr)=Omega(m-3:m-1,S_1hr)-SensorFaultRecord(k-3:k-1,S_1hr);
  %�������
  [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,NoUpdate);
  %����һ��
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  %����˫��ȹ���
  for s2n=VotedSensor
      if abs(Mkc(m,s2n)-Data2Sensor_Fault(k,S_2hr1(s2n)))<abs(Mkc(m,s2n)-Data2Sensor_Fault(k,S_2hr2(s2n)))
      %�ع��ź�
      Data2Controller(k,s2n)=Data2Sensor_Fault(k,S_2hr1(s2n));
      %��¼������Ϣ
      SensorFaultRecord(k,S_2hr1(s2n))=0;
      SensorFaultRecord(k,S_2hr2(s2n))=1;
          %�������ڹ���ʱ��ȷ�Ϲ���
          if sum(SensorFaultRecord(k-3:k,S_2hr2(s2n)))>=2||sum(SensorFaultRecord(k-9:k,S_2hr2(s2n)))>=6
              %ȷ�Ϲ��Ϻ����ε��ô�����
              Data2Sensor_Fault(k+1:totaltime,S_2hr2(s2n))=Data2Sensor_Fault(k+1:totaltime,S_2hr1(s2n));
          end
      else
          %�ع��ź�
          Data2Controller(k,s2n)=Data2Sensor_Fault(k,S_2hr2(s2n));
          %��¼������Ϣ
          SensorFaultRecord(k,S_2hr1(s2n))=1;
          SensorFaultRecord(k,S_2hr2(s2n))=0;
          %�������ڹ���ʱ��ȷ�Ϲ���
          if sum(SensorFaultRecord(k-3:k,S_2hr1(s2n)))>=2||sum(SensorFaultRecord(k-9:k,S_2hr1(s2n)))>=6
              %ȷ�Ϲ��Ϻ����ε��ô�����
              Data2Sensor_Fault(k+1:totaltime,S_2hr1(s2n))=Data2Sensor_Fault(k+1:totaltime,S_2hr2(s2n));
          end
      end
  end
 %������ȹ���
  for s1n=S_1hr
      %1:��������ȱȽ�������ֵ�ҹ���δ��ȷ��ʱ
      if abs(Mkc(m,s1n)-Data2Sensor_Fault(k,s1n))/DataJudgement(2,s1n)>0.04&&isempty(find(NoUpdate==s1n,1))==1
          k
          %��¼������Ϣ
          SensorFaultRecord(k,s1n)=1;
          %�ع�����
          Data2Controller(k,s1n)=[Data2Controller(k,1:6) 1]*ab(:,s1n);
          %ȷ�Ϲ��ϣ�4������
          if sum(SensorFaultRecord(k-3:k,s1n))==4
              NoUpdate=[NoUpdate s1n]
          end 
      %2:�����ϱ�ȷ��ʱ��4������
      elseif isempty(find(NoUpdate==s1n,1))~=1
          %�ع�����
          Data2Controller(k,s1n)=[Data2Controller(k,1:6) 1]*ab(:,s1n);
      %3���޹���ʱ
      else
        %�������ģ��
          if abs((Data2Controller(k,s1n))-[Data2Controller(k,S_2hr1) 1]*ab(:,s1n))>0.02*DataJudgement(2,s1n)
            %====����ģ�Ͳ���====
            %���� A: x=Ax,7*7
            Aab=eye(7,7);
            %����H: z=Hx+e,1*7
            H=[Data2Controller(k,S_2hr1) 1];
            %====������������====
            Q=0*eye(7,7);
            R=0.001;
            %====����Э�������Pguess:7*7====
            Pguess=Aab*P*Aab'+Q;
            %====��������K:====
            K=Pguess*H'/(H*Pguess*H'+R);
            %====����Э�������====
            P=(eye(7)-K*H)*Pguess;     
            %====״̬����====
            ab(:,s1n)=ab(:,s1n)+K*(Data2Controller(k,s1n)-H*ab(:,s1n));
            %�����Ϸ���ʱ�����õ�ǰģ�Ͳ����ع��ź�
          end   
      end
 end
end
MainFDIA_Plot;