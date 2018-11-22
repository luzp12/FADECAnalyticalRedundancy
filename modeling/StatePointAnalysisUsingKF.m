clear;
%%1120更新:用selectdata.mat
load 'selectdata112102.mat';
abcd=[];
selectdata(selectdata(:,1)<40,:)=[];
figure(1)
plot(selectdata(:,1),'.');
theta=[0.547007683593049,0.623924750292026,0.00960824628939787,-0.198521652284297,1.17281525906111,0.0497519610959243,-0.0364278294826703,0.0431471952768373,0.222676549222758]';

startn1n=70;
for nn=startn1n:2:106
  tempdata=[];
  data=selectdata;
  data(data(:,1)<(nn-0.25),:)=[];
  data(data(:,1)>(nn+0.25),:)=[];
 if ~isempty(data)&&length(data)>150
  %初始值赋值
  P=10^3.*eye(9);
%   if nn>startn1n
%       theta=abcd((nn-startn1n)/2,2:10)';
%   end
for  k=1:length(data)
    
  %构建S、H矩阵
  S=data(k,2:4)';
  H=[ data(k,5:7) 0 0 0 0 0 0;
      0 0 0 data(k,5:7) 0 0 0;
      0 0 0 0 0 0 data(k,5:7)];
  
  A=eye(9);
  Q=zeros(9,9);
%   R=zeros(3,3);
 R=diag([0.0001,0.0001,0.0001]);
  
  %估计协方差矩阵Pguess:9*9
  Pguess=A*P*A'+Q;
  
  %计算增益K:9*3
  K=Pguess*H'/(H*Pguess*H'+R);
  
  %更新协方差矩阵
  P=(eye(9)-K*H)*Pguess; 
  
  %更新theta:9*1
  thetatemp=theta+K*(S-H*theta);
  [~,lambda]=eig([thetatemp(1,1) thetatemp(2,1);thetatemp(4,1) thetatemp(5,1)]);
  rou=max(max(abs(lambda)));
  rouk=1;
  %谱半径大于0.95时减小步长
  while(rou>0.9)
      thetatemp=theta+0.5^rouk*K*(S-H*theta);
      [~,lambda]=eig([thetatemp(1,1) thetatemp(2,1);thetatemp(4,1) thetatemp(5,1)]);
      rou=max(max(abs(lambda)));
      rouk=rouk+1;
  end
  theta=thetatemp;
%   ab=[theta(1:3);theta(4:6)];
%   cd=theta(7:9);
  tempdata=[tempdata;theta'];
 judgestep=40;
  if k>judgestep&&max(abs(theta'-mean(tempdata(k-judgestep+1:k,:))))<10e-4
      
      break;
      
  end
end


%  if max(sum((data(:,2:4)'-abcdtemp*data(:,5:7)').*(data(:,2:4)'-abcdtemp*data(:,5:7)')))/(length(data)-1)<0.3&&rou<1%&&min(min(abs(corrcoef(data(:,2:4),data(:,5:7)*abcdtemp'))))>0.8%&&abs(ab(1,1)+0.24-0.011*Ameanr(9+en))<0.03   
% theta=mean(tempdata(length(tempdata)-min(100,floor(length(tempdata)/10)):length(tempdata),:));
    abcd=[abcd;nn theta'];
 
%  end
%   figure(2)
%   plot(1:length(data),data(:,2:4),'.',1:length(data),data(:,5:7)*abcdtemp');
%   legend('N1','N2','EGT');

label={'a{_1_1}','a{_1_2}','b{_1_1}','a{_2_1}','a{_2_2}','b{_2_1}','c{_1_1}','c{_1_2}','d{_1_1}'};
  figure(2)
  for ntheta=1:9
      subplot(3,3,ntheta)
      plot(tempdata(:,ntheta));
      xlabel('Data Number');
      ylabel(label(ntheta));
      grid on;
  end
  end
end

abcd(abcd(:,1)<40,:)=[];
abcd(isnan(abcd(:,1)),:)=[];

for i=2:9
%     abcd(abs(abcd(:,i))>100,:)=[];
    abcd(isnan(abcd(:,i)),:)=[];
end
figure(3)
for i=2:10
subplot(3,3,i-1) 
plot(abcd(:,1),abcd(:,i),'.');
xlabel('N1{_r}');
ylabel(label(i-1));
end
