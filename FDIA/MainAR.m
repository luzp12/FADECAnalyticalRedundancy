clear;
close all;
%��������
load Data01.mat;
load DataJudgement.mat;

%�ܱ�����,����n��������
n=8;
M=A(:,1:n);
Mc=zeros(size(M));
for AR_Sensor=1:n
%��������������,�ӿռ�ά��,��ʼ���ӿռ�
m=30;maxrank=6;
U =orth(randn(m,maxrank));
%Ԥ��������ù۲����
% AR_Sensor=[2];
Omega=ones(m,n);
Omega(m,AR_Sensor)=0;
%Ȩ��ϵ������
Psai0=diag([ones(1,m)]);
%  Psai0=diag([1:0.04:2.16]);


%%��ʼ����
% Mc=M;
for k=m:length(M)
  %��ȡ��������
  Mk=M(k-m+1:k,:);
  %��һ��
  [NMk,minMk,maxMk]=NormalData(Mk);
  %����
  [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,AR_Sensor);
  %����һ��
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  Mc(k,AR_Sensor)=Mkc(m,AR_Sensor);
%   M(k,AR_Sensor)=Mc(k,AR_Sensor);
end
end

MainAR_Plot;