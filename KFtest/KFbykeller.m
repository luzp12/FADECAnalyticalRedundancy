
%%�������ݸ��֣����й��Ͻ���ܵ��˲��������봫ͳ�˲������˶Ա�
%Keller, J.Y., Fault isolation filter design for linear stochastic systems. Automatica, 1999. 35(10): p. 1701-1706.
%�ص㣺ֻ��Ҫ֪������ģ�ͺ͹���ģ�ͣ�A B C F���󣬸���y�Ĺ۲�ֵ���ɼ���в�q,q��ÿһ��ֱ������F��Ӧ��һ������
clear;
A=[0.2 1 0 0.2; 0 0.5 1 0.4; 0 0 0.8 1; 0 0 0 0.3];
C=[0 1 0 0;0 0 1 0;0 0 0 1];

% C=randn(3,4);
[m,n]=size(C);
B=zeros(n,1);
%���Ϸֲ�����
F=[-1 1;1 0; 0 -1; 1 1];
% F=[null(C) F];


W=[0.9 0 0 0; 0 0 0 0;0 0 0.5 0; 0 0 0 0.3];
V=eye(m);
%%�������

%����rouֵ
[lengthF,widthF]=size(F);
rou=zeros(widthF,1);
for i=1:widthF
    for rou_temp=1:100
        if norm(C*A^(rou_temp-1)*F(:,i),2)>10e-6
            rou(i,1)=rou_temp;
            break;
        end
    end
end

%����Psai��D
Psai_=[];
for i=1:max(rou)
       Psai_=[Psai_ A^(i-1)*F(:,find(rou==i))];
end
D_=C*Psai_;

%����SIGMA��PAI
PAI=eye(widthF)/D_;
SIGMA=randn(m-widthF,m)*(eye(m)-D_*PAI);
omega=A*Psai_;
A_=A-omega*PAI*C;
C_=SIGMA*C;
V_=SIGMA*SIGMA';
W_=W+omega*(PAI*PAI')*omega';

%%�������
%��ʼ��
ttotal=200;
xk=zeros(n,ttotal);
uk=zeros(1,ttotal);
yk=zeros(m,ttotal);
xk(:,1)=randn(n,1);
KFxk=xk;
wk=sqrt(W)*randn(n,ttotal);
vk=sqrt(V)*randn(m,ttotal); 
nk=zeros(widthF,ttotal);
Pk1_=10^6.*zeros(n,n);
KFpk1=Pk1_;
qk=zeros(widthF,ttotal);
gamak=zeros(m-widthF,ttotal);
xk_head=zeros(n,ttotal);
KFeyk=yk;
for t=1:ttotal-1
 %ģ�Ͳ��� 
  
 if t>=50 
     nk(1,t)=10*sin(0.1*t);
 end
 if t>=120
     nk(2,t)=5;
 end
%����״̬
xk(:,t+1)=A*xk(:,t)+F*nk(:,t)+wk(:,t);
yk(:,t)=C*xk(:,t)+vk(:,t);

%���Ͻ������
%״̬���ƣ����ɵõ��в�qk
Pk_=Pk1_;
Kk_=A_*Pk_*C_'/(C_*Pk_*C_'+V_);
Pk1_=(A_-Kk_*C_)*Pk_*(A_-Kk_*C_)'+Kk_*V_*Kk_'+W_;
qk(:,t)=PAI*(yk(:,t)-C*xk_head(:,t));
gamak(:,t)=SIGMA*(yk(:,t)-C*xk_head(:,t));
xk_head(:,t+1)=A*xk_head(:,t)+B*uk(:,t)+omega*qk(:,t)+Kk_*gamak(:,t);

%��ͳ�������˲���������ֱ�Ӽ���в�
KFpk=KFpk1;
KFpk1_=A*KFpk*A'+W;
KFkk=KFpk1_*C'/(C*KFpk1_*C'+V);
KFpk1=(eye(n)-KFkk*C)*KFpk1_;
KFxkhead=A*KFxk(:,t)+B*uk(:,t);
KFxk(:,t)=KFxkhead+KFkk*(yk(:,t)-C*KFxkhead);
KFeyk(:,t)=yk(:,t)-C*KFxk(:,t);


end
figure(1)
plot(yk');
figure(2)
plot(qk');
figure(3)
plot(gamak');
figure(4)
plot(KFeyk');
%


        

