%% Train classifier based on MC10 data from Phone Labels
% Run after GenerateClips.m
clear all

Subj_CrossVal=1;

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

Feat=[];
Label={};
Subjs=[];
HomeInds=[];

for i=1:length(Train)
    if i==indFold; continue; end;
    Feat=[Feat; Train(i).Features];
    Label=[Label Train(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Train(i).ActivitiyLabel)])];
    HomeInds=[HomeInds zeros(1,length(Train(i).ActivityLabel))];
end

for i=1:length(Test)
    if i==indFold; continue; end;
    Feat=[Feat; Test(i).Features];
    Label=[Label Test(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Train(i).ActivitiyLabel)])];
    HomeInds=[HomeInds zeros(1,length(Train(i).ActivityLabel))];
end

for i=1:length(Home)
    Feat=[Feat; Home(i).Features];
    Label=[Label Home(i).ActivityLabel];
    Subjs=[Subjs repmat(i,[1 length(Train(i).ActivitiyLabel)])];
    HomeInds=[HomeInds zeros(1,length(Train(i).ActivityLabel))];
end

for indFold=1:length(Home)
    
    TrainFeat=Feat(~HomeInds & ~Subjs==indFold,:);
    TrainLabel=Label(~HomeInds & ~Subjs==indFold,:).';

    TestFeat=Feat(Subjs==indFold,:);
    TestLabel=Label(Subjs==indFold,:);     
    TestLabel=TestLabel.';

    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,TestFeat);
    PopConfMat{indFold}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF])-eye(6);
    
    if isempty(Home(indFold).Features)
        continue
    end
    
    %% Lab->Home (15 Subj only)
    
    Subjs_w_Home=cellfun(@(x) ~isempty(x),{Home.Features});
    
    TrainFeat=Feat(~HomeInds & ~Subjs==indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2),:);
    TrainLabel=Label(~HomeInds & ~Subjs==indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2),:).';

    TestFeat=Feat(HomeInds & Subjs==indFold,:);
    TestLabel=Label(HomeInds & Subjs==indFold,:);     
    TestLabel=TestLabel.';

    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,TestFeat);
    LabConfMatHome{indFold}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF])-eye(6);
    
    TestFeatLab=Feat(~HomeInds & Subjs==indFold,:);
    TestLabelLab=Label(~HomeInds & Subjs==indFold,:);     
    TestLabelLab=TestLabelLab.';
    
    LabelsRF = predict(RFModel,TestFeat);
    LabConfMatLab{indFold}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF])-eye(6);
    
    %% Resample and test Lab+Home->Home
    
    trainsize=size(TrainFeat,1);
    
    for indResample=1:10
    
        TrainFeat=Feat(~Subjs==indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2),:);
        TrainLabel=Label(~Subjs==indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2),:).';
        
        resampinds=randperm(size(TrainFeat,1),trainsize);
        TrainFeat=TrainFeat(resampinds,:);
        TrainLabel=TrainLabel(resampinds);

        t = templateTree('MinLeafSize',5);
        RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
        LabelsRF = predict(RFModel,TestFeat);
        LabHomeConfMat{indFold,indResample}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF])-eye(6);
        
        LabelsRF = predict(RFModel,TestFeat);
        LabHomeConfMatLab{indFold,indResample}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF])-eye(6);
        
    end
end

save('ConfusionMat_strokestrokeHome.mat','LabConfMat', 'LabHomeConfMat')
save('ConfusionMat_strokestrokeHome.mat','LabConfMat', 'LabHomeConfMat')

ConfMatAll=zeros(length(Activities),length(Activities),length(LabConfMat));

for i=length(LabConfMat):-1:1
    ConfMatAll(:,:,i)=LabConfMat{i};
end
ConfMatAll=sum(ConfMatAll,3);

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])

savefig('ConfusionMat_strokestrokeLab')

ConfMatAll=zeros(length(Activities),length(Activities),length(LabHomeConfMat));

for i=length(LabHomeConfMat):-1:1
    ConfMatAll(:,:,i)=LabHomeConfMat{i};
end
ConfMatAll=sum(ConfMatAll,3);

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])

savefig('ConfusionMat_strokestrokeHome')