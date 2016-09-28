%% Prep Features for Classification

clear all

nTrees=200;
nResample=2; % Set to more than 1 to balance classes for training and specify number of resamplings
TestBalance=0; % Test on imbalanced or balanced classes when resampling test set
SemiBal=3; % Desired ratio of smallest class to largest
rmvFeat=0;
VarImp=1;
if VarImp
    OOB='on';
else
    OOB='off';
end
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
for xInd=1:nResample
% Count each class
if nResample==1
    NewFeatures=Features;
    NewLabels=Labels;
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

        TestInd=find(Features(:,1)==indSubj);
        FeatTest=Features(TestInd,2:end);
        LabelTest=Labels(TestInd);

        RFModel=TreeBagger(nTrees, FeatTrain(:, FeatInds), LabelTrain,'OOBVarImp',OOB);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest(:, FeatInds));

        if VarImp
            if isempty(err{indSubj})
                err{indSubj}=zeros(size(RFModel.OOBPermutedVarDeltaError));
            end
            err{indSubj} = err{indSubj}+RFModel.OOBPermutedVarDeltaError;
        end
        
        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k(indSubj)=length(TPInd);
        Acc(indSubj)=sum(TPInd)/k(indSubj);

        ConfMat{indSubj}=confusionmat(LabelTest, LabelsRF);
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
else
    parfor indSubj=1:length(AllFeat)
    % for indSubj=1:1

        TrainInd=find(NewFeatures(:,1)~=indSubj);
        FeatTrain=NewFeatures(TrainInd,2:end);
        LabelTrain=NewLabels(TrainInd);

        TestInd=find(NewFeatures(:,1)==indSubj);
        FeatTest=NewFeatures(TestInd,2:end);
        LabelTest=NewLabels(TestInd);

        RFModel=TreeBagger(nTrees, FeatTrain(:,FeatInds), LabelTrain,'OOBVarImp',OOB);
        [LabelsRF,P_RF] = predict(RFModel,FeatTest(:,FeatInds));

        if VarImp
            if isempty(err{indSubj})
                err{indSubj}=zeros(size(RFModel.OOBPermutedVarDeltaError));
            end
            err{indSubj} = err{indSubj}+RFModel.OOBPermutedVarDeltaError;
        end
            
        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k(indSubj)=length(TPInd);
        Acc(indSubj)=sum(TPInd)/k(indSubj);

        ConfMat{indSubj}=confusionmat(LabelTest, LabelsRF);

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
end
if nResample~=1
    save(['ConfusionMat_' num2str(xInd) '.mat'], 'ConfMat','err');
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
figure; imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)


WAcc=sum(diag(ConfMatAll))/sum(sum(ConfMatAll));
