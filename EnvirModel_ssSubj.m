% Envir_ssBalAcc

%% Load Feature Set

load NormImp
FeatInds=find(norm_imp>.25);

%% Load Stroke Features
load('Z:\RERC- Phones\Stroke\Clips\Test_Feat.mat')
Lab2_StrokeFeatures=[];
Lab2_StrokeLabels={};

Activities={'Sitting', 'Standing', 'Walking', 'Stair'};

for indSubj=1:length(AllFeat) %[1:13 15:length(AllFeat)]
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    Lab2_StrokeFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    Lab2_StrokeLabels=[Lab2_StrokeLabels tempTestLabels];
end
Lab2_StrokeLabels=Lab2_StrokeLabels.';

ly_inds=strcmp('Lying',Lab2_StrokeLabels);
Lab2_StrokeLabels(ly_inds)={'Sitting'};

st_inds=strmatch('Stairs ',Lab2_StrokeLabels);
Lab2_StrokeLabels(st_inds)={'Stair'};

nStroke=length(AllFeat);

load('Z:\RERC- Phones\Stroke\Clips\Train_Feat.mat')
Lab1_StrokeFeatures=[];
Lab1_StrokeLabels={};

nStroke=length(AllFeat);

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    Lab1_StrokeFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    Lab1_StrokeLabels=[Lab1_StrokeLabels tempTestLabels];
end
Lab1_StrokeLabels=Lab1_StrokeLabels.';

ly_inds=strcmp('Lying',Lab1_StrokeLabels);
Lab1_StrokeLabels(ly_inds)={'Sitting'};

st_inds=strmatch('Stairs ',Lab1_StrokeLabels);
Lab1_StrokeLabels(st_inds)={'Stair'};


load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')
Home_StrokeFeatures=[];
Home_StrokeLabels={};

for indSubj=1:length(AllFeat)
    tempTestLabels=AllFeat(indSubj).ActivityLabel;
    
    ly_inds=strcmp('Lying',tempTestLabels);
    tempTestLabels(ly_inds)={'Sitting'};

    st_inds=strmatch('Stairs ',tempTestLabels);
    tempTestLabels(st_inds)={'Stair'};
    
    if ~all(cellfun(@(x) sum(strcmp(x,tempTestLabels))>59, Activities))
        continue
    end
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempTestLabels),1)*indSubj; 
    Home_StrokeFeatures(end+1:end+length(tempTestLabels),:)=[SubjectV AllFeat(indSubj).Features(:,:)];
    Home_StrokeLabels=[Home_StrokeLabels tempTestLabels];
end
Home_StrokeLabels=Home_StrokeLabels.';

ly_inds=strcmp('Lying',Home_StrokeLabels);
Home_StrokeLabels(ly_inds)={'Sitting'};

st_inds=strmatch('Stairs ',Home_StrokeLabels);
Home_StrokeLabels(st_inds)={'Stair'};

%%
nRand=1000;
nInst=500;

Acc_LL=zeros(nStroke-2,nRand);
BalAcc_LL=zeros(nStroke-2,nRand);

Acc_LH=zeros(nStroke-2,nRand);
BalAcc_LH=zeros(nStroke-2,nRand);

parfor ssSubj=nStroke-15:nStroke-5 % loop over number of test subjects to reserve
    [~, randSubjMat] = sort(rand(nStroke-3,nRand)); % nRand columns for random permutations of all subjects
    % adjust values for removed subjects
    randSubjMat=randSubjMat+1; randSubjMat(randSubjMat>13)=randSubjMat(randSubjMat>13)+1;
    randSubjMat(randSubjMat>20)=randSubjMat(randSubjMat>20)+1;
    for indRand=1:nRand
        
        % Lab 1 trained model
        indSubj=randSubjMat(end-ssSubj+1:end,indRand); % Pick last (ssSubj) to be test set

        TrainInd=all(bsxfun(@ne,Lab1_StrokeFeatures(:,1),indSubj'),2); % Training set is all subj not in indSubj
        FeatTrain=Lab1_StrokeFeatures(TrainInd,FeatInds+1);
        LabelTrain=Lab1_StrokeLabels(TrainInd);

        [~, randFeatMat] = sort(rand(length(FeatTrain),1));
        
        TestInd=any(bsxfun(@eq,Lab2_StrokeFeatures(:,1),indSubj'),2);
        FeatTest=Lab2_StrokeFeatures(TestInd,FeatInds+1);
        LabelTest=Lab2_StrokeLabels(TestInd);
        
        t = templateTree('MinLeafSize',5);
        RFModel=fitensemble(FeatTrain(randFeatMat(1:nInst),:),LabelTrain(randFeatMat(1:nInst)),'RUSBoost',ntrees,t,'LearnRate',1);
        LabelsRF = predict(RFModel,FeatTest);

        % Test on Lab2
        
        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc_LL(ssSubj,indRand)=sum(TPInd)/k;

        ConfMat_LL=confusionmat(LabelTest, LabelsRF,'Order',Activities);
        BalAcc_LL(ssSubj,indRand) = mean(diag(ConfMat_LL)./sum(ConfMat_LL,2));
        PredLabels_HH=LabelsRF;
        
        % Test on Home
        TestInd=any(bsxfun(@eq,Home_StrokeFeatures(:,1),indSubj'),2);
        FeatTest=Home_StrokeFeatures(TestInd,FeatInds+1);
        LabelTest=Home_StrokeLabels(TestInd);
        
        LabelsRF = predict(RFModel,FeatTest);

        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc_LH(ssSubj,indRand)=sum(TPInd)/k;

        ConfMat_LH=confusionmat(LabelTest, LabelsRF,'Order',Activities);
        BalAcc_LH(ssSubj,indRand) = mean(diag(ConfMat_LH)./sum(ConfMat_LH,2));
        PredLabels_LH=LabelsRF;
        
    end %indRand
    fprintf('Completed! Testing sample size %i \n',ssSubj);
end %ssSubj
