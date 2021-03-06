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

for indFold=1:length(Home)
    disp(indFold)

    PopConfMat{indFold}=[];
    
    if size(Home(indFold).Features,1)<60 || ~Subjs_w_All(indFold)
        continue
    end
    
    %% Lab->Home (15 Subj only)
    
    Subjs_w_Home=cellfun(@(x) ~size(Home(indFold).Features,1)<60,{Home.Features});
    
    %% Combine Sitting/Lying and Stairs Up/Down for environmental models
    
    ly_inds=strcmp('Lying',Label);
    Label(ly_inds)={'Sitting'};
    
    st_inds=strmatch('Stairs ',Label);
    Label(st_inds)={'Stair'};
    
    Envir_Activities={'Sitting', 'Standing', 'Stair', 'Walking'};
    
    TrainFeat=Feat(~HomeInds & Subjs~=indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2)',:);
    TrainLabel=Label(~HomeInds & Subjs~=indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2)').';
    TempSubjs=Subjs(~HomeInds & Subjs~=indFold & sum(bsxfun(@eq,find(Subjs_w_Home),Subjs'),2)');
    
    trainsizes=sum(bsxfun(@eq,find(Subjs_w_All),TempSubjs'),1);

    TestFeat=Feat(HomeInds & Subjs==indFold,:);
    TestLabel=Label(HomeInds & Subjs==indFold);     
    TestLabel=TestLabel.';

    % Don't test on activities that have less than 60 instances for this subject
    
    for i=1:length(Activities)
        act_counts=sum(strcmp(Activities(i),TestLabel));
        if act_counts<60
            act_inds=strcmp(Activities(i),TestLabel);
            TestFeat(act_inds,:)=[];
            TestLabel(act_inds)=[];
        end
    end
    
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,TestFeat);
    LabConfMatHome{indFold}=confusionmat([Envir_Activities'; TestLabel], [Envir_Activities'; LabelsRF])-eye(length(Envir_Activities));
    
%     TestFeatLab=Feat(~HomeInds & Subjs==indFold,:);
%     TestLabelLab=Label(~HomeInds & Subjs==indFold);     
%     TestLabelLab=TestLabelLab.';
%     
%     LabelsRF = predict(RFModel,TestFeatLab);
%     LabConfMatLab{indFold}=confusionmat([Activities'; TestLabelLab], [Activities'; LabelsRF])-eye(6);
    
    %% Resample and test Lab+Home->Home
    Subjs_w_Home=find(Subjs_w_Home & Subjs_w_All);
    for indResample=1:3
    
        TrainFeat=[];
        TrainLabel={};
        LabFeat=[];
        LabLabel={};
        HomeFeat=[];
        HomeLabel={};
        
        for i=1:length(trainsizes)
            if Subjs_w_Home(i)==indFold
                continue
            end
            TempFeat=Feat(~HomeInds & Subjs==Subjs_w_Home(i),:);
            TempLabel=Label(~HomeInds & Subjs==Subjs_w_Home(i));
            
            TempHomeFeat=Feat(HomeInds & Subjs==Subjs_w_Home(i),:);
            TempHomeLabel=Label(HomeInds & Subjs==Subjs_w_Home(i));
            
            if size(TempFeat,1)>size(TempHomeFeat,1)
                Lab_resampinds=randperm(size(TempFeat,1),size(TempHomeFeat,1));
                LabFeat=[LabFeat; TempFeat(Lab_resampinds,:)];
                LabLabel=[LabLabel; TempLabel(Lab_resampinds)'];
                HomeFeat=[HomeFeat; TempHomeFeat];
                HomeLabel=[HomeLabel; TempHomeLabel'];
                
                resampinds=randperm(size(TempFeat,1),max([trainsizes(i)-size(TempHomeFeat,1) 0]));
                TempFeat=[TempFeat(resampinds,:); TempHomeFeat];
                TempLabel=[TempLabel(resampinds) TempHomeLabel];
                TrainFeat=[TrainFeat; TempFeat];
                TrainLabel=[TrainLabel; TempLabel'];
            else
                Lab_resampinds=randperm(size(TempHomeFeat,1),size(TempFeat,1));
                LabFeat=[LabFeat; TempFeat];
                LabLabel=[LabLabel; TempLabel'];
                HomeFeat=[HomeFeat; TempHomeFeat(Lab_resampinds,:)];
                HomeLabel=[HomeLabel; TempHomeLabel(Lab_resampinds)'];
                
                resampinds=randperm(size(TempFeat,1),max([trainsizes(i)-size(TempHomeFeat(Lab_resampinds,:),1) 0]));
                TempFeat=[TempFeat(resampinds,:); TempHomeFeat(Lab_resampinds,:)];
                TempLabel=[TempLabel(resampinds) TempHomeLabel(Lab_resampinds)];
                TrainFeat=[TrainFeat; TempFeat];
                TrainLabel=[TrainLabel; TempLabel'];
            end

            
        end

        t = templateTree('MinLeafSize',5);
        RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
        LabelsRF = predict(RFModel,TestFeat);
        LabHomeConfMatHome{indFold,indResample}=confusionmat([Envir_Activities'; TestLabel], [Envir_Activities'; LabelsRF])-eye(length(Envir_Activities));
        
%         LabelsRF = predict(RFModel,TestFeatLab);
%         LabHomeConfMatLab{indFold,indResample}=confusionmat([Activities'; TestLabelLab], [Activities'; LabelsRF])-eye(6);
        
        RFModel=fitensemble(HomeFeat,HomeLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
        LabelsRF = predict(RFModel,TestFeat);
        HometoHome{indFold,indResample}=confusionmat([Envir_Activities'; TestLabel], [Envir_Activities'; LabelsRF])-eye(length(Envir_Activities));
        
        RFModel=fitensemble(LabFeat,LabLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
        LabelsRF = predict(RFModel,TestFeat);
        Lab_HometoHome{indFold,indResample}=confusionmat([Envir_Activities'; TestLabel], [Envir_Activities'; LabelsRF])-eye(length(Envir_Activities));
        
    end
end

PopConfMat=load('ConfusionMat_strokestrokeHome.mat','PopConfMat');
PopConfMat=PopConfMat.PopConfMat;
save('ConfusionMat_strokestrokeHome.mat','LabConfMatHome', 'LabHomeConfMatHome', 'PopConfMat')
save('DirectComp_LabvsHome.mat','Lab_HometoHome','HometoHome')

ConfMatAll=zeros(length(Activities),length(Activities),length(LabConfMatHome));

for i=length(LabConfMatHome):-1:1
    ConfMatAll(:,:,i)=LabConfMatHome{i};
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

subjinds=cellfun(@(x) ~isempty(x), LabHomeConfMatHome(:,1));
ConfMatAll=zeros(length(Activities),length(Activities),sum(subjinds),size(LabHomeConfMatHome,2));

subjinds=find(subjinds);

for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(LabHomeConfMatHome,2)
        ConfMatAll(:,:,ind,j)=LabHomeConfMatHome{ind,j};
    end
end
ConfMatAll=sum(ConfMatAll,4);
ConfMatAll=sum(ConfMatAll,3);

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])

savefig('ConfusionMat_strokestrokeHome')