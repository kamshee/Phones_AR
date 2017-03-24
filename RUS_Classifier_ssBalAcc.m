%% Prep Features for Classification

clear all

ntrees=200;

rmvFeat=1;
if rmvFeat
    load NormImp
    FeatInds=find(norm_imp>.25);
%     FeatInds=find(norm_imp(1:end-8)>.25); % Run w/o barometer features
else
    FeatInds=1:270;
end

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
% Activities={'Sitting', 'Lying', 'Standing', 'Walking'};
numAct=length(Activities);

%% Load Healthy Features
load('Z:\RERC- Phones\Server Data\Clips\10s\PhoneData_Feat.mat')
nHealthy=length(AllFeat);

HealthyFeatures=[];
HealthyLabels={};

for indSubj=1:nHealthy
    tempLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of features indexes subjects
    SubjectV=ones(length(tempLabels),1)*indSubj; 
    HealthyFeatures(end+1:end+length(tempLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    HealthyLabels=[HealthyLabels tempLabels];
end
HealthyLabels=HealthyLabels.';

%% Load Stroke Features
load('Z:\RERC- Phones\Stroke\Clips\Test_Feat.mat')
StrokeFeatures=[];
StrokeLabels={};

for indSubj=1:length(AllFeat) %[1:13 15:length(AllFeat)]
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    StrokeFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    StrokeLabels=[StrokeLabels tempTestLabels];
end

nStroke=length(AllFeat);

load('Z:\RERC- Phones\Stroke\Clips\Train_Feat.mat')

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    StrokeFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    StrokeLabels=[StrokeLabels tempTestLabels];
end

load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    StrokeFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    StrokeLabels=[StrokeLabels tempTestLabels];
end
StrokeLabels=StrokeLabels.';

% Mild, Moderate, Severe stroke subjects
strokeClass={'Mild','Mod','Sev'};
strokeClass = [strokeClass; {[7 11 18 24 26 29 30],...  % Took out 14 (mild)
    [1 8 10 12 13 15 16 19 20 21 22 25 28],...
    [2 3 4 5 6 9 17 23 27]}];

%% Model
% Determine effects of sample size

nRand=1000;  % How many iterations (to pick a random set)
nInst=1200; % How many instances to randomly select for each training set

NewHealthyFeatures=HealthyFeatures;
NewHealthyLabels=HealthyLabels;

Acc_HH=zeros(nHealthy-2,nRand);
BalAcc_HH=zeros(nHealthy-2,nRand);

Acc_HS=zeros(nHealthy-2,nRand);
BalAcc_HS=zeros(nHealthy-2,nRand);

parfor ssSubj=1:7%nHealthy-2 % sample size of testing subjects; always training on at least 2
    [~, randSubjMat] = sort(rand(nHealthy,nRand)); % nRand columns for random permutations of all subjects
    for indRand=1:nRand
        
        % Healthy to Healthy
        indSubj=randSubjMat(end-ssSubj+1:end,indRand); % Pick last (ssSubj) to be test set

        TrainInd=all(bsxfun(@ne,NewHealthyFeatures(:,1),indSubj'),2); % Training set is all subj not in indSubj
        FeatTrain=NewHealthyFeatures(TrainInd,FeatInds+1);
        LabelTrain=NewHealthyLabels(TrainInd);

        [~, randFeatMat] = sort(rand(length(FeatTrain),1));
        
        TestInd=~TrainInd;
        FeatTest=HealthyFeatures(TestInd,FeatInds+1);
        LabelTest=HealthyLabels(TestInd);
        
        t = templateTree('MinLeafSize',5);
        RFModel=fitensemble(FeatTrain(randFeatMat(1:nInst),:),LabelTrain(randFeatMat(1:nInst)),'RUSBoost',ntrees,t,'LearnRate',0.1);
        LabelsRF = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc_HH(ssSubj,indRand)=sum(TPInd)/k;

        ConfMat_HH=confusionmat(LabelTest, LabelsRF,'Order',Activities);
        BalAcc_HH(ssSubj,indRand) = mean(diag(ConfMat_HH)./sum(ConfMat_HH,2));
        PredLabels_HH=LabelsRF;
        
        
        % Healthy to Stroke All
        SubjectID=StrokeFeatures(:,1);
        FeatTest=StrokeFeatures(:,FeatInds+1);
        LabelTest=StrokeLabels;
        
        LabelsRF = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc_HS(ssSubj,indRand)=sum(TPInd)/k;

        ConfMat_HS=confusionmat(LabelTest, LabelsRF,'Order',Activities);
        BalAcc_HS(ssSubj,indRand) = mean(diag(ConfMat_HS)./sum(ConfMat_HS,2));
        PredLabels_HS=LabelsRF;
        
        
        % Healthy to Stroke by Severity
        for indStroke=1:length(strokeClass)
            indFeat=sum(bsxfun(@eq, SubjectID, strokeClass{2,indStroke}),2);
            indFeat=logical(indFeat);
            LabelsRF = predict(RFModel,FeatTest(indFeat,:));

            TPInd=cellfun(@strcmp, LabelsRF, LabelTest(indFeat));
            k=length(TPInd);
            Acc=sum(TPInd)/k;

            ConfMat={};
            ConfMatAll=zeros(length(Activities),length(Activities),nStroke);
            for indSubSev=1:nStroke
                if any(indSubSev==strokeClass{2,indStroke})
                    ConfMat{indSubSev}=confusionmat([Activities'; LabelTest(SubjectID==indSubSev)], [Activities'; LabelsRF(SubjectID(indFeat)==indSubSev)])-eye(6);
                    ConfMatAll(:,:,indSubSev)=ConfMat{indSubSev};
                end
            end
            ConfMatAll=sum(ConfMatAll,3);
            PredLabels=LabelsRF;

            switch indStroke
                case 1
                    BalAcc_Mild(ssSubj,indRand) = mean(diag(ConfMatAll)./sum(ConfMatAll,2));
                case 2
                    BalAcc_Mod(ssSubj,indRand) = mean(diag(ConfMatAll)./sum(ConfMatAll,2));
                case 3
                    BalAcc_Sev(ssSubj,indRand) = mean(diag(ConfMatAll)./sum(ConfMatAll,2));
                otherwise
                    fprintf('Not a valid stroke severity');
            end
            

        end
    end %indRand
    fprintf('Completed! Testing sample size %i \n',ssSubj);
end %ssSubj

save ssBalAcc_HealthyHealthy.mat BalAcc_HH
save ssBalAcc_HealthyStroke_All.mat BalAcc_HS
save ssBalAcc_HealthyStroke_bySev.mat BalAcc_Mild BalAcc_Mod BalAcc_Sev

