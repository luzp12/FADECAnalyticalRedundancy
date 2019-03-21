%==========================================================================
% Function: Compare matrix completion algorithms,such as SVT,Grouse&OptSpace
%
% SVT algorithm: the main part is completed by myself
% With reference to J.Cai,E.J.Cand¨¨ s et.al ¡°A singular value thresholding algorithm for matrix completion,¡±
%
% Grouse algorithm: the main part is completed by myself
% With reference to L. Balzano, R. Nowak and B. Recht, "Online Identification and Tracking of Subspaces from Highly Incomplete Information," 
%
% Lu Zepeng, id:2016211139
% Date:2016.12.8
% Project: Matrix Completion (Matrix analysis & application simulation homework)
%==========================================================================

%%   main code

%    set paramaters of our simulation experiment
%    note:for Grouse algorithm,we need m<=n
clear;
data=zeros(7,8);
A_row=[50,100,200,300,400,500,800];
A_column=[50,100,200,300,400,500,800];
sssam=[0.9 0.8 0.7 0.4 0.6 0.5 0.3];
sss=[30,5,5,8,10,15,20];
for size_step=1:length(A_row)
m=A_row(size_step);
n=A_column(size_step);
%
% for i=1:length(sss)
% m=1000;
% n=1000;
%    Reference sample rate: r*n^(1.25)*1g10(n)/(m*n)
%    m      n    reference rate                
%   100    100      0.06r     
%   200    200      0.04r     
%   500    500      0.026r     
%   500    1000     0.034r      
%  1000    1000     0.017r     
%  1000    2000     0.022r 
%  2000    2000     0.011r   
SamRate=sssam(size_step) ;
r=sss(size_step);
tic
[A,M,Omega]=LowRankMatrixBuilder(m,n,r,SamRate);
toc
%    max cycle number & result data matrix
max_cycle=10;
RMSE=zeros(max_cycle,2);
Rank_Error=zeros(max_cycle,2);
RunTime=zeros(max_cycle,2);
%    start
for k=1:max_cycle  
   [~,RMSE(k,1),Rank_Error(k,1),RunTime(k,1)]=SVT(A,M,Omega);
   [~,RMSE(k,2),Rank_Error(k,2),RunTime(k,2)]=Grouse(A,M,Omega);
    %[~,RMSE(k,3),Rank_Error(k,3),RunTime(k,3)]=OptSpace(A,M);
end
data(size_step,:)=[m,n,mean(RMSE),mean(Rank_Error),mean(RunTime)]
end
%plot(1:max_cycle,RMSE(1:max_cycle,3));