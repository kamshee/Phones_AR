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
        countsHome(j)=sum(strcmp(Home(i).ActivityLabel,Activities{j}));
        countsLab2(j)=sum(strcmp(Test(i).ActivityLabel,Activities{j}));
        countsLab1(j)=sum(strcmp(Train(i).ActivityLabel,Activities{j}));
    end
    Subjs_w_All(i)=all([countsHome(1)+countsHome(2) countsHome(3) countsHome(4)+countsHome(5) countsHome(6)])...
        & all([countsLab2(1)+countsLab2(2) countsLab2(3) countsLab2(4)+countsLab2(5) countsLab2(6)])...
        & all([countsLab1(1)+countsLab1(2) countsLab1(3) countsLab1(4)+countsLab1(5) countsLab1(6)]);
end

Feat=[];
Label={};
Subjs=[];
HomeInds=[];
Lab2Inds=[];
Lab1Inds=[];

for i=1:length(Train)
    if ~Subjs_w_All(i)
        continue
    end
    Feat=[Feat; Train(i).Features];
    Label=[Label Train(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Train(i).ActivityLabel)])];
    HomeInds=[HomeInds zeros(1,length(Train(i).ActivityLabel))];
    Lab2Inds=[Lab2Inds zeros(1,length(Train(i).ActivityLabel))];
    Lab1Inds=[Lab1Inds ones(1,length(Train(i).ActivityLabel))];
end

for i=1:length(Test)
    if ~Subjs_w_All(i)
        continue
    end
    Feat=[Feat; Test(i).Features];
    Label=[Label Test(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Test(i).ActivityLabel)])];
    HomeInds=[HomeInds zeros(1,length(Test(i).ActivityLabel))];
    Lab2Inds=[Lab2Inds ones(1,length(Test(i).ActivityLabel))];
    Lab1Inds=[Lab1Inds zeros(1,length(Test(i).ActivityLabel))];
end

for i=1:length(Home)
    if ~Subjs_w_All(i)
        continue
    end
    Feat=[Feat; Home(i).Features];
    Label=[Label Home(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Home(i).ActivityLabel)])];
    HomeInds=[HomeInds ones(1,length(Home(i).ActivityLabel))];
    Lab2Inds=[Lab2Inds zeros(1,length(Home(i).ActivityLabel))];
    Lab1Inds=[Lab1Inds zeros(1,length(Home(i).ActivityLabel))];
end

for indFold=1:length(Home)
    disp(indFold)

    if size(Home(indFold).Features,1)<60 || ~Subjs_w_All(indFold)
        continue
    end
    
    %% Combine Sitting/Lying and Stairs Up/Down for environmental models
    
    ly_inds=strcmp('Lying',Label);
    Label(ly_inds)={'Sitting'};
    
    st_inds=strmatch('Stairs ',Label);
    Label(st_inds)={'Stairs'};
    
    Envir_Activities={'Sitting', 'Standing', 'Walking' 'Stairs'};
    
    % Lab1 to Lab2 and Lab1 to Home
    TrainFeat=Feat(Lab1Inds & Subjs~=indFold,:);
    TrainLabel=Label(Lab1Inds & Subjs~=indFold).';
    TempSubjs=Subjs(Lab1Inds & Subjs~=indFold);
    
    trainsizes=sum(bsxfun(@eq,find(Subjs_w_All),TempSubjs'),1);

    TestFeat=Feat(Lab2Inds & Subjs==indFold,:);
    TestLabel=Label(Lab2Inds & Subjs==indFold);     
    TestLabel=TestLabel.';
    
    HomeFeat=Feat(HomeInds & Subjs==indFold,:);
    HomeLabel=Label(HomeInds & Subjs==indFold);     
    HomeLabel=HomeLabel.';

    % Don't test on activities that have less than 60 instances for this subject
    % Not necessary for the 6 subj here
    for i=1:length(Activities)
        act_counts=sum(strcmp(Activities(i),TestLabel));
        if act_counts<60
            act_inds=strcmp(Activities(i),TestLabel);
            TestFeat(act_inds,:)=[];
            TestLabel(act_inds)=[];
        end
    end
    
    for i=1:length(Activities)
        act_counts=sum(strcmp(Activities(i),HomeLabel));
        if act_counts<60
            act_inds=strcmp(Activities(i),HomeLabel);
            HomeFeat(act_inds,:)=[];
            HomeLabel(act_inds)=[];
        end
    end
    
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',1);
    LabelsRF = predict(RFModel,TestFeat);
    Lab1ConfMatLab2{indFold}=confusionmat(TestLabel, LabelsRF,'order',Envir_Activities);
    
    LabelsRF = predict(RFModel,HomeFeat);
    Lab1ConfMatHome{indFold}=confusionmat(HomeLabel,LabelsRF,'order',Envir_Activities);
    
    % Home to Home
    TrainFeat=Feat(HomeInds & Subjs~=indFold,:);
    TrainLabel=Label(HomeInds & Subjs~=indFold);     
    TrainLabel=TrainLabel.';
    
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',1);
    LabelsRF = predict(RFModel,HomeFeat);
    HomeConfMatHome{indFold}=confusionmat(HomeLabel, LabelsRF,'order',Envir_Activities);
    
end

save('ConfusionMat_env_JMIR_rev1.mat','Lab1ConfMatLab2', 'Lab1ConfMatHome', 'HomeConfMatHome')