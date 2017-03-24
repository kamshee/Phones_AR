%% Load Feature Set

load NormImp
FeatInds=find(norm_imp>.25);

ntrees=200;

%% Load Home Data

Activities={'Sitting', 'Standing', 'Walking', 'Stair'};
Subjs=[11 17:19 24 27];

load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')
Home_StrokeFeatures=[];
Home_StrokeLabels={};

for indSubj=1:length(Subjs)
    tempLabels=AllFeat(Subjs(indSubj)).ActivityLabel;
    
    % Vector in first column of TestFeatures indexes subjects
    SubjectV=ones(length(tempLabels),1)*indSubj; 
    Home_StrokeFeatures(end+1:end+length(tempLabels),:)=[SubjectV AllFeat(Subjs(indSubj)).Features(:,:)];
    Home_StrokeLabels=[Home_StrokeLabels tempLabels];
end

ly_inds=strcmp('Lying',Home_StrokeLabels);
Home_StrokeLabels(ly_inds)={'Sitting'};

st_inds=strmatch('Stairs ',Home_StrokeLabels);
Home_StrokeLabels(st_inds)={'Stair'};

Home_StrokeLabels=Home_StrokeLabels.';

nHome=length(Subjs);

%%
nRand=1000;
nInst=500;

Acc_HH=zeros(nHome-1,nRand);
BalAcc_HH=zeros(nHome-1,nRand);

for ssSubj=1:nHome-1 % loop over number of test subjects to reserve
    [~, randSubjMat] = sort(rand(nHome,nRand)); % nRand columns for random permutations of all subjects
    for indRand=1:nRand
        
        % Home model testing
        indSubj=randSubjMat(end-ssSubj+1:end,indRand); % Pick last (ssSubj) to be test set

        TrainInd=all(bsxfun(@ne,Home_StrokeFeatures(:,1),indSubj'),2); % Training set is all subj not in indSubj
        FeatTrain=Home_StrokeFeatures(TrainInd,FeatInds+1);
        LabelTrain=Home_StrokeLabels(TrainInd);

        [~, randFeatMat] = sort(rand(length(FeatTrain),1));
        
        TestInd=any(bsxfun(@eq,Home_StrokeFeatures(:,1),indSubj'),2);
        FeatTest=Home_StrokeFeatures(TestInd,FeatInds+1);
        LabelTest=Home_StrokeLabels(TestInd);
        
        t = templateTree('MinLeafSize',5);
        RFModel=fitensemble(FeatTrain(randFeatMat(1:nInst),:),LabelTrain(randFeatMat(1:nInst)),'RUSBoost',ntrees,t,'LearnRate',1);
        LabelsRF = predict(RFModel,FeatTest);
        
        TPInd=cellfun(@strcmp, LabelsRF, LabelTest);
        k=length(TPInd);
        Acc_HH(ssSubj,indRand)=sum(TPInd)/k;

        ConfMat_HH=confusionmat(LabelTest, LabelsRF,'Order',Activities);
        BalAcc_HH(ssSubj,indRand) = mean(diag(ConfMat_HH)./sum(ConfMat_HH,2));
        PredLabels_HH=LabelsRF;
        
    end %indRand
    fprintf('Completed! Testing sample size %i \n',ssSubj);
end %ssSubj

save('ssBalAcc_Stroke_HometoHome.mat','Acc_HH','BalAcc_HH');
