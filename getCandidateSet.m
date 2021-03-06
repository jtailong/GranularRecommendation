function [candidateSet,statistic]=getCandidateSet(userid,userPreference,cluster,clusterGene)
  userGene=getPreference(userid,userPreference);
  num=length(cluster);
  %countN=0;
  sims=zeros(num,2);
  for i=1:num
    if any(userid==cluster{i})
        sim=personCorrelation(userGene,clusterGene(i,:));
        if ~isnan(sim) && sim~=0
            sims(i,1)=sim;
            sims(i,2)=i;
            %countN=countN+1;
        end
    end
  end
 
  set=zeros(num,length(clusterGene));
  for i=1:num
      if(sims(i,2)~=0)
        set(i,:)=sims(i,1).*clusterGene(sims(i,2),:);
      end
  end
  set(isnan(set))=0;
  candidateSet=sum(set);
  
   %��һ��
  %sims(:,1)=sims(:,1).*(1/sum(sims(:,1)));
  for i=1:length(candidateSet)
      countN=sum(sims(set(:,i)>0,1)>0);
      if countN>1
        candidateSet(i)=candidateSet(i)/sum(sims(set(:,i)>0,1));
      else
        candidateSet(i)=0;
      end
  end
  statistic=sum(set>0)/size(set,1);
 % radio=sum(sims(:,1)>0)/length(sims);
end
