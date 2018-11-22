clear;
path = 'D:\FADECAnalyticalRedundancy\data\Tail_687_2\';
fext = '*.mat';
dt = dir([path fext]);
pt = {dt.name};
T0=288.15;%��׼�������£���λK�������¶�
P0=1.013e3;%��׼����ѹ����λMBar,����
B=zeros(1,20);

selectdata=[];
% for k = 1:length(pt)
for k = 1:100
    load(dt(k).name);
    M=length(ALT.data);N=20;
    if max(TAS.data)>200
        k
        A=zeros(M,N);
        % B=zeros(100,N);
        %��Ŀ�������ȡ��A����
        A(:,1)=ALT.data;
        A(:,2)=(EGT_1.data+273.15)./10;
        A(:,3)=(EGT_2.data+273.15)./10;
        A(:,4)=(EGT_3.data+273.15)./10;
        A(:,5)=(EGT_4.data+273.15)./10;
        A(:,6)=FF_1.data./30;
        A(:,7)=FF_2.data./30;
        A(:,8)=FF_3.data./30;
        A(:,9)=FF_4.data./30;
        A(:,10)=N1_1.data;
        A(:,11)=N1_2.data;
        A(:,12)=N1_3.data;
        A(:,13)=N1_4.data;
        A(:,14)=N2_1.data;
        A(:,15)=N2_2.data;
        A(:,16)=N2_3.data;
        A(:,17)=N2_4.data;
        %����٣���λknots��
        A(:,18)=TAS.data.*0.5144444;
        %���£���λ���϶�
        A(:,19)=interp1(1:length(TAT.data),TAT.data,0.25:0.25:length(TAT.data),'linear')+273.15;
        %��ѹ����λMb��+
        A(:,20)=interp1(1:length(PT.data),PT.data,0.5:0.5:length(PT.data),'linear');
        % A=A(3931:3960,:);
        A0=A;
        %�޳��������ݣ���Fn=30Ϊ��λ����ȡ3��ԭ��
        Fn=30;
        for i=1:floor(length(A)/Fn)
            Amean=mean(A(Fn*(i-1)+1:Fn*i,:));
            Asigma=std(A(Fn*(i-1)+1:Fn*i,:));
           for j=1:Fn
            if sum(abs(A(Fn*(i-1)+j,:)-Amean)>3*Asigma)>0.1||sum(isnan(A(Fn*(i-1)+j,:)))>0.1
%                  A(Fn*(i-1)+j,:)=zeros(1,N);
                   A(Fn*(i-1)+j,:)= A(max(1,Fn*(i-1)+j-1),:);
            end
           end
        end
%       A(all(A==0,2),:)=[];
        for i=1: N
            A(isnan(A(:,i)),:)=[];
        end
        A=A(1000:length(A)-100,:);
       
        Af=A;
        
%%     �˲�
        for ss=1:N
%         Af(:,ss)=smooth(A(:,ss),5);
        Af(:,ss)=medfilt1(A(:,ss),10);
        
        end
        %���ƻ���
        Ar=Af;
        for en=1:4
                Ar(:,1+en)=A(:,1+en).*(T0./A(:,19)).^0.5;
                Ar(:,5+en)=A(:,5+en).*(T0./A(:,19)).^0.5.*P0./A(:,20);
                Ar(:,9+en)=A(:,9+en).*(T0./A(:,19)).^0.5;
                Ar(:,13+en)=A(:,13+en).*(T0./A(:,19)).^0.5;
                figure(2)
                subplot(2,2,en);
                plot(1:length(Ar),Ar(:,5+en),1:length(Ar),Ar(:,9+en));
                legend('WFr','N1r');
        end
%%     ѡ����ʽ׶Σ���Sn=40sample=10sΪ��λ��
        %��������Ϊȥ�����ġ���һ�ģ�100%�����������
        Sn=100;

        for i=1:floor(length(Ar)/Sn)
            Ameanr=mean(Ar(Sn*(i-1)+1:Sn*i,:));
            steadyflag=1;
           
%            if max(max(diff(Ar(Sn*(i-1)+1:Sn*i,2:17))))<0.05||min(min(diff(Ar(Sn*(i-1)+1:Sn*i,2:17))))>-0.05
%                   steadyflag=1;
%            else
%                   steadyflag=0;
%            end
%            
            for j=1:Sn
            if max(abs((Ar(Sn*(i-1)+j,2:17)-Ameanr(2:17))./Ameanr(2:17)))>0.01
                 steadyflag=0;
            end
            end
           
            %��������Ϊ��̬����ʱ
           if  steadyflag==1
                %��ȡ��̬��
                B=[B;Ameanr];


                
%                 Ar=zeros(Sn,N);
%                 EGTr=[];WFr=[];N1r=[];N2r=[];
%                 
                %���ƻ���
%                for en=1:3   %���������1-4  
                                    %��̬�㻻��
                   
%                     Ameanr(1,1+en)=Amean(1,1+en).*(T0./Amean(1,19)).^0.5;
%                     Ameanr(1,5+en)=Amean(1,5+en).*(T0./Amean(1,19)).^0.5.*P0./Amean(:,20);
%                     Ameanr(1,9+en)=Amean(1,9+en).*(T0./Amean(1,19)).^0.5;
%                     Ameanr(1,13+en)=Amean(1,13+en).*(T0./Amean(1,19)).^0.5;
                    %��̬�㸽������Ԥ����

% 
%                     Ar(:,1+en)=A(Sn*(i-1)+1:Sn*i,1+en).*(T0./A(Sn*(i-1)+1:Sn*i,19)).^0.5;
%                     Ar(:,5+en)=A(Sn*(i-1)+1:Sn*i,5+en).*(T0./A(Sn*(i-1)+1:Sn*i,19)).^0.5.*P0./A(Sn*(i-1)+1:Sn*i,20);
%                     Ar(:,9+en)=A(Sn*(i-1)+1:Sn*i,9+en).*(T0./A(Sn*(i-1)+1:Sn*i,19)).^0.5;
%                     Ar(:,13+en)=A(Sn*(i-1)+1:Sn*i,13+en).*(T0./A(Sn*(i-1)+1:Sn*i,19)).^0.5;
                   
                    %��ѡ���ʵ���̬���ݽ�������ģ����ȡ
%                     if min([std( Ar(:,1+en)),std( Ar(:,5+en)),std( Ar(:,9+en)),std( Ar(:,13+en))])>0.2%&&(min(min( Ar(2:Sn,[5]+en)- Ar(1:Sn-1,[ 5 ]+en)))>=0||max(max( Ar(2:Sn,[ 5 ]+en)- Ar(1:Sn-1,[ 5 ]+en)))<=0)
%                    if (min(min( Ar(2:Sn,[5]+en)- Ar(1:Sn-1,[ 5 ]+en)))>=0||max(max( Ar(2:Sn,[ 5 ]+en)- Ar(1:Sn-1,[ 5 ]+en)))<=0)
                    %if min([std( Ar(:,1+en)),std( Ar(:,5+en)),std( Ar(:,9+en)),std( Ar(:,13+en))])>0.2
                    %
%                     DXr=[Ar(Sn*(i-1)+1:Sn*i,9+en)-Ameanr(9+en),Ar(Sn*(i-1)+1:Sn*i,13+en)-Ameanr(13+en)];
%                     DYr=Ar(Sn*(i-1)+1:Sn*i,1+en)-Ameanr(1+en);
%                     DUr=Ar(Sn*(i-1)+1:Sn*i,5+en)-Ameanr(5+en);
%                     
% 
%                     yX=DXr(2:Sn,:);xXU=[DXr(1:Sn-1,:) DUr(1:Sn-1,:)];
%                     yY=DYr(1:Sn-1,:);
%                     selectdata=[selectdata;Ameanr(9+en).*ones(Sn-1,1) yX yY xXU];
%                     abcdtemp=[yX';yY']/xXU';
%                     ab=abcdtemp(1:2,:);
%                     cd=abcdtemp(3,:);
% 
%                    
% %                     cd=ycd'/xcd';
% 
%                     %��һЩ��ѡ��ѡ���������Ϻõ�ģ��
%                         if max(sum(([yX,yY]-xXU*abcdtemp').*([yX,yY]-xXU*abcdtemp')))/(Sn-1)<0.01&&min(min(abs(corrcoef([yX,yY],xXU*abcdtemp'))))>0.9%&&abs(ab(1,1)+0.24-0.011*Ameanr(9+en))<0.03
%                             
%                             abcd=[abcd;Ameanr(9+en) ab(1,:) ab(2,:) cd];
%                             figure(3)
%                             plot(1:Sn-1,[yX,yY],'.',1:Sn-1,xXU*abcdtemp');
%                             legend('N1','N2','EGT');
%                         end
%               end 
                
                %y=ab*x===>y'=x'*ab'
                %����
           end
        end
    else
        dt(k).name
    end
   


end;

plot(B(:,2:5));
legend('EGT','WF','N1','N2');


