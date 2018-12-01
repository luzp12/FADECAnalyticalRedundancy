
%%文章内容复现，带有故障解耦功能的滤波器。并与传统滤波器做了对比
%Keller, J.Y., Fault isolation filter design for linear stochastic systems. Automatica, 1999. 35(10): p. 1701-1706.
%特点：只需要知道对象模型和故障模型，A B C F矩阵，根据y的观测值即可计算残差q,q的每一项分别代表了F对应的一个故障
clear;
A=[0.2 1 0 0.2; 0 0.5 1 0.4; 0 0 0.8 1; 0 0 0 0.3];
C=[0 1 0 0;0 0 1 0;0 0 0 1];

% C=randn(3,4);
[m,n]=size(C);
B=zeros(n,1);
%故障分布矩阵
F=[-1 1;1 0; 0 -1; 1 1];
% F=[null(C) F];


W=[0.9 0 0 0; 0 0 0 0;0 0 0.5 0; 0 0 0 0.3];
V=eye(m);
%%计算过程

%计算rou值
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

%计算Psai和D
Psai_=[];
for i=1:max(rou)
       Psai_=[Psai_ A^(i-1)*F(:,find(rou==i))];
end
D_=C*Psai_;

%计算SIGMA和PAI
PAI=eye(widthF)/D_;
SIGMA=randn(m-widthF,m)*(eye(m)-D_*PAI);
omega=A*Psai_;
A_=A-omega*PAI*C;
C_=SIGMA*C;
V_=SIGMA*SIGMA';
W_=W+omega*(PAI*PAI')*omega';

%%仿真计算
%初始化
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
 %模型部分 
  
 if t>=50 
     nk(1,t)=10*sin(0.1*t);
 end
 if t>=120
     nk(2,t)=5;
 end
%更新状态
xk(:,t+1)=A*xk(:,t)+F*nk(:,t)+wk(:,t);
yk(:,t)=C*xk(:,t)+vk(:,t);

%故障解耦方法：
%状态估计，即可得到残差qk
Pk_=Pk1_;
Kk_=A_*Pk_*C_'/(C_*Pk_*C_'+V_);
Pk1_=(A_-Kk_*C_)*Pk_*(A_-Kk_*C_)'+Kk_*V_*Kk_'+W_;
qk(:,t)=PAI*(yk(:,t)-C*xk_head(:,t));
gamak(:,t)=SIGMA*(yk(:,t)-C*xk_head(:,t));
xk_head(:,t+1)=A*xk_head(:,t)+B*uk(:,t)+omega*qk(:,t)+Kk_*gamak(:,t);

%传统卡尔曼滤波器方法，直接计算残差
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


        

