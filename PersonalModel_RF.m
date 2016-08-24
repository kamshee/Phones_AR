%% Prep Features for Classification (Amputee Data)

clear all

nTrees=150;
nFolds=1;
FoldOffset=10;

TrainingSizes=[90, 80, 75, 50, 25];

Shuffled=0;

SemiBal=3; % Desired ratio of smallest class to largest
Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
numAct=length(Activities);

load('Z:\RERC- Phones\Server Data\Clips\PhoneData_Feat.mat')

Features=[];
Labels={};

%% Leave one subject out cross validation

k=zeros(length(AllFeat),1);
Acc=zeros(length(AllFeat),1);
ConfMat=cell(1,length(AllFeat));
PredLabels=cell(1,length(AllFeat));

for indSubj=2:length(AllFeat)

    % Vector in first column of features indexes subjects
    Features=AllFeat(indSubj).Features(:,:);
    Labels=AllFeat(indSubj).ActivityLabel;
    Labels=Labels.';
    ActCounts=zeros(length(Activities),1);
    Fold=zeros(length(Features),1);
    
    if Shuffled
        count=size(Features,1);

        X=rand(count,1);

        Features=[X Features];
        [Features,I]=sortrows(Features);
        Features=Features(:,2:end);
        Labels=Labels(I);    

        TrainSize=floor(.8*count);
        TestSize=count-TrainSize;

        FeatTrain=Features(1:TrainSize,2:end);
        LabelTrain=Labels(1:TrainSize);

        FeatTest=Features(TrainSize+1:end,2:end);
        LabelTest=Labels(TrainSize+1:end);
        
        RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        Acc(indSubj)=sum(TPInd)/k(indSubj);
        
        ConfMat{indSubj}=confusionmat(LabelTest, LabelsRF);
    else
        for i=1:length(Activities)
            ActCounts(i)=sum(cellfun(@(x) strcmp(x,Activities{i}), Labels));
        end
        
        for i=1:length(Activities)
            for j=1:ActCounts(i)
                Fold(sum(ActCounts(1:i-1))+j,1)=ceil(j/ActCounts(i)*20);
            end
        end 
    
        ConfMatTemp=cell(1,length(TrainingSizes));

        parfor indFold=1:length(TrainingSizes)
            FeatTrain=Features(Fold<=TrainingSizes(indFold)/5,:);
            LabelTrain=Labels(Fold<=TrainingSizes(indFold)/5);

            % Use Last 10 percent as test data
            FeatTest=Features(Fold>18,:);
            LabelTest=Labels(Fold>18);

            RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
            [LabelsRF,P_RF] = predict(RFModel,FeatTest);

            TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
            ConfMatTemp{indFold}=confusionmat(LabelTest, LabelsRF);
        end
        ConfMat{indSubj}=ConfMatTemp;
    end
    
end
    
save('ConfusionMat_Personal_RF_TrainSizes.mat', 'ConfMat');

%% Calculations to evaluate models
ConfMatAll=zeros(6,6,15);

for i=1:length(ConfMat) 
    ConfMatAll(:,:,i)=ConfMat{i};
end

ConfMatAll=sum(ConfMatAll,3);

for i=1:length(Activities)
    precision(i)=ConfMatAll(i,i)/sum(ConfMatAll(:,i));
    recall(i)=ConfMatAll(i,i)/sum(ConfMatAll(i,:));
    F1(i)=2*precision(i)*recall(i)/(precision(i)+recall(i));
end

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])


WAcc=sum(diag(ConfMatAll))/sum(sum(ConfMatAll));
