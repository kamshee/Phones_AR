%% Train classifier based on MC10 data from Phone Labels
% Run after GenerateClips.m
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

dirname='Z:\RERC- Phones\Stroke';

Test=load([dirname '\Clips\Test_Feat.mat']);
Train=load([dirname '\Clips\Train_Feat.mat']);

Test=Test.AllFeat;
Train=Train.AllFeat;

load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')

Home=AllFeat;

for i=1:length(Home)
    for j=1:length(Activities)
        counts(j)=sum(strcmp(Home(i).ActivityLabel,Activities{j}));
    end
    Subjs_w_All(i)=all([counts(1)+counts(2) counts(3) counts(4)+counts(5) counts(6)]);
end

Feat=[];
Label={};
Subjs=[];
HomeInds=[];

for i=1:length(Train)
    if ~Subjs_w_All(i)
        continue
    end
    Feat=[Feat; Train(i).Features];
    Label=[Label Train(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Train(i).ActivityLabel)])];
    HomeInds=[HomeInds zeros(1,length(Train(i).ActivityLabel))];
end

for i=1:length(Test)
    if ~Subjs_w_All(i)
        continue
    end
    Feat=[Feat; Test(i).Features];
    Label=[Label Test(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Test(i).ActivityLabel)])];
    HomeInds=[HomeInds zeros(1,length(Test(i).ActivityLabel))];
end

for i=1:length(Home)
    if ~Subjs_w_All(i)
        continue
    end
    Feat=[Feat; Home(i).Features];
    Label=[Label Home(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Home(i).ActivityLabel)])];
    HomeInds=[HomeInds ones(1,length(Home(i).ActivityLabel))];
end

nStroke=length(Home);
nHealthy=15;

%% Model
% Determine effects of sample size

nRand=1000;  % How many iterations (to pick a random set)
nInst=1200; % How man instances to randomly select for each training set

NewFeatures=Feat;
NewLabels=Label;

Acc=zeros(nHealthy-2,nRand);
BalAcc=zeros(nHealthy-2,nRand);

% Exclude subj 14 because they had no training data
% Take max subjects as 15 b/c that's how many we are going up to for Healthy group (nHealthy)
for ssSubj=1:nHealthy-2 % sample size of testing subjects; always training on at least 2
    % To make sure 14 won't be picked as training subj, pick randomly between 1-29 and add 1 to any >13
    [~, randSubjMat] = sort(rand(nStroke-1,nRand)); % nRand columns for random permutations of all subjects
    randSubjMat(randSubjMat>13)=randSubjMat(randSubjMat>13)+1;
    
    for indRand=1:nRand
        
        % Stroke to Stroke
        indSubj=randSubjMat(end-ssSubj+1:end,indRand); % Pick last (ssSubj) to be test set

        TrainInd=all(bsxfun(@ne,NewFeatures(:,1),indSubj'),2); % Training set is all subj not in indSubj
        FeatTrain=NewFeatures(TrainInd,FeatInds+1);
        LabelTrain=NewLabels(TrainInd);

        [~, randFeatMat] = sort(rand(length(FeatTrain),1));
        
        TestInd=~TrainInd;
        FeatTest=Feat(TestInd,FeatInds+1);
        LabelTest=Label(TestInd);
        
        t = templateTree('MinLeafSize',5);
        RFModel=fitensemble(FeatTrain(randFeatMat(1:nInst),:),LabelTrain(randFeatMat(1:nInst)),'RUSBoost',ntrees,t,'LearnRate',0.1);
        LabelsRF = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc(ssSubj,indRand)=sum(TPInd)/k;

        ConfMat=confusionmat(LabelTest, LabelsRF,'Order',Activities);
        BalAcc(ssSubj,indRand) = mean(diag(ConfMat)./sum(ConfMat,2));
        PredLabels=LabelsRF;
        
    end %indRand
    fprintf('Completed! Testing sample size %i \n',ssSubj);
end %ssSubj

save ssBalAcc_StrokeStroke.mat BalAcc