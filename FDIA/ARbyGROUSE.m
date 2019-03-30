function [Mc,U]=ARbyGROUSE(U,M,Omega,maxrank,Psai0,NoUpdate)
%% Grouse algorithm for Analytical Redundancy
% With reference to L. Balzano, R. Nowak and B. Recht, "Online Identification and Tracking of Subspaces from Highly Incomplete Information," 
%
%  Inputs:
%      U: original subspace  ,U =orth(randn(m,maxrank));   
%      M: original matrix
%      Omega: the position index of the known elements of M
%      maxrank: estimation of rank(M)
%      Psai0:weight @ time
%
% Outputs:
%          Mc: Matrix we complete to approximate M
%%    Main code
tic;

% Set initial parameters
%    Size of matrix A & M
[m,n]=size(M);
%    Max cycle number
kmax=10;
%    Factor of stepsize
yita=0.1;

% Cycle & compute 
for out_k=1:kmax
    %    Random sort
    a=randperm(n);
    
    %    Renew subspace for every column of M
    for in_k=1:n
        %    Project M & U to Omega(column(in_k))
         if isempty(find(NoUpdate==a(in_k)))==1
            idx=find(Omega(:,a(in_k)));
            v_Omega=M(idx,a(in_k));
            U_Omega=U(idx,:);
            %    Compute optimization w
            Psai=Psai0(1:length(idx),1:length(idx));
            w=(Psai*U_Omega)\(Psai*v_Omega);
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
                alpha = (cos(t)-1)/norm(w)^2;
                beta = sin(t)/sigma;
                step = U*(alpha*w);
                step(idx) = step(idx) + beta*res;
                U = U + step*w';
            end
        else
            U=U;
%            fprintf('%d: %d \n',out_k,a(in_k));
        end
    end
end
% Compute approximate matrix X=UR' 
R = zeros(n,maxrank);
for k=1:n,     
    %    Projection  M & U to every column of Omega in order
    idx = find(Omega(:,k));
    v_Omega = M(idx,k);
    U_Omega = U(idx,:);
    %    Compute R 
    Psai=Psai0(1:length(idx),1:length(idx));
    R(k,:)=(Psai*U_Omega)\(Psai*v_Omega);
end
Mc=U*R';


