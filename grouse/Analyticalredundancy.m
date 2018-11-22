clear;
% load engine data
% data parameters:
% column:time,0.25s per step
% row:variables,EGT(#1-4) FF(#1-4) N1(#1-4) N2(#1-4)
% all conversed & normalized
load 'Ar2020181118.mat';
A=Ar(2000:3000,2:17);

% set step number per calculation 
step=30;

% select variables to predict
xn=9;

% set rank guess for A, for refenrence rank(A(30,16),0.1)=6
maxrank=11;

% creat a new matrix for predicted data recording
Atest=zeros(size(A));

% load prepared subspace U, or random creat a new U
load 'U.mat';% U =orth(randn(step,maxrank)); 

% loop step by step
for n=step:length(A)
%     if n>200
     [Atest(n,xn),U]=ConstMatrixcompletion(A(n-step+1:n,:),xn,U);
%     else
%     [Atest(n,xn),U]=Matrixcompletion(A(n-step+1:n,:),xn,U);
%     end
end


% plot original data \ predicted dada \ relative error

figure(1)

xtime=step:length(A);

h1=plot(xtime,A(step:length(A),xn),'black');
hold on;

[Ax,h2,h3]=plotyy(xtime,Atest(step:length(A),xn),xtime,(Atest(step:length(A),xn)-A(step:length(A),xn))./A(step:length(A),xn));
set(h2,'color','red');
set(h3,'color','blue');

h=[h1 h2 h3];
legend(h,'measured','predicted','re');
grid on;

    