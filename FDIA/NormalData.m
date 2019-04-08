function [NM,minM,maxM]=NormalData(M,D)
[m,~]=size(M);
minM=repmat(min(D),m,1);
maxM=repmat(max(D),m,1)+0.1;
NM=(M-minM)./(maxM-minM)+0.5;
% NM=M-(minM+maxM)*0.5;

