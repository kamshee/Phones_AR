%% Train on Mild/Severe, Test on Severe

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

Features=[];
Labels={};

% Mild, Moderate, Severe stroke subjects
strokeClass={'Mild','Mod','Sev'};
strokeClass = [strokeClass; {[7 11 14 18 24 26 29 30],...
    [1 8 10 12 13 15 16 19 20 21 22 25 28],...
    [2 3 4 5 6 9 17 23 27]}];

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
    TestFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    TestLabels=[TestLabels tempTestLabels];
end

TestLabels=TestLabels.';

SubjectID=TestFeatures(:,1);
FeatTest=TestFeatures(:,FeatInds+1);
LabelTest=TestLabels;

%% Mild/Mod --> Severe
for indStroke=1:length(strokeClass)-1
    
    indFeat=sum(bsxfun(@eq, SubjectID, strokeClass{2,indStroke}),2);
    indFeat=logical(indFeat);
    
    FeatTrain=FeatTest(indFeat,:);
    LabelTrain=LabelTest(indFeat,:);
    
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(FeatTrain,LabelTrain,'RUSBoost',ntrees,t,'LearnRate',0.1);
    
    indFeat=sum(bsxfun(@eq, SubjectID, strokeClass{2,3}),2); % Severe Only
    indFeat=logical(indFeat);
    LabelsRF = predict(RFModel,FeatTest(indFeat,:));

    TPInd=cellfun(@strcmp, LabelsRF, LabelTest(indFeat));
    k=length(TPInd);
    Acc=sum(TPInd)/k;

    clear ConfMat
    ConfMatAll=zeros(length(Activities),length(Activities),length(AllFeat));
    for indSub=1:length(AllFeat)
        if any(indSub==strokeClass{2,3})
            ConfMat{indSub}=confusionmat([Activities'; LabelTest(SubjectID==indSub)], [Activities'; LabelsRF(SubjectID(indFeat)==indSub)])-eye(6);
            ConfMatAll(:,:,indSub)=ConfMat{indSub};
        end
    end
    ConfMatAll=sum(ConfMatAll,3);
    PredLabels=LabelsRF;

    save(['ConfusionMat_Sev_' strokeClass{1,indStroke} '.mat'],'ConfMat','ConfMatAll')

    correctones = sum(ConfMatAll,2);
    correctones = repmat(correctones,[1 6]);
    figure; imagesc(ConfMatAll./correctones); colorbar
    set(gca,'XTickLabels',Activities)
    set(gca,'YTickLabels',Activities)

    savefig(['ConfusionMat_Sev_' strokeClass{1,indStroke}])
end

% Severe --> Severe

clear ConfMat
ConfMatAll=zeros(length(Activities),length(Activities),length(AllFeat));

for i=1:length(strokeClass{2,3})
    indSub=strokeClass{2,3}(i);
    
    indFeat=sum(bsxfun(@eq, SubjectID, strokeClass{2,indStroke}(1:length(strokeClass{2,3})~=indSub)),2);
    indFeat=logical(indFeat);
    
    FeatTrain=FeatTest(indFeat,:);
    LabelTrain=LabelTest(indFeat,:);
    
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(FeatTrain,LabelTrain,'RUSBoost',ntrees,t,'LearnRate',0.1);
    
    indFeat=SubjectID==indSub; % One subject only
    indFeat=logical(indFeat);
    LabelsRF = predict(RFModel,FeatTest(indFeat,:));

    TPInd=cellfun(@strcmp, LabelsRF, LabelTest(indFeat));
    k=length(TPInd);
    Acc=sum(TPInd)/k;

    ConfMat{indSub}=confusionmat([Activities'; LabelTest(SubjectID==indSub)], [Activities'; LabelsRF])-eye(6);
    ConfMatAll(:,:,indSub)=ConfMat{indSub};
    ConfMatAll=sum(ConfMatAll,3);
end

save('ConfusionMat_Sev_Sev.mat','ConfMat','ConfMatAll')

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)

savefig('ConfusionMat_Sev_Sev')