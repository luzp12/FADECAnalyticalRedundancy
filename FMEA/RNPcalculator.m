load Collect_rank.mat;

%%数据整理，形成完整表格
for i=1:length(rank0)-1
    if rank0(i+1,1)==0
        rank0(i+1,1)=rank0(i,1);
    end
    for j=2:2:8
        if rank0(i,j)~=0&&rank0(i,j+1)==0
            rank0(i,j+1)=100;
        end
    end
end    

%%初步D-S合成
rank1=zeros(83,10);
rank1(:,1)=rank0(:,1);
for  i=1:length(rank0)-1
    
    if rank0(i,1)==rank0(i+1,1)
        for j=[2 6]
            A=[rank0(i,j),rank0(i,j+2),rank0(i+1,j),rank0(i+1,j+2)];
        rank1(i,j)=max(A);
        A(A==rank1(i,j))=[];
        rank1(i+1,j)=max(A);
        numtemp=[rank0(i,j) rank0(i,j+2) rank0(i+1,j) rank0(i+1,j+2)];
        ranktemp=[rank0(i,j+1) rank0(i,j+3) rank0(i+1,j+1) rank0(i+1,j+3)];
        pos1=find( numtemp==rank1(i,j));
        if length(pos1)>1
                ans1= ranktemp(pos1(1))*ranktemp(pos1(2));
            else
                ans1=0;
        end
        
         pos2=find( numtemp==rank1(i+1,j));
        if length(pos2)>1
                ans2= ranktemp(pos2(1))*ranktemp(pos2(2));
            else
                ans2=0;
        end
        rank1(i,j+1)=ans1/(ans1+ans2)*100;
        rank1(i+1,j+1)=ans2/(ans1+ans2)*100;
        end
        rank1(i,10)=rank0(i,10);
         rank1(i+1,10)=rank0(i+1,10);
    elseif rank0(i,1)==rank0(i-1,1)
            
    else
           rank1(i,:)=rank0(i,:);
    end
end

%最终计算
rank2=zeros(45,1);
for i=1:length(rank1)-1
 if rank1(i,1)==rank1(i+1,1)
     rank2(rank0(i,1))=rank1(i,2)*rank1(i,6)*rank1(i,10)*rank1(i,3)*rank1(i,7)+rank1(i,2)*rank1(i+1,6)*rank1(i,10)*rank1(i,3)*rank1(i+1,7) +rank1(i+1,2)*rank1(i,6)*rank1(i,10)*rank1(i+1,3)*rank1(i,7) +rank1(i+1,2)*rank1(i+1,6)*rank1(i,10)*rank1(i+1,3)*rank1(i+1,7);
     rank2(rank0(i,1))=rank2(rank0(i,1))/10000;
 elseif rank1(i,1)==rank1(i-1,1)
            
    else
           rank2(rank0(i,1))=rank1(i,2)*rank1(i,6)*rank1(i,10);
           
 end
end
