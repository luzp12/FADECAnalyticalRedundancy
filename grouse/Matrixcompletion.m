function [y,U]=Matrixcompletion(A,xn,U)

%矩阵的秩的猜想值
maxrank=11;
kmax=30;yita=0.1;
% [A,M,Omega]=LowRankMatrixBuilder(m,n,r,SampleNumber);
%初始化
%yita=1;
[m,n]=size(A);
a=zeros(n,1);
Omega=ones(m,n);
M=A;
Omega(m,xn)=0;
M(m,xn)=0;
Psai0=diag([ones(m-2,1);1.5;2]);
for out_k=1:kmax
    %排列
    a=randperm(n);
    for in_k=1:n
        %更新子空间
        idx=find(Omega(:,a(in_k)));
        v_Omega=M(idx,a(in_k));
        U_Omega=U(idx,:);
        %计算权重w
        Psai=Psai0(1:length(idx),1:length(idx));
        w=(Psai*U_Omega)\(Psai*v_Omega);
        %预测全向量p=U*w;
        res=v_Omega-U_Omega*w;%计算残量
        sigma=norm(res)/norm(w);
        %更新子空间
        t=yita*sigma/((out_k-1)*n+in_k);
         if t<pi/2 % drop big steps        
        alpha = (cos(t)-1)/norm(w)^2;
        beta = sin(t)/sigma;
        step = U*(alpha*w);
        step(idx) = step(idx) + beta*res;
        U = U + step*w';
         end 
    end
end
% fprintf('Find column weights...');
R = zeros(n,maxrank);
for k=1:n,     
    % Pull out the relevant indices and revealed entries for this column
    idx = find(Omega(:,k));
    v_Omega = M(idx,k);
    U_Omega = U(idx,:);
    % solve a simple least squares problem to populate R
     Psai=Psai0(1:length(idx),1:length(idx));
     R(k,:)=(Psai*U_Omega)\(Psai*v_Omega);
end
X=U*R';
Z=X-A;
y=X(m,xn);
% norm(Z,'fro')/norm(A,'fro')

