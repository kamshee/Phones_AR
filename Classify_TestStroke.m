%% Train on Healthy, Test on Stroke

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


%% Load test data (Stroke) and evaluate model

load('Z:\RERC- Phones\Stroke\Clips\Test_Feat.mat')
TestFeatures=[];
TestLabels={};

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    TestFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    TestLabels=[TestLabels tempTestLabels];
end

load('Z:\RERC- Phones\Stroke\Clips\Train_Feat.mat')

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    TestFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    TestLabels=[TestLabels tempTestLabels];
end

indHomeStart=length(TestFeatures);

load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    TestFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).TestFeatures(:,:)];
    TestLabels=[TestLabels tempTestLabels];
end

TestLabels=TestLabels.';

FeatTrain=Features(:,2:end);
LabelTrain=Labels;

% Healthy --> Stroke all
FeatTest=TestFeatures(:,2:end);
LabelTest=TestLabels;

t = templateTree('MinLeafSize',5);
RFModel=fitensemble(FeatTrain,LabelTrain,'RUSBoost',ntrees,t,'LearnRate',0.1);
LabelsRF = predict(RFModel,FeatTest);

TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
k=length(TPInd);
Acc=sum(TPInd)/k;

ConfMat=confusionmat([Activities'; LabelTest], [Activities'; LabelsRF])-eye(6);
PredLabels=LabelsRF;

save('ConfusionMat_strokeAll.mat','ConfMat')

correctones = sum(ConfMat,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMat./correctones); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)

savefig('ConfusionMat_strokeAll')

% Healthy --> Stroke Home
FeatTest=TestFeatures(indHomeStart+1:end,2:end);
LabelTest=TestLabels(indHomeStart+1:end);

t = templateTree('MinLeafSize',5);
RFModel=fitensemble(FeatTrain,LabelTrain,'RUSBoost',ntrees,t,'LearnRate',0.1);
LabelsRF = predict(RFModel,FeatTest);

TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
k=length(TPInd);
Acc=sum(TPInd)/k;

ConfMat=confusionmat([Activities'; LabelTest], [Activities'; LabelsRF])-eye(6);
PredLabels=LabelsRF;

save('ConfusionMat_strokeHome.mat','ConfMat')

correctones = sum(ConfMat,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMat./correctones); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)

savefig('ConfusionMat_strokeHome')

%% Calculations to evaluate models
% for i=1:length(AllFeat) 
%     ConfMatAll(:,:,i)=ConfMat{i};
% end
% 
% ConfMatAll=sum(ConfMatAll,3);
% % figure;
% % bar(ActCounts);
% % set(gca,'XTickLabels',Activities)
% 
% for i=1:length(Activities)
%     precision(i)=ConfMatAll(i,i)/sum(ConfMatAll(:,i));
%     recall(i)=ConfMatAll(i,i)/sum(ConfMatAll(i,:));
%     F1(i)=2*precision(i)*recall(i)/(precision(i)+recall(i));
% end
% 
% correctones = sum(ConfMatAll,2);
% correctones = repmat(correctones,[1 6]);
% figure; imagesc(ConfMatAll./correctones); colorbar
% set(gca,'XTickLabels',Activities)
% set(gca,'YTickLabels',Activities)
% 
% 
% WAcc=k.'*Acc/sum(k);
