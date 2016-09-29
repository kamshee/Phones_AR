clc
clear all
close all
% -------------------------------------------------------------------------
% AnalyzeConfMat.m

% Generate tables or figures relating to classifier output.

% Input: .mat data from classifier scripts
% Output: ConfMat, Boxplot, table 
% -------------------------------------------------------------------------

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
numAct=length(Activities);

%load('Z:\RERC- Phones\Server Data\Clips\10s\PhoneData_Feat.mat') % Features

%% Lab vs. Home
load('ConfusionMat_strokestrokeHome');

% Confusion Matrix: Lab+Home --> Lab 
subjinds=cellfun(@(x) ~isempty(x), LabHomeConfMatLab(:,1));
ConfMatAll=zeros(length(Activities),length(Activities),sum(subjinds),size(LabHomeConfMatLab,2));

subjinds=find(subjinds);

for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(LabHomeConfMatLab,2)
        ConfMatAll(:,:,ind,j)=LabHomeConfMatLab{ind,j};
    end
end
ConfMatAll=sum(ConfMatAll,4);
ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab+Home to Stroke Lab');
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])

for i=1:numAct
    for j=1:numAct
        text(i-0.25,j,num2str(ConfMatAll(j,i)));
    end
end

% Confusion Matrix: Lab+Home --> Home 
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
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab+Home to Stroke Home');
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])

for i=1:numAct
    for j=1:numAct
        text(i-0.25,j,num2str(ConfMatAll(j,i)));
    end
end

% Accuracy
for i=1:length(subjinds)
    indSub=subjinds(i);
    
    Acc_LabLab(i,:)=calc_classacc(LabConfMatLab{indSub});
    Acc_LabHome(i,:)=calc_classacc(LabConfMatHome{indSub});
    
    LabHomeConfMatLab_sub=cat(3,LabHomeConfMatLab{indSub,:});
    LabHomeConfMatHome_sub=cat(3,LabHomeConfMatHome{indSub,:});
    Acc_LabHomeLab(i,:)=calc_classacc(sum(LabHomeConfMatLab_sub,3));
    Acc_LabHomeHome(i,:)=calc_classacc(sum(LabHomeConfMatHome_sub,3));

end

% Box plots: Environment-specific
figure;
subplot(2,4,1);
boxplot(Acc_LabLab,Activities);
ylim([0 1.1]);
title('Stroke Lab to Stroke Lab');

subplot(2,4,2);
boxplot(Acc_LabHome,Activities);
boxplot_fill('y')
ylim([0 1.1]);
title('Stroke Lab to Stroke Home');

subplot(2,4,3);
boxplot(Acc_LabHomeLab,Activities);
ylim([0 1.1]);
title('Stroke Lab+Home to Stroke Lab');

subplot(2,4,4);
boxplot(Acc_LabHomeHome,Activities);
boxplot_fill([1 0.5 0])
ylim([0 1.1]);
title('Stroke Lab+Home to Stroke Home');

subplot(2,4,[5:8])
BalAcc_LabLab=nanmean(Acc_LabLab,2);
BalAcc_LabHome=nanmean(Acc_LabHome,2);
BalAcc_LabHomeLab=nanmean(Acc_LabHomeLab,2);
BalAcc_LabHomeHome=nanmean(Acc_LabHomeHome,2);
mdl = [repmat({'Lab to Lab'}, length(BalAcc_LabLab), 1); ...
    repmat({'Lab to Home'}, length(BalAcc_LabHome), 1); ...
    repmat({'Lab+Home to Lab'}, length(BalAcc_LabHomeLab), 1); ...
    repmat({'Lab+Home to Home'}, length(BalAcc_LabHomeHome), 1)];

boxplot([BalAcc_LabLab; BalAcc_LabHome; BalAcc_LabHomeLab; BalAcc_LabHomeHome],mdl)
boxplot_fill('y',3); boxplot_fill([1 0.5 0],1)
ylim([0 1.1]); ylabel('Balanced Accuracy');

%% Healthy to Healthy

load('RUSConfusion');

% Confusion Matrix
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i};
end

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Healthy')

for i=1:numAct
    for j=1:numAct
        text(i-0.25,j,num2str(ConfMatAll(j,i)));
    end
end

% Accuracy
for indSub=1:length(ConfMat)
    Acc_Health(indSub,:)=calc_classacc(ConfMat{indSub});
end

%% Healthy to Stroke Home

load('ConfusionMat_strokeAll.mat')

% Confusion Matrix
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i};
end

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Stroke Home')

for i=1:numAct
    for j=1:numAct
        text(i-0.25,j,num2str(ConfMatAll(j,i)));
    end
end

% Accuracy
for i=1:30%length(subjinds)
    indSub=i;%subjinds(i);
    Acc_Stroke(i,:)=calc_classacc(ConfMat{indSub});
end

% Box plots: Population
figure;
subplot(2,3,1)
boxplot(Acc_Health,Activities);
ylim([0 1.1]);
title('Healthy to Healthy');
boxplot_fill('b')

subplot(2,3,2)
boxplot(Acc_Stroke,Activities);
boxplot_fill([0.5 0 0.5])
ylim([0 1.1]);
title('Healthy to Stroke (All)');

subplot(2,3,3)
boxplot(Acc_LabHomeHome,Activities);
boxplot_fill('r')
ylim([0 1.1]);
title('Stroke (Lab+Home) to Stroke (Home)');

subplot(2,3,[4:6])
BalAcc_Health=nanmean(Acc_Health,2);
BalAcc_Stroke=nanmean(Acc_Stroke,2);
mdl = [repmat({'Healthy to Healthy'}, length(BalAcc_Health), 1); ...
    repmat({'Healthy to Stroke'}, length(BalAcc_Stroke), 1); ...
    repmat({'Stroke (Lab+Home) to Stroke (Home)'}, length(BalAcc_LabHomeHome), 1)];
boxplot([BalAcc_Health; BalAcc_Stroke; BalAcc_LabHomeHome],mdl)
boxplot_fill('b',3); boxplot_fill([0.5 0 0.5],2); boxplot_fill('r',1)
ylim([0 1.1]); ylabel('Balanced Accuracy');