function [X,RMSE,Rank_Error,RunTime]=SVT(A,M,Omega)
%% Singular value thresholding(SVT) algorithm for matrix completion
% With reference to J.Cai,E.J.Cand¨¨ s et.al ¡°A singular value thresholding algorithm for matrix completion,¡±
%
%  Inputs:
%          A: matrix we want to complete
%          M: the known part of A, a spara matrix where other elements are all zeros
%      Omega: the position index of the known elements of A
%
% Outputs:
%          X: Matrix we complete to approximate A
%       RMSE: Relative error of A & X in Frobenius norm
% Rank_Error:Defference between the rank of A & X
%    RunTime: total time used for SVT algorithm
%
% Lu Zepeng, id:2016211139
% Date:2016.12.8


%%    Main code

% Start timing 
tic;

% Set initial parameters
%    size of A & M   
[m,n]=size(M);
SampleNumber=nnz(M);
%    Step size: delta
delta=1.2*m*n/SampleNumber;
%    Tolerance: epsilon
epsilon=10^-5;
%    Parameter: tao
tao=5*max(m,n);
%    Increment:L
L=1;
%    Max cycle number Kmax
Kmax=2000;
%    Get initial Y0
k0=ceil(tao/(delta*norm(M,2)));
Y=k0*delta*M;
%    Set initial rk, 
rk=0;

% Start cycle & compute    
for k=1:Kmax
    %    Get rk, s.t.: rk=max(j|sigular(j)>tao)
    s=rk+1;
    [U,S,V]=svd(Y);
    for i=1:min(m,n)-rk
        s=s+L;
        if S(s-L,s-L)<=tao
            break;
        end
    end
    rk=s-2*L;
    
    %    Renew X & Y
    X=U(:,1:rk)*(S(1:rk,1:rk)-tao*eye(rk,rk))*V(:,1:rk)';
    POmegaX_M=zeros(m,n);  
    for i=1:m
        for j=1:n
            if Omega(i,j)==1
                Y(i,j)=Y(i,j)+delta*(M(i,j)-X(i,j));
                POmegaX_M(i,j)=X(i,j)-M(i,j);
            end
        end
    end
    
    %    Judge relative error
    if norm(POmegaX_M,'fro')/norm(M,'fro')<=epsilon
            break;
    end
end

% Get result & output
RMSE=norm(A-X,'fro')/(abs(max(max(A)))*sqrt(m*n));
Rank_Error=abs(rank(A)-rank(X));
RunTime=toc;