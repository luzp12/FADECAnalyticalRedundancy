function [X,RMSE,Rank_Error,RunTime]=Grouse(A,M,Omega)
%% Grouse algorithm for matrix completion
% With reference to L. Balzano, R. Nowak and B. Recht, "Online Identification and Tracking of Subspaces from Highly Incomplete Information," 
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
tic;

% Set initial parameters
%    Size of matrix A & M
[m,n]=size(M);
%    Guess of the rank
maxrank=rank(A)+5;
%    Max cycle number
kmax=10;
%    Factor of stepsize
yita=0.1;
%    random & orthogonal matrix U 
U =orth(randn(m,maxrank)); 

% Cycle & compute 
for out_k=1:kmax
    %    Random sort
    a=randperm(n);
    
    %    Renew subspace for every column of M
    for in_k=1:n
        %    Project M & U to Omega(column(in_k))
        v_Omega=M(:,a(in_k));
        U_Omega=Project_Omega(U,Omega(:,a(in_k)));
        %    Compute optimization w
        w=U_Omega\v_Omega;
        %    Predict whole vector p
        p=U*w;
        %    Compute residual res
        res=v_Omega-U_Omega*w;
        %    Renew U
        sigma=norm(res)*norm(w);
        t=yita*sigma/((out_k-1)*n+in_k);
        %    Stop cycle when t is big enough 
        if sin(t)>0, 
        %    Get new U matrix
         U=U+(sin(t)*res/norm(res)+(cos(t)-1)*p/norm(p))*w'/norm(w); 
        end
    end
end
% Compute approximate matrix X=UR' 
R = zeros(n,maxrank);
for k=1:n,     
    %    Projection  M & U to every column of Omega in order
    v_Omega=M(:,k);
    U_Omega=Project_Omega(U,Omega(:,k));
    %    Compute R 
    R(k,:) = (U_Omega\v_Omega)';
end
X=U*R';
RMSE=norm(A-X,'fro')/(abs(max(max(A)))*sqrt(m*n));
Rank_Error=abs(rank(A)-rank(X));
RunTime=toc;


%% Function to project one vector or matrix P0 to certain set Omega
function P=Project_Omega(P0,Omega)
%%=========================================================================
% Inputs:
%     P0: vector or matrix  needto be projected
%  Omega: aim set of the projection
% 
% Output:
%      P: Projection of P0 to Omega
% =========================================================================

% main code
[m,n]=size(P0);
P=zeros(m,n);
for i=1:m
    % Row i of P is nonzero only in positon where Omega(i)=1 
        if Omega(i)==1
            P(i,:)=P0(i,:);
        end
end

