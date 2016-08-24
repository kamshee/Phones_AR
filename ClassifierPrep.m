%% Prep Features for Classification

clear all

nTrees=150;
nResample=1; % Set to more than 1 to balance classes for training and specify number of resamplings
TestBalance=0; % Test on imbalanced or balanced classes when resampling test set
SemiBal=3; % Desired ratio of smallest class to largest
Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
% Activities={'Sitting', 'Lying', 'Standing', 'Walking'};
numAct=length(Activities);

load('Z:\RERC- Phones\Server Data\Clips\PhoneData_Feat.mat')

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

%% Balance Classes
for xInd=1:nResample
% Count each class
if nResample==1
    NewFeatures=Features;
    NewLabels=Labels;
    clear ('Features', 'Labels');
else
    for i=1:length(Activities)

        ActCounts(i)=sum(cellfun(@(x) strcmp(x,Activities{i}), Labels));

    end

    BalCount=min(ActCounts);
    X=rand(length(Features),1);

    KeepInd=zeros(size(Features,1),1);

    parfor i=1:size(Features,1)
        % Find index of activity
        indAct=find(cellfun(@(x) strcmp(x,Labels{i}),Activities));
        KeepInd(i)=X(i)<BalCount*SemiBal/ActCounts(indAct);
    end

    NewFeatures=Features(find(KeepInd==1),:);
    NewLabels=Labels(find(KeepInd==1));
end


%% Leave one subject out cross validation

k=zeros(length(AllFeat),1);
Acc=zeros(length(AllFeat),1);
% ConfMat=zeros(numAct,numAct,length(AllFeat));
ConfMat=cell(1,length(AllFeat));
PredLabels=cell(1,length(AllFeat));
if ~TestBalance
    parfor indSubj=1:length(AllFeat)
    % for indSubj=1:1

        TrainInd=find(NewFeatures(:,1)~=indSubj);
        FeatTrain=NewFeatures(TrainInd,2:end);
        LabelTrain=NewLabels(TrainInd);

        TestInd=find(NewFeatures(:,1)==indSubj);
        FeatTest=NewFeatures(TestInd,2:end);
        LabelTest=NewLabels(TestInd);

        RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k(indSubj)=length(TPInd);
        Acc(indSubj)=sum(TPInd)/k(indSubj);

        ConfMat{indSubj}=confusionmat(LabelTest, LabelsRF);
        PredLabels{indSubj}=LabelsRF;
    end
else
    parfor indSubj=1:length(AllFeat)
    % for indSubj=1:1

        TrainInd=find(NewFeatures(:,1)~=indSubj);
        FeatTrain=NewFeatures(TrainInd,2:end);
        LabelTrain=NewLabels(TrainInd);

        TestInd=find(NewFeatures(:,1)==indSubj);
        FeatTest=NewFeatures(TestInd,2:end);
        LabelTest=NewLabels(TestInd);

        RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k(indSubj)=length(TPInd);
        Acc(indSubj)=sum(TPInd)/k(indSubj);

        ConfMat{indSubj}=confusionmat(LabelTest, LabelsRF);

    end
end
if nResample~=1
    save(['ConfusionMat_' num2str(xInd) '.mat'], 'ConfMat');
end

end
%% Calculations to evaluate models
for i=1:length(AllFeat) 
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
figure; imagesc(ConfMatAll./correctones); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)


WAcc=k.'*Acc/sum(k);
