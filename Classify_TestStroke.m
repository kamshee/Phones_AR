%% Train on Healthy, Test on Stroke

clear all

nTrees=50;
nResample=5; % Set to more than 1 to balance classes for training and specify number of resamplings
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

% load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')
% 
% for indSubj=1:length(AllFeat)
%     tempTestLabels=AllFeat(indSubj).ActivityLabel;
%     
%     % Vector in first column of TestFeatures indexes subjects
%     SubjectV=ones(length(tempTestLabels),1)*indSubj; 
%     TestFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).TestFeatures(:,:)];
%     TestLabels=[TestLabels tempTestLabels];
% end

TestLabels=TestLabels.';

if ~TestBalance 
        FeatTrain=NewFeatures(:,2:end);
        LabelTrain=NewLabels;

        FeatTest=TestFeatures(:,2:end);
        LabelTest=TestLabels;

        RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc=sum(TPInd)/k;

        ConfMat=confusionmat(LabelTest, LabelsRF);
        PredLabels=LabelsRF;
else

        FeatTrain=NewFeatures(:,2:end);
        LabelTrain=NewLabels;

        FeatTest=TestFeatures(:,2:end);
        LabelTest=TestLabels;

        RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc=sum(TPInd)/k;

        ConfMat=confusionmat(LabelTest, LabelsRF);

end
    correctones = sum(ConfMat,2);
    correctones = repmat(correctones,[1 6]);
    figure; imagesc(ConfMat./correctones); colorbar
    set(gca,'XTickLabels',Activities)
    set(gca,'YTickLabels',Activities)
end
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
