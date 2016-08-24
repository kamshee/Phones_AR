%% Prep Features for Classification (Amputee Data)

clear all

Resample=1;

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
    
    for rep=1:repeats
    % Vector in first column of features indexes subjects
    Features=AllFeat(indSubj).Features(:,:);
    Labels=AllFeat(indSubj).ActivityLabel;
    Labels=Labels.'; 

    if Resample
        X=rand(1,size(Features,1));
        inds=find(X<ReSampleSize/size(Features,1));
        Features=Features(inds,:);
        Labels=Labels(inds);       
    end
    
    % Use Last 10 percent as test data
    FeatTest=x.AllFeat(indSubj).Features(:,:);
    LabelTest=x.AllFeat(indSubj).ActivityLabel;
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
    
WACC=zeros(13,2);
for i=1:13
    WACC(i,1)=sum(diag(ConfMat{i}))/sum(sum(ConfMat{i}));
    WACC(i,2)=sum(sum(ConfMat{i}));
end

save(['ConfusionMat_' Group '.mat'], 'ConfMat', 'WACC');
end

