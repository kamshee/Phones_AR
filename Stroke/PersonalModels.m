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
Envir_Activities={'Sitting', 'Standing', 'Stair', 'Walking'};

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
        train_counts(j)=sum(strcmp(Train(i).ActivityLabel,Activities{j}));
        test_counts(j)=sum(strcmp(Test(i).ActivityLabel,Activities{j}));
    end
    Subjs_w_All(i)=all([counts(1)+counts(2) counts(3) counts(4)+counts(5) counts(6)])...
        & all([train_counts(1)+train_counts(2) train_counts(3) train_counts(4)+train_counts(5) train_counts(6)])...
        & all([test_counts(1)+test_counts(2) test_counts(3) test_counts(4)+test_counts(5) test_counts(6)]);
end

Subjs_w_All=find(Subjs_w_All);

Feat=[];
Label={};
Subjs=[];
HomeInds=[];

for i=1:length(Subjs_w_All)
    
    % Lab (Day 1)
    ind=Subjs_w_All(i);
    
    FeatTrain=Train(ind).Features(:,FeatInds);
    LabelTrain=Train(ind).ActivityLabel';

    ly_inds=strcmp('Lying',LabelTrain);
    LabelTrain(ly_inds)={'Sitting'};
    
    st_inds=strmatch('Stairs ',LabelTrain);
    LabelTrain(st_inds)={'Stair'};
    
    % Lab (Day 2)
    
    FeatLab=Test(ind).Features(:,FeatInds);
    LabelLab=Test(ind).ActivityLabel';

    ly_inds=strcmp('Lying',LabelLab);
    LabelLab(ly_inds)={'Sitting'};
    
    st_inds=strmatch('Stairs ',LabelLab);
    LabelLab(st_inds)={'Stair'};
    
    % Home
    FeatHome=Home(ind).Features(:,FeatInds);
    LabelHome=Home(ind).ActivityLabel';

    ly_inds=strcmp('Lying',LabelHome);
    LabelHome(ly_inds)={'Sitting'};
    
    st_inds=strmatch('Stairs ',LabelHome);
    LabelHome(st_inds)={'Stair'};
    
    %train/test model
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(FeatTrain,LabelTrain,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,FeatHome);
    LabConfMatHome{i}=confusionmat([Envir_Activities'; LabelHome], ...
        [Envir_Activities'; LabelsRF])-eye(length(Envir_Activities));
    
    LabelsRF = predict(RFModel,FeatLab);
    LabConfMatLab{i}=confusionmat([Envir_Activities'; LabelLab], ...
        [Envir_Activities'; LabelsRF])-eye(length(Envir_Activities));
    
end
%% Plot Results
figure;

ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),length(Subjs_w_All));
for i=1:length(Subjs_w_All)
    ConfMatAll(:,:,i)=LabConfMatHome{i};
end
ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
subplot(3,2,1); imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab Day 1 to Stroke Home');
set(gca,'XTickLabel',Envir_Activities)
set(gca,'YTickLabel',Envir_Activities)
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))
addtexttoConfMat(ConfMatAll)

ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),length(Subjs_w_All));
for i=1:length(Subjs_w_All)
    ConfMatAll(:,:,i)=LabConfMatLab{i};
end
ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
subplot(3,2,2); imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab Day 1 to Stroke Lab Day 2');
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))
addtexttoConfMat(ConfMatAll)

% Accuracy
for i=1:length(Subjs_w_All)
    indSub=Subjs_w_All(i);
    
    Acc_LabHome(i,:)=calc_classacc(LabConfMatHome{i});
    F1_LabHome(i,:)=calc_f1(LabConfMatHome{i});
    Acc_LabLab(i,:)=calc_classacc(LabConfMatLab{i});
    F1_LabLab(i,:)=calc_f1(LabConfMatLab{i});
end

BalAcc_LabHome=nanmean(Acc_LabHome,2);
BalAcc_LabLab=nanmean(Acc_LabLab,2);

% Box plots: Environment-specific
subplot(3,2,3);
boxplot([Acc_LabHome BalAcc_LabHome]);
ylim([0 1.1]);
title('Acc Lab to Home');

subplot(3,2,4);
boxplot([Acc_LabLab BalAcc_LabLab]);
%boxplot_fill('y')
ylim([0 1.1]);
title('Acc Lab to Lab');

subplot(3,2,5);
boxplot(F1_LabHome,Envir_Activities);
ylim([0 1.1]);
title('F1 Lab to Home');

subplot(3,2,6);
boxplot(F1_LabLab,Envir_Activities);
%boxplot_fill('y')
ylim([0 1.1]);
title('F1 Lab to Lab');

% % Save figure
% savefig_pdf('Fig6')