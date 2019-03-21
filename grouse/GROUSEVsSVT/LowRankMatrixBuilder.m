function [A,M,Omega]=LowRankMatrixBuilder(m,n,r,SamRate)
%==========================================================================
%Function: build a low-rank matrix A and the index set Omega of its sample matrix M
%
%Inputs:
%   [m,n]: row & column number of matrix A
%       r: rank of A, which is much smaller than m or n
% SampRate: rate of our sample number
%          in this case, our sample number=SamRate*m*n
%
%Outputs:
%       A: matrix we want to complete
%       M: the known part of A, a spara matrix where other elements are all zeros
%   Omega: the position index of the known elements of A
%
%Lu zepeng.2016.12.8
%==========================================================================


%%   Main code

%    Build a low-rank matrix randomly
A1 = randn(m,r);
A2 = randn(n,r);
A=A1*A2';
%    Get the sample set & its index
M=zeros(m,n);
Omega=zeros(m,n);
L=randperm(m*n);
L=L(1:SamRate*m*n);
for k=1:SamRate*m*n
    i=rem(L(k),m);
    if i==0
        i=m;
    end
    j=(L(k)-i)/m+1;
    M(i,j)=A(i,j);
    Omega(i,j)=1;
end