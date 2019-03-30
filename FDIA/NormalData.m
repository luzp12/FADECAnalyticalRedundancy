function [NM,minM,maxM]=NormalData(M)
[m,~]=size(M);
minM=repmat(min(M),m,1);
maxM=repmat(max(M),m,1)+0.1;
NM=(M-minM)./(maxM-minM)+0.5;

