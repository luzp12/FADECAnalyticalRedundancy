
function [y,U]=ConstMatrixcompletion(A,xn,U)

%矩阵的秩的猜想值
maxrank=11;
% [A,M,Omega]=LowRankMatrixBuilder(m,n,r,SampleNumber);
%初始化
%yita=1;
[m,n]=size(A);
Omega=ones(m,n);
M=A;
Omega(m,xn)=0;
M(m,xn)=0;
Psai0=diag([ones(m-2,1);1.5;2]);
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
y=X(m,xn);