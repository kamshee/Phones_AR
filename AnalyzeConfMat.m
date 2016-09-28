clc
clear all
%close all
% -------------------------------------------------------------------------
% AnalyzeConfMat.m

% Generate tables or figures relating to classifier output.

% Input: .mat data from classifier scripts
% Output: ConfMat, Boxplot, table 
% -------------------------------------------------------------------------

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
numAct=length(Activities);

%load('Z:\RERC- Phones\Server Data\Clips\10s\PhoneData_Feat.mat') % Features

%% Healthy to Healthy

load('RUSConfusion');

% Confusion Matrix
for i=1:size(ConfMat,3)
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
        text(i-0.25,j,num2str(ConfMat(i,j)));
    end
end

% % Box plots
% F1_Healthy=calc_f1(ConfMatAll);
% 
% figure;
% boxplot(F1_Healthy,Activities); 
% title('Healthy to Healthy');

%% Healthy to Stroke

load('ConfusionMat_strokeHome.mat')

correctones = sum(ConfMat,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMat./correctones); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Stroke Home')

for i=1:numAct
    for j=1:numAct
        text(i-0.25,j,num2str(ConfMat(i,j)));
    end
end

% % Box plots
% F1_Stroke(i,:)=calc_f1(ConfMat);
%
% figure;
% boxplot(F1_Stroke,Activities); 
% title('Healthy to Stroke');

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
        text(i-0.25,j,num2str(ConfMatAll(i,j)));
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
        text(i-0.25,j,num2str(ConfMatAll(i,j)));
    end
end

% Box plots
for i=1:length(subjinds)
    indSub=subjinds(i);
    F1_LabLab(i,:)=calc_f1(LabConfMatLab{1,indSub});
    F1_LabHome(i,:)=calc_f1(LabConfMatHome{1,indSub});
    
    LabHomeConfMatLab_sub=cat(3,LabHomeConfMatLab{indSub,:});
    LabHomeConfMatHome_sub=cat(3,LabHomeConfMatHome{indSub,:});
    F1_LabHomeLab(i,:)=calc_f1(sum(LabHomeConfMatLab_sub,3));
    F1_LabHomeHome(i,:)=calc_f1(sum(LabHomeConfMatHome_sub,3));

end

figure;
boxplot(F1_LabLab,Activities); 
title('Stroke Lab to Stroke Lab');

figure;
boxplot(F1_LabHome,Activities); 
title('Stroke Lab to Stroke Home');

figure;
boxplot(F1_LabHomeLab,Activities); 
title('Stroke Lab+Home to Stroke Lab');

figure;
boxplot(F1_LabHomeHome,Activities); 
title('Stroke Lab+Home to Stroke Home');

