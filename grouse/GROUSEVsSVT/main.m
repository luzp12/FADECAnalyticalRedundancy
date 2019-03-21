%==========================================================================
% Function: Compare matrix completion algorithms,such as SVT,Grouse&OptSpace
%
% SVT algorithm: the main part is completed by myself
% With reference to J.Cai,E.J.Cand¨¨ s et.al ¡°A singular value thresholding algorithm for matrix completion,¡±
%
% Grouse algorithm: the main part is completed by myself
% With reference to L. Balzano, R. Nowak and B. Recht, "Online Identification and Tracking of Subspaces from Highly Incomplete Information," 
%
%Inputs:
%          m,n: size of A & M
%      SamRate: rate of sample
%            r: rank of A
%
%Outputs:
%          X: matrix completed to approximate A
%       RMSE: relative error of A & X in Frobenius norm
% Rank_Error:defference between the rank of A & X
%    RunTime: total time used for SVT algorithm
% Lu Zepeng, id:2016211139
% Date:2016.12.13
% Project: Matrix Completion (Matrix analysis & application simulation homework)
%==========================================================================

%%   main code
clear;
% set paramaters of our simulation experiment
% *************************************************************************
%    size of A & M
%    note:for Grouse algorithm,we need m<=n
m=1000;n=1000;
%    sample rate
%    reference sample rate: r*n^(1.25)*1g10(n)/(m*n)
%    m      n    reference rate                
%   100    100      0.06r     
%   200    200      0.04r     
%   500    500      0.026r     
%   500    1000     0.034r      
%  1000    1000     0.017r     
%  1000    2000     0.022r 
%  2000    2000     0.011r   
SamRate=0.4;
%    rank(A)
%    note:there should be r<<n
r=5;
%**************************************************************************

% build low_rank matrix A & samlpe collection M & index matrix Omega
[A,M,Omega]=LowRankMatrixBuilder(m,n,r,SamRate);

% start completion
   %[X_SVT,RMSE_SVT,Rank_Error_SVT,RunTime_SVT]=SVT(A,M,Omega);
   [X_Grouse,RMSE_Grouse,Rank_Error_Grouse,RunTime_Grouse]=Grouse(A,M,Omega);
% end 