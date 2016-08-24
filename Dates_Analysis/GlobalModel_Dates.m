%% Prep Features for Classification (Amputee Data)

clear all
for Resample=0:1
% Resample=1;

nTrees=150;
Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
numAct=length(Activities);

Groups={'Train100', 'Train75', 'Train50', 'Train25'};

for indGroup=1:length(Groups)
    Group=Groups{indGroup};

load(['Z:\RERC- Phones\Server Data\DataByDate\Clips\' Group '\PhoneData_Feat.mat'])

AllFeat(6)=[];
AllFeat(11)=[];

Features=[];
Labels={};

%% Leave one subject out cross validation

k=zeros(length(AllFeat),1);
Acc=zeros(length(AllFeat),1);
ConfMat=cell(1,length(AllFeat));
PredLabels=cell(1,length(AllFeat));

x=load('Z:\RERC- Phones\Server Data\DataByDate\Clips\Test\PhoneData_Feat.mat');

x.AllFeat(6)=[];
x.AllFeat(11)=[];

y=load('Z:\RERC- Phones\Server Data\DataByDate\Clips\Train100\PhoneData_Feat.mat');

y.AllFeat(6)=[];
y.AllFeat(11)=[];

TrainingSizes=zeros(1,length(AllFeat));
for i=1:length(AllFeat)
    TrainingSizes(i)=size(AllFeat(i).Features,1);
end   
    
ReSampleSize=min(TrainingSizes);
if Resample
    repeats=10;
else
    repeats=1;
end


parfor indSubj=1:length(AllFeat)    
    ConfTemp=cell(1,5);
    
    Tinds=1:length(AllFeat)~=indSubj;
    
    for rep=1:repeats
    % Vector in first column of features indexes subjects
    temp=AllFeat(Tinds);
    Features=[];
    Labels={};
    for i=1:length(temp)
        if Resample
            X=rand(1,size(temp(i).Features,1));
            inds=find(X<ReSampleSize/size(temp(i).Features,1));
            Features=[Features; temp(i).Features(inds,:)];
            Labels=[Labels temp(i).ActivityLabel(inds)];      
        else
            Features=[Features; temp(i).Features(:,:)];
            Labels=[Labels temp(i).ActivityLabel];
        end
    end
    Labels=Labels.';
    if Resample
        X=rand(1,size(Features,1));
        inds=find(X<ReSampleSize/size(Features,1));
        Features=Features(inds,:);
        Labels=Labels(inds);       
    end
    
    % Use one Subject as test Data
    FeatTest=[x.AllFeat(indSubj).Features(:,:); y.AllFeat(indSubj).Features(:,:)]; 
    LabelTest=[x.AllFeat(indSubj).ActivityLabel y.AllFeat(indSubj).ActivityLabel];
    LabelTest=LabelTest.';

    RFModel=TreeBagger(nTrees, Features, Labels);
    [LabelsRF,P_RF] = predict(RFModel,FeatTest);

    TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
    ConfTemp{rep}=confusionmat(LabelTest, LabelsRF);
    end
    
    temp=[];
    for i=1:repeats
        temp=ConfTemp{i};
    end
    
    ConfMat{indSubj}=mean(temp,3);
    
end
    
WACC=zeros(13,3);
for i=1:13
    WACC(i,1)=sum(diag(ConfMat{i}))/sum(sum(ConfMat{i}));
    WACC(i,2)=nanmean(sum(ConfMat{i}-diag(diag(ConfMat{i}),0),2)./sum(ConfMat{i},2));
    WACC(i,3)=sum(sum(ConfMat{i}));
end
if ~Resample
    save(['Z:\RERC- Phones\Matlab Code\Dates\LOO_CV\ConfusionMat_' Group '.mat'], 'ConfMat', 'WACC');
else
    save(['Z:\RERC- Phones\Matlab Code\Dates\LOO_ReS_CV\ConfusionMat_' Group '.mat'], 'ConfMat', 'WACC');
end
end
end