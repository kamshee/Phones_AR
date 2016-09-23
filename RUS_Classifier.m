%% Prep Features for Classification

clear all

ntrees=200;

rmvFeat=1;
if rmvFeat
    load NormImp
    FeatInds=find(norm_imp>.25);
else
    FeatInds=1:270;
end

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
% Activities={'Sitting', 'Lying', 'Standing', 'Walking'};
numAct=length(Activities);

load('Z:\RERC- Phones\Server Data\Clips\10s\PhoneData_Feat.mat')

Features=[];
Labels={};

for indSubj=1:length(AllFeat)
    tempLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of features indexes subjects
    SubjectV=ones(length(tempLabels),1)*indSubj; 
    Features(end+1:end+length(tempLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    Labels=[Labels tempLabels];
end
Labels=Labels.';

err=cell(1,length(AllFeat));
%% Balance Classes
    NewFeatures=Features;
    NewLabels=Labels;


%% Leave one subject out cross validation

k=zeros(length(AllFeat),1);
Acc=zeros(length(AllFeat),1);
% ConfMat=zeros(numAct,numAct,length(AllFeat));
ConfMat=cell(1,length(AllFeat));
PredLabels=cell(1,length(AllFeat));
for indSubj=1:length(AllFeat)
% for indSubj=1:1

    TrainInd=find(NewFeatures(:,1)~=indSubj);
    FeatTrain=NewFeatures(TrainInd,FeatInds+1);
    LabelTrain=NewLabels(TrainInd);

    TestInd=find(Features(:,1)==indSubj);
    FeatTest=Features(TestInd,FeatInds+1);
    LabelTest=Labels(TestInd);

    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(FeatTrain,LabelTrain,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,FeatTest);

    %figure; plot(loss(RFModel,FeatTest,LabelTest,'mode','cumulative'))
    %savefig(['Features25/RUS_Subj_' num2str(indSubj) '.fig'])

    TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
    k(indSubj)=length(TPInd);
    Acc(indSubj)=sum(TPInd)/k(indSubj);

    ConfMat{indSubj}=confusionmat([Activities'; LabelTest], [Activities'; LabelsRF])-eye(6);
    PredLabels{indSubj}=LabelsRF;

    % Find missing classes and replace them
    u=unique([LabelTest; LabelsRF]);
    n_missing=zeros(1,6);
    for uind=1:length(u)
        n_missing(strcmp(u(uind),Activities))=1;
    end
    z_inds=find(~n_missing);
    for m=z_inds
        if m==1
            ConfMat{indSubj}=[zeros(1,size(ConfMat{indSubj},2)); ConfMat{indSubj}(m:end,:)];
            ConfMat{indSubj}=[zeros(size(ConfMat{indSubj},1),1) ConfMat{indSubj}(:,m:end)];
        else
            ConfMat{indSubj}=[ConfMat{indSubj}(1:m-1,:); zeros(1,size(ConfMat{indSubj},2)); ConfMat{indSubj}(m:end,:)];
            ConfMat{indSubj}=[ConfMat{indSubj}(:,1:m-1) zeros(size(ConfMat{indSubj},1),1) ConfMat{indSubj}(:,m:end)];
        end
    end

end

save RUSConfusion.mat ConfMat
%% Calculations to evaluate models
for i=1:size(ConfMat,3)
    ConfMatAll(:,:,i)=ConfMat{i};
end

ConfMatAll=sum(ConfMatAll,3);
% figure;
% bar(ActCounts);
% set(gca,'XTickLabels',Activities)

for i=1:length(Activities)
    precision(i)=ConfMatAll(i,i)/sum(ConfMatAll(:,i));
    recall(i)=ConfMatAll(i,i)/sum(ConfMatAll(i,:));
    F1(i)=2*precision(i)*recall(i)/(precision(i)+recall(i));
end

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)


WAcc=sum(diag(ConfMatAll))/sum(sum(ConfMatAll));