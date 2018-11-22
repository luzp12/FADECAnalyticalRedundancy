clear;
load 'selectdata.mat';
abcd=[];
selectdata(selectdata(:,1)<40,:)=[];
figure(1)
plot(selectdata(:,1),'.');


for nn=50:2:95
  data=selectdata;
  data(data(:,1)<(nn-0.25),:)=[];
  data(data(:,1)>(nn+0.25),:)=[];
%   subplot(3,3,nn/5-8);
%   plot
ab=data(:,2:3)'/data(:,5:7)';
cd=data(:,4)'/data(:,5:7)';
abcdtemp=[ab;cd];
%   ab=abcdtemp(1:2,:);
%   cd=abcdtemp(3,:);

                   
%                     cd=ycd'/xcd';

                    %做一些挑选，选择拟合情况较好的模型
  [~,lambda]=eig(ab(1:2,1:2));
% [~,lambda]=eig([-3.8557,1.4467;0.4690,-4.7081]);
rou=max(max(abs(lambda)));
 if max(sum((data(:,2:4)'-abcdtemp*data(:,5:7)').*(data(:,2:4)'-abcdtemp*data(:,5:7)')))/(length(data)-1)<0.3&&rou<1%&&min(min(abs(corrcoef(data(:,2:4),data(:,5:7)*abcdtemp'))))>0.8%&&abs(ab(1,1)+0.24-0.011*Ameanr(9+en))<0.03

    abcd=[abcd;nn ab(1,:) ab(2,:) cd];
 end
 figure(2)
  plot(1:length(data),data(:,2:4),'.',1:length(data),data(:,5:7)*abcdtemp');
  legend('N1','N2','EGT');
% end
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
end
