function SearchMagicPrams  
  [data,test]=dataFormat(0.9);
  trainData=userPrefrence(data);
  testData=test;
  rst=[];
  if(exist('UBCF_SIM.mat','file')>0)
      load('UBCF_SIM.mat');
  else
      SIM = SIMMatrix(trainData);
      save  UBCF_SIM.mat SIM;
  end

%   matlabpool local 2;  
%   parfor i=1:2
      [afa,beta,mae,rmse]=GranularRST(trainData,testData,SIM);
      rst=[rst; [afa,beta,mae,rmse]];
%   end
%   matlabpool close 
  save searchMagic.mat rst;
end

function [afa,beta,mae,rmse]=GranularRST(trainData,testData,SIM)
  afa=myrandom(0.3,1);
  beta=myrandom(0,0.5);
  [r,s]=EvaluateGranular(trainData,testData,SIM,10,afa,beta);
  [ mae,rmse ] = GlobalMAE(s);
end

function r=myrandom(a,b)
  r = a + (b-a).*rand(1);
end

function [result,statistics]=EvaluateGranular(trainData,testData,SIM,num,afa,beta)
  %格式化dataFormat();%用户分组%%1.构建用户偏好矩阵%matrix=userPrefrence(data);
  %%2.粗糙聚类
  %用户相似矩阵 
%   if(exist('Granular_clusterGene.mat','file')>0)
%       load('Granular_SIM.mat');
%       load('Granular_cluster.mat');
%       load('Granular_clusterGene.mat');
%   else
%       if(exist('UBCF_SIM.mat','file')>0)
%         SIM=cell2mat(struct2cell(load('UBCF_SIM.mat')));
%       else
        
%         save  UBCF_SIM.mat SIM;
%       end
      %SIM  = SIMMatrix(trainData);
      cluster = RoughCluster( SIM,afa,beta );
      %%3.类的基因（偏好）
      clusterGene=produceClusterGene(cluster,trainData);
%       save  Granular_SIM.mat SIM;
%       save  Granular_cluster.mat cluster;
%       save  Granular_clusterGene.mat clusterGene;
%   end
  %根据类获取??选集 %% 
  users=trainData(:,1);
  users(1)=[];
  itemsIndex=trainData(1,:);
  itemsIndex(1)=[];
  result=zeros(length(users),6);
  for i=1:length(users)
      userid=users(i);
      [candidateSet,statistic]=getCandidateSet(userid,trainData,cluster,clusterGene);
      itemsOrg=testData(testData(:,1)==userid,2:size(testData,2));
      [itemsRec,mae,compare]=recommendation(userid,trainData,candidateSet,num,true,itemsOrg,itemsIndex,statistic);
      THRESHOLD=getTHRESHOLDFromPreference(getPreference(userid,trainData(2:size(trainData,1),:)));
      result(i,:)=[userid,mae,EvaluateParam(itemsRec,itemsOrg,THRESHOLD),compare.radio];
      statistics(i)=compare;
  end
end