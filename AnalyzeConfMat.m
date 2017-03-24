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
Act_order = [2 1 3 6 4 5];
numAct=length(Activities);

actSed=[1 2 3]; %indices of sedentary activities
actAmb=[4 5 6]; %indices of ambulatory activities

%load('Z:\RERC- Phones\Server Data\Clips\10s\PhoneData_Feat.mat') % Features

%% Lab vs. Home
load('ConfusionMat_strokestrokeHome');
load('DirectComp_LabvsHome');

Envir_Activities={'Sitting', 'Standing', 'Stair', 'Walking'};
Act_order2=[1 2 4 3];
% Confusion Matrix: Lab --> Home
subjinds=cellfun(@(x) ~isempty(x), LabConfMatHome(:));
ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),sum(subjinds),size(LabConfMatHome,2));

subjinds=find(subjinds);

for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(LabConfMatHome,2)
        ConfMatAll(:,:,ind,j)=LabConfMatHome{ind};
    end
end
ConfMatAll=sum(ConfMatAll,4);
ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab to Stroke Home');
set(gca,'XTickLabel',Envir_Activities)
set(gca,'YTickLabel',Envir_Activities)
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))

addtexttoConfMat(ConfMatAll)

% Confusion Matrix: Lab+Home --> Home 
subjinds=cellfun(@(x) ~isempty(x), LabHomeConfMatHome(:,1));
ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),sum(subjinds),size(LabHomeConfMatHome,2));

subjinds=find(subjinds);

StrokeHomeCounts=zeros(length(Envir_Activities),15);
for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(LabHomeConfMatHome,2)
        ConfMatAll(:,:,ind,j)=LabHomeConfMatHome{ind,j};
        if j==1
            StrokeHomeCounts(:,i)=sum(LabHomeConfMatHome{ind,j},2);
        end
    end
end
ConfMatAll=sum(ConfMatAll,4);

subjs_w_All=all(sum(ConfMatAll,2),1);

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab+Home to Stroke Home');
set(gca,'XTickLabel',Envir_Activities)
set(gca,'YTickLabel',Envir_Activities)
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))

addtexttoConfMat(ConfMatAll)


subjinds=cellfun(@(x) ~isempty(x), LabHomeConfMatHome(:,1));
subjinds=subjinds & permute(subjs_w_All,[3 2 1]);
subjinds=find(subjinds);
% Accuracy
for i=1:length(subjinds)
    indSub=subjinds(i);
    
    Acc_Lab_HomeHome(i,:)=calc_classacc(sum(cat(3,Lab_HometoHome{indSub,:}),3));
    Acc_LabHome(i,:)=calc_classacc(LabConfMatHome{indSub});
    
    LabHomeConfMatLab_sub=cat(3,HometoHome{indSub,:});
    LabHomeConfMatHome_sub=cat(3,LabHomeConfMatHome{indSub,:});
    Acc_HometoHome(i,:)=calc_classacc(sum(LabHomeConfMatLab_sub,3));
    Acc_LabHomeHome(i,:)=calc_classacc(sum(LabHomeConfMatHome_sub,3));

end

% Confusion Matrix: Home --> Home
subjinds=cellfun(@(x) ~isempty(x), HometoHome(:,1));
ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),sum(subjinds),size(HometoHome,2));

subjinds=find(subjinds);

StrokeHomeCounts=zeros(length(Envir_Activities),15);
for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(HometoHome,2)
        ConfMatAll(:,:,ind,j)=HometoHome{ind,j}(Act_order2,Act_order2);
        if j==1
            StrokeHomeCounts(:,i)=sum(HometoHome{ind,j},2);
        end
    end
end
ConfMatAll=sum(ConfMatAll,4);

subjs_w_All=all(sum(ConfMatAll,2),1);

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Home to Stroke Home');
set(gca,'XTickLabel',Envir_Activities(Act_order2))
set(gca,'YTickLabel',Envir_Activities(Act_order2))
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))

addtexttoConfMat(ConfMatAll)


% Box plots: Environment-specific
figure;
subplot(2,4,1);
boxplot(Acc_Lab_HomeHome,Envir_Activities);
ylim([0 1.1]);
title('Stroke Lab-Home to Home');

subplot(2,4,2);
boxplot(Acc_LabHome,Envir_Activities);
boxplot_fill('y')
ylim([0 1.1]);
title('Stroke Lab to Stroke Home');

subplot(2,4,3);
boxplot(Acc_HometoHome,Envir_Activities);
ylim([0 1.1]);
title('Stroke Home to Home');

subplot(2,4,4);
boxplot(Acc_LabHomeHome,Envir_Activities);
boxplot_fill([1 0.5 0])
ylim([0 1.1]);
title('Stroke Lab+Home to Stroke Home');

subplot(2,4,[5:8])
BalAcc_Lab_HomeHome=nanmean(Acc_Lab_HomeHome,2);
BalAcc_LabHome=nanmean(Acc_LabHome,2);
BalAcc_HomeHome=nanmean(Acc_HometoHome,2);
BalAcc_LabHomeHome=nanmean(Acc_LabHomeHome,2);
mdl = [repmat({'Lab-Home to Home'}, length(BalAcc_Lab_HomeHome), 1); ...
    repmat({'Lab to Home'}, length(BalAcc_LabHome), 1); ...
    repmat({'Home to Home'}, length(BalAcc_HomeHome), 1); ...
    repmat({'Lab+Home to Home'}, length(BalAcc_LabHomeHome), 1)];

boxplot([BalAcc_Lab_HomeHome; BalAcc_LabHome; BalAcc_HomeHome; BalAcc_LabHomeHome],mdl)
boxplot_fill('y',3); boxplot_fill([1 0.5 0],1)
ylim([0 1.1]); ylabel('Balanced Accuracy');

%% Stroke to Stroke Population

ConfMatAll=zeros(length(Activities),length(Activities),size(PopConfMat,2));

% Confusion Matrix
for i=1:size(PopConfMat,2)
    ConfMatAll(:,:,i)=PopConfMat{i}./repmat(sum(PopConfMat{i},2),[1 6]);
    
    ConfMatSimp(1,1)=nansum(nansum(PopConfMat{i}(actSed,actSed)));
    ConfMatSimp(1,2)=nansum(nansum(PopConfMat{i}(actSed,actAmb)));
    ConfMatSimp(2,1)=nansum(nansum(PopConfMat{i}(actAmb,actSed)));
    ConfMatSimp(2,2)=nansum(nansum(PopConfMat{i}(actAmb,actAmb)));
    correctones = sum(ConfMatSimp,2);
    correctones = repmat(correctones,[1 2]);
    class_perc=ConfMatSimp./correctones .*100;

    % Misclassification (confusing Sed and Amb)
    Misclass_Amb_Sed_StrokePop(i)=class_perc(2,1);
    Misclass_Sed_Amb_StrokePop(i)=class_perc(1,2);
end

ConfMatAll=nansum(ConfMatAll,3);
ConfMatAll=ConfMatAll(Act_order,Act_order);

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure, subplot(2,3,3), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities(Act_order))
set(gca,'YTickLabels',Activities(Act_order))
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke to Stroke')

addtexttoConfMat(ConfMatAll)

% Accuracy
for indSub=1:length(PopConfMat)
    Acc_StrokePop(indSub,:)=calc_classacc(PopConfMat{indSub});
    F1_StrokePop(indSub,:)=calc_f1(PopConfMat{indSub});
end

%% Healthy to Healthy

load('RUSConfusion');

% Confusion Matrix
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i}./repmat(sum(ConfMat{i},2),[1 6]);
end
ConfMatAll=nansum(ConfMatAll,3);
ConfMatAll=ConfMatAll(Act_order,Act_order);

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
subplot(2,3,1), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities(Act_order))
set(gca,'YTickLabels',Activities(Act_order))
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Healthy')

addtexttoConfMat(ConfMatAll)

% Accuracy
for indSub=1:length(ConfMat)
    Acc_Health(indSub,:)=calc_classacc(ConfMat{indSub});
    F1_Health(indSub,:)=calc_f1(ConfMat{indSub});
end

% ActivityCounts
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i};
end
HealthyCounts=sum(sum(ConfMatAll,3),2);

%% Healthy to Stroke (Lab and Home)

load('ConfusionMat_strokeAll.mat')

% Confusion Matrix
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i}./repmat(sum(ConfMat{i},2),[1 6]);
end
ConfMatAll=nansum(ConfMatAll,3);
ConfMatAll=ConfMatAll(Act_order,Act_order);

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
subplot(2,3,2), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities(Act_order))
set(gca,'YTickLabels',Activities(Act_order))
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Stroke')

addtexttoConfMat(ConfMatAll)

% Accuracy
for i=1:30%length(subjinds)
    indSub=i;%subjinds(i);
    Acc_Stroke(i,:)=calc_classacc(ConfMat{indSub});
    F1_Stroke(i,:)=calc_f1(ConfMat{indSub});
end

for i=1:size(ConfMat,2)
    ConfMatSimp(1,1)=nansum(nansum(ConfMat{i}(actSed,actSed)));
    ConfMatSimp(1,2)=nansum(nansum(ConfMat{i}(actSed,actAmb)));
    ConfMatSimp(2,1)=nansum(nansum(ConfMat{i}(actAmb,actSed)));
    ConfMatSimp(2,2)=nansum(nansum(ConfMat{i}(actAmb,actAmb)));
    correctones = sum(ConfMatSimp,2);
    correctones = repmat(correctones,[1 2]);
    class_perc=ConfMatSimp./correctones .*100;

    % Misclassification (confusing Sed and Amb)
    Misclass_Amb_Sed_HealthStroke(i)=class_perc(2,1);
    Misclass_Sed_Amb_HealthStroke(i)=class_perc(1,2);
        
    ConfMatAll(:,:,i)=ConfMat{i};
end
StrokeCounts=sum(sum(ConfMatAll,3),2);

% Box plots: Population

BalAcc_Health=nanmean(Acc_Health,2);
BalAcc_Stroke=nanmean(Acc_Stroke,2);
BalAcc_StrokePop=nanmean(Acc_StrokePop,2);

subplot(2,3,4)
% boxplot(Acc_Health,Activities);
boxplot([Acc_Health BalAcc_Health]);
ylim([0 1.1]);
title('Healthy to Healthy');
%boxplot_fill('b')

subplot(2,3,5)
% boxplot(Acc_Stroke,Activities);
boxplot([Acc_Stroke BalAcc_Stroke]);
%boxplot_fill([0.5 0 0.5])
ylim([0 1.1]);
title('Healthy to Stroke (All)');

subplot(2,3,6)
% boxplot(Acc_StrokePop,Activities);
boxplot([Acc_StrokePop BalAcc_StrokePop]);
%boxplot_fill('r')
ylim([0 1.1]);
title('Stroke to Stroke');

% subplot(2,3,[4:6])
% BalAcc_Health=nanmean(Acc_Health,2);
% BalAcc_Stroke=nanmean(Acc_Stroke,2);
% BalAcc_StrokePop=nanmean(Acc_StrokePop,2);
% mdl = [repmat({'Healthy to Healthy'}, length(BalAcc_Health), 1); ...
%     repmat({'Healthy to Stroke'}, length(BalAcc_Stroke), 1); ...
%     repmat({'Stroke to Stroke'}, length(BalAcc_StrokePop), 1)];
% boxplot([BalAcc_Health; BalAcc_Stroke; BalAcc_StrokePop],mdl)
% boxplot_fill('b',3); boxplot_fill([0.5 0 0.5],2); boxplot_fill('r',1)
% ylim([0 1.1]); ylabel('Balanced Accuracy');

% Save figure
% h=gcf;
% set(h,'Units','Inches');
% pos = get(h,'Position');
% set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(h,'Fig3','-dpdf','-r0')

%% Healthy to Stroke by gait impairment

strokeSev={'Mild','Mod','Sev'};

actSed=[1 2 3]; %indices of sedentary activities
actAmb=[4 5 6]; %indices of ambulatory activities

figure;
for indStroke=1:length(strokeSev)
    load(['ConfusionMat_strokeAll_' strokeSev{indStroke} '.mat'])
    ConfMatAll = ConfMatAll(Act_order,Act_order);


    % Confusion Matrix
    ConfMatAll=nansum(ConfMatAll,3);
    correctones = sum(ConfMatAll,2);
    correctones = repmat(correctones,[1 6]);
    subplot(2,3,indStroke), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
    set(gca,'XTickLabels',Activities(Act_order))
    set(gca,'YTickLabels',Activities(Act_order))
    xlabel('Predicted Activities'); ylabel('True Activities');
    title(['Healthy to Stroke ' strokeSev{indStroke}])
    
    addtexttoConfMat(ConfMatAll)
    
    % Percent misclassified
    subjinds=cellfun(@(x) ~isempty(x), ConfMat(:));
    subjinds=find(subjinds);
    for i=1:length(subjinds)
        indSub=subjinds(i);
        ConfMatSimp(1,1)=nansum(nansum(ConfMat{indSub}(actSed,actSed)));
        ConfMatSimp(1,2)=nansum(nansum(ConfMat{indSub}(actSed,actAmb)));
        ConfMatSimp(2,1)=nansum(nansum(ConfMat{indSub}(actAmb,actSed)));
        ConfMatSimp(2,2)=nansum(nansum(ConfMat{indSub}(actAmb,actAmb)));
        correctones = sum(ConfMatSimp,2);
        correctones = repmat(correctones,[1 2]);
        class_perc=ConfMatSimp./correctones .*100;
        
        % Misclassification (confusing Sed and Amb)
        eval(['Misclass_Amb_Sed_' strokeSev{indStroke} '(i)=class_perc(2,1);']);
        eval(['Misclass_Sed_Amb_' strokeSev{indStroke} '(i)=class_perc(1,2);']);
    end
    
    % Accuracy
    subjinds=cellfun(@(x) ~isempty(x), ConfMat(:));
    subjinds=find(subjinds);
    for i=1:length(subjinds)
        indSub=subjinds(i);
        eval(['Acc_' strokeSev{indStroke} '(i,:)=calc_classacc(ConfMat{indSub});']);
        eval(['F1_' strokeSev{indStroke} '(i,:)=calc_f1(ConfMat{indSub});']);
    end
    
    eval(['BalAcc_' strokeSev{indStroke} '=nanmean(Acc_' strokeSev{indStroke} ',2);']);
    eval(['BalAcc_' strokeSev{indStroke} '_Sed=nanmean(Acc_' strokeSev{indStroke} '(:,1:3),2);']);
    eval(['BalAcc_' strokeSev{indStroke} '_Amb=nanmean(Acc_' strokeSev{indStroke} '(:,4:6),2);']);
    
    subplot(2,3,3+indStroke)
    eval(['boxplot([BalAcc_' strokeSev{indStroke} '_Sed BalAcc_' strokeSev{indStroke} '_Amb]);']);
    ylim([0 1.1]);
    title(['Healthy to ' strokeSev{indStroke}]);
end

% Correlation: velocity in TMWT and balanced accuracy for each subject
V_tmwt=[0.5560,0.3318,0.1676,0.2760,0.2259,0.2345,1.0260,0.4050,0.3850,0.6389,...
    1.5800,0.6700,0.4760,0.9710,0.7037,0.6805,0.3275,0.9000,0.4480,0.5450,...
    0.7250,0.7310,0.3170,1.0010,0.6630,0.8930,0.3630,0.612,0.8557,0.8112];

V_Mild=V_tmwt(V_tmwt>0.8);
V_Mod=V_tmwt(V_tmwt>=0.4 & V_tmwt<=0.8);
V_Sev=V_tmwt(V_tmwt<0.4);

figure; 
subplot(2,2,1); hold on;
plot(V_Mild,nanmean(Acc_Mild(:,actAmb)*100,2),'go')
plot(V_Mod,nanmean(Acc_Mod(:,actAmb)*100,2),'yo')
plot(V_Sev,nanmean(Acc_Sev(:,actAmb)*100,2),'ro')
xlabel('Walking speed (m/s)'); ylabel('Mean Recall (Amb)');
axis([0 1.7 0 100])
[R,P,RL,RU]=corrcoef([V_Mild V_Mod V_Sev]',[nanmean(Acc_Mild(:,actAmb),2); nanmean(Acc_Mod(:,actAmb),2); nanmean(Acc_Sev(:,actAmb),2)],'rows','complete');
fprintf('Corr walking speed to mean Amb recall: r=%5.3f , p=%3.2e \n\n', R(1,2),P(1,2));

subplot(2,2,2); hold on;
plot(V_Mild,Misclass_Amb_Sed_Mild,'go')
plot(V_Mod,Misclass_Amb_Sed_Mod,'yo')
plot(V_Sev,Misclass_Amb_Sed_Sev,'ro')
xlabel('Walking speed (m/s)'); ylabel('Percent misclassified (Amb as Sed)');
axis([0 1.7 0 100])
[R,P,RL,RU]=corrcoef([V_Mild V_Mod V_Sev]',[Misclass_Amb_Sed_Mild Misclass_Amb_Sed_Mod Misclass_Amb_Sed_Sev]','rows','complete');
fprintf('Corr walking speed to Amb->Sed misclass: r=%5.3f , p=%3.2e \n\n', R(1,2),P(1,2));

subplot(2,2,3); hold on;
plot(V_Mild,nanmean(Acc_Mild(:,actSed),2),'gx')
plot(V_Mod,nanmean(Acc_Mod(:,actSed),2),'bx')
plot(V_Sev,nanmean(Acc_Sev(:,actSed),2),'rx')
xlabel('Walking speed (m/s)'); ylabel('Mean Recall (Sed)');
[R,P,RL,RU]=corrcoef([V_Mild V_Mod V_Sev]',[nanmean(Acc_Mild(:,actSed),2); nanmean(Acc_Mod(:,actSed),2); nanmean(Acc_Sev(:,actSed),2)],'rows','complete');
fprintf('Corr walking speed to mean Sed recall: r=%5.3f , p=%3.2e \n\n', R(1,2),P(1,2));

subplot(2,2,4); hold on;
plot(V_Mild,Misclass_Sed_Amb_Mild,'gx')
plot(V_Mod,Misclass_Sed_Amb_Mod,'bx')
plot(V_Sev,Misclass_Sed_Amb_Sev,'rx')
xlabel('Walking speed (m/s)'); ylabel('Percent misclassified (Sed as Amb)');
[R,P,RL,RU]=corrcoef([V_Mild V_Mod V_Sev]',[Misclass_Sed_Amb_Mild Misclass_Sed_Amb_Mod Misclass_Sed_Amb_Sev]','rows','complete');
fprintf('Corr walking speed to Sed->Amb misclass: r=%5.3f , p=%3.2e \n\n', R(1,2),P(1,2));


% Stats
whichmdl={'Mild_Amb','Mod_Amb','Sev_Amb'};
%whichmdl={'Mild_Sed','Mod_Sed','Sev_Sed'};
%whichmdl={'Mild','Mod','Sev','StrokePop','Stroke'};

Recall=[]; Mdl={};
indStats=1;
for i=1:length(whichmdl)
    eval(['thismdl = BalAcc_' whichmdl{i} ';']);
    Recall = [Recall; thismdl];
    Mdl(indStats:indStats+length(thismdl)-1)=whichmdl(i);
    indStats=indStats+length(thismdl);
end
Mdl=Mdl';
fprintf('\n STATS: Gait impairment using Healthy training data \n')
figure;
fprintf('  Anova: \n'); [p,t,stats] = anova1(Recall,Mdl,'off')
fprintf('  Tukey post-hoc: \n'); [c,m,h,nms] = multcompare(stats)
[nms num2cell(m)]

%% Stroke to Stroke by gait impairment
strokeSev={'Mild','Mod','Sev'};

% Mild, Moderate, Severe stroke subjects
strokeClass = [strokeSev; {[7 11 14 18 24 26 29 30],...
    [1 8 10 12 13 15 16 19 20 21 22 25 28],...
    [2 3 4 5 6 9 17 23 27]}];

actSed=[1 2 3]; %indices of sedentary activities
actAmb=[4 5 6]; %indices of ambulatory activities

figure;
for indStroke=1:length(strokeSev)
    subjinds=strokeClass{2,indStroke};
    for i=1:length(subjinds)
        indSub=subjinds(i);
        ConfMatAll(:,:,i)=PopConfMat{indSub}./repmat(sum(PopConfMat{indSub},2),[1 6]);
    end
    ConfMatAll = ConfMatAll(Act_order,Act_order);
    
    % Confusion Matrix
    ConfMatAll=nansum(ConfMatAll,3);
    correctones = sum(ConfMatAll,2);
    correctones = repmat(correctones,[1 6]);
    subplot(2,3,indStroke), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
    set(gca,'XTickLabels',Activities(Act_order))
    set(gca,'YTickLabels',Activities(Act_order))
    xlabel('Predicted Activities'); ylabel('True Activities');
    title(['Stroke to Stroke ' strokeSev{indStroke}])
    
    addtexttoConfMat(ConfMatAll)
    
    % Percent misclassified
    for i=1:length(subjinds)
        indSub=subjinds(i);
        ConfMatSimp(1,1)=nansum(nansum(PopConfMat{indSub}(actSed,actSed)));
        ConfMatSimp(1,2)=nansum(nansum(PopConfMat{indSub}(actSed,actAmb)));
        ConfMatSimp(2,1)=nansum(nansum(PopConfMat{indSub}(actAmb,actSed)));
        ConfMatSimp(2,2)=nansum(nansum(PopConfMat{indSub}(actAmb,actAmb)));
        correctones = sum(ConfMatSimp,2);
        correctones = repmat(correctones,[1 2]);
        class_perc=ConfMatSimp./correctones .*100;
        
        % Misclassification (confusing Sed and Amb)
        eval(['Misclass_Amb_Sed_' strokeSev{indStroke} '(i)=class_perc(2,1);']);
        eval(['Misclass_Sed_Amb_' strokeSev{indStroke} '(i)=class_perc(1,2);']);
    end
    
    % Accuracy;
    for i=1:length(subjinds)
        indSub=subjinds(i);
        eval(['Acc_' strokeSev{indStroke} '(i,:)=calc_classacc(PopConfMat{indSub});']);
        eval(['F1_' strokeSev{indStroke} '(i,:)=calc_f1(PopConfMat{indSub});']);
    end
    
    eval(['BalAcc_stroke' strokeSev{indStroke} '_Sed=nanmean(Acc_' strokeSev{indStroke} '(:,1:3),2);']);
    eval(['BalAcc_stroke' strokeSev{indStroke} '_Amb=nanmean(Acc_' strokeSev{indStroke} '(:,4:6),2);']);
    eval(['BalAcc_stroke' strokeSev{indStroke} '=nanmean(Acc_' strokeSev{indStroke} ',2);']);
    
%     % Split boxplots by Sed and Amb
%     subplot(2,3,3+indStroke)
%     eval(['boxplot([BalAcc_stroke' strokeSev{indStroke} '_Sed BalAcc_stroke' strokeSev{indStroke} '_Amb]);']);
%     ylim([0 1.1]);
%     title(['Stroke to ' strokeSev{indStroke}]);
end

subplot(2,3,4)
g=[1*ones(length(strokeClass{2,1}),1); ...
   2*ones(length(strokeClass{2,2}),1); ...
   3*ones(length(strokeClass{2,3}),1); ...
   4*ones(length(BalAcc_StrokePop),1); ...
   5*ones(length(BalAcc_Stroke),1)];
boxplot([BalAcc_strokeMild; BalAcc_strokeMod; BalAcc_strokeSev; BalAcc_StrokePop; BalAcc_Stroke]*100,g);
ylim([0 110]); ylabel('Mean Recall');

subplot(2,3,5)
g=[1*ones(length(strokeClass{2,1}),1); ...
   2*ones(length(strokeClass{2,2}),1); ...
   3*ones(length(strokeClass{2,3}),1); ...
   4*ones(length(BalAcc_StrokePop),1); ...
   5*ones(length(BalAcc_Stroke),1)];
boxplot([Misclass_Amb_Sed_Mild Misclass_Amb_Sed_Mod Misclass_Amb_Sed_Sev Misclass_Amb_Sed_StrokePop Misclass_Amb_Sed_HealthStroke]',g);
ylim([0 110]); ylabel('Avg Misclass (Amb->Sed)');


% Stats
whichmdl={'strokeMild_Amb','strokeMod_Amb','strokeSev_Amb'};
%whichmdl={'strokeMild','strokeMod','strokeSev','StrokePop','Stroke'};

Recall=[]; Mdl={};
indStats=1;
for i=1:length(whichmdl)
    eval(['thismdl = BalAcc_' whichmdl{i} ';']);
    Recall = [Recall; thismdl];
    Mdl(indStats:indStats+length(thismdl)-1)=whichmdl(i);
    indStats=indStats+length(thismdl);
end
Mdl=Mdl';
fprintf('\n STATS: Gait impairment using Stroke training data \n')
figure;
fprintf('  Anova: \n'); [p,t,stats] = anova1(Recall,Mdl,'off')
fprintf('  Tukey post-hoc: \n'); [c,m,h,nms] = multcompare(stats)
[nms num2cell(m)]

%% Severe to other stroke severity
figure;

% Confusion Matrix, Severe to Severe
load('ConfusionMat_Sev_Sev.mat')

ConfMatAll=nansum(ConfMatAll,3);
actSed=[1 2 3]; %indices of sedentary activities
actAmb=[4 5 6]; %indices of ambulatory activities
ConfMatSimp(1,1)=nansum(nansum(ConfMatAll(actSed,actSed)));
ConfMatSimp(1,2)=nansum(nansum(ConfMatAll(actSed,actAmb)));
ConfMatSimp(2,1)=nansum(nansum(ConfMatAll(actAmb,actSed)));
ConfMatSimp(2,2)=nansum(nansum(ConfMatAll(actAmb,actAmb)));
correctones = sum(ConfMatSimp,2);
correctones = repmat(correctones,[1 2]);
subplot(2,2,1), imagesc(ConfMatSimp./correctones); colorbar; caxis([0 1])
% set(gca,'XTickLabels',Activities)
% set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Severe to Severe')

addtexttoConfMat(ConfMatSimp)

% Accuracy, Severe to Severe
subjinds=cellfun(@(x) ~isempty(x), ConfMat(:));
subjinds=find(subjinds);
for i=1:length(subjinds)
    indSub=subjinds(i);
    Acc_SevSev(i,:)=calc_classacc(ConfMat{indSub});
end

% Confusion Matrix, Mild to Severe
load('ConfusionMat_Sev_Mild.mat')

ConfMatAll=nansum(ConfMatAll,3);
ConfMatSimp(1,1)=nansum(nansum(ConfMatAll(actSed,actSed)));
ConfMatSimp(1,2)=nansum(nansum(ConfMatAll(actSed,actAmb)));
ConfMatSimp(2,1)=nansum(nansum(ConfMatAll(actAmb,actSed)));
ConfMatSimp(2,2)=nansum(nansum(ConfMatAll(actAmb,actAmb)));
correctones = sum(ConfMatSimp,2);
correctones = repmat(correctones,[1 2]);
subplot(2,2,2), imagesc(ConfMatSimp./correctones); colorbar; caxis([0 1])
% set(gca,'XTickLabels',Activities)
% set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Mild to Severe')

addtexttoConfMat(ConfMatSimp)

% Accuracy, Severe to Mild
subjinds=cellfun(@(x) ~isempty(x), ConfMat(:));
subjinds=find(subjinds);
for i=1:length(subjinds)
    indSub=subjinds(i);
    Acc_SevMild(i,:)=calc_classacc(ConfMat{indSub});
end

% Box plots
%BalAcc_SevSev=nanmean(Acc_SevSev,2);
BalAcc_SevSev_Sed=nanmean(Acc_SevSev(:,1:3),2);
BalAcc_SevSev_Amb=nanmean(Acc_SevSev(:,4:6),2);
%BalAcc_SevMild=nanmean(Acc_SevMild,2);
BalAcc_SevMild_Sed=nanmean(Acc_SevMild(:,1:3),2);
BalAcc_SevMild_Amb=nanmean(Acc_SevMild(:,4:6),2);

subplot(2,2,3)
boxplot([BalAcc_SevSev_Sed BalAcc_SevSev_Amb]);
%boxplot([Acc_SevSev]);
ylim([0 1.1]);
title('Severe to Severe');

subplot(2,2,4)
boxplot([BalAcc_SevMild_Sed BalAcc_SevMild_Amb]);
%boxplot([Acc_SevMild]);
ylim([0 1.1]);
title('Mild to Severe');

%% Histograms of class distributions

% Healthy and Stroke (Population)
figure, hold on
bar(1:6,HealthyCounts/sum(HealthyCounts),'FaceColor',[.6 .6 .6],'BarWidth',1)
for j=1:6
    if HealthyCounts(j)
        text(j,HealthyCounts(j)/sum(HealthyCounts)+.015,num2str(HealthyCounts(j)),'Rotation',90)
    end
end
bar(8:13,StrokeCounts/sum(StrokeCounts),'FaceColor',[1 .5 0],'BarWidth',1)
for j=1:6
    if StrokeCounts(j)
        text(7+j,StrokeCounts(j)/sum(StrokeCounts)+.015,num2str(StrokeCounts(j)),'Rotation',90)
    end
end
ax=gca;
ax.XTick=[1:6 8:13];
ax.XTickLabel=[Activities Activities];
ax.XTickLabelRotation=45;

% Stroke Home

StrokeHomeCounts(StrokeHomeCounts<60)=0;
StrokeHomeCounts(:,sum(StrokeHomeCounts)==0)=[];

Activities_abr={'Si', 'L', 'St', 'SU', 'SD', 'W'};

ticks=[];
ticklabels={};

figure, hold on
for i=1:length(StrokeHomeCounts)
    bar((length(Envir_Activities)+1)*(i-1)+1:(length(Envir_Activities)+1)*i-1,StrokeHomeCounts(:,i)/sum(StrokeHomeCounts(:,i)),'FaceColor',[1 .5 0],'BarWidth',1)
    ticks=[ticks (length(Envir_Activities)+1)*(i-1)+1:(length(Envir_Activities)+1)*i-1];
    ticklabels=[ticklabels Activities_abr];
    for j=1:(length(Envir_Activities))
        if StrokeHomeCounts(j,i)
            text((length(Envir_Activities)+1)*(i-1)+j,StrokeHomeCounts(j,i)/sum(StrokeHomeCounts(:,i))+.015,num2str(StrokeHomeCounts(j,i)),'Rotation',90)
        end
    end
end
ax=gca;
ax.XTick=ticks;
ax.XTickLabel=ticklabels;
ax.XTickLabelRotation=90;

%% Envronmental models
load('EnvironmentalModels');
load('DirectComp_LabvsHome');

Envir_Activities={'Sitting', 'Standing', 'Stair', 'Walking'};
Act_order2=[1 2 4 3];

actSed2=[1 2];
actAmb2=[3 4];

% Confusion Matrix: Lab 1 --> Lab 2 
subjinds=cellfun(@(x) ~isempty(x), LabConfMatLab(:,1));
ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),sum(subjinds),size(LabConfMatLab,2));

subjinds=find(subjinds);

LabLabCounts=zeros(length(Envir_Activities),15);
for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(LabConfMatLab,2)
        ConfMatAll(:,:,ind,j)=LabConfMatLab{ind,j}(Act_order2,Act_order2);
        if j==1
            LabLabCounts(:,i)=sum(LabConfMatLab{ind,j},2);
        end
    end
end
ConfMatAll=sum(ConfMatAll,4);
subjs_w_All=all(sum(ConfMatAll,2),1);

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
figure; subplot(2,3,1); imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab 1 to Stroke Lab 2');
set(gca,'XTickLabel',Envir_Activities(Act_order2))
set(gca,'YTickLabel',Envir_Activities(Act_order2))
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))

addtexttoConfMat(ConfMatAll)

ConfMatSimp(1,1)=nansum(nansum(ConfMatAll(actSed2,actSed2)));
ConfMatSimp(1,2)=nansum(nansum(ConfMatAll(actSed2,actAmb2)));
ConfMatSimp(2,1)=nansum(nansum(ConfMatAll(actAmb2,actSed2)));
ConfMatSimp(2,2)=nansum(nansum(ConfMatAll(actAmb2,actAmb2)));
correctones = sum(ConfMatSimp,2);
correctones = repmat(correctones,[1 2]);
class_perc=ConfMatSimp./correctones .*100;

% Misclassification (confusing Sed and Amb)
Misclass_Amb_Sed_LabLab=class_perc(2,1);
Misclass_Sed_Amb_LabLab=class_perc(1,2);

% Confusion Matrix: Lab 1 --> Home 
subjinds=cellfun(@(x) ~isempty(x), LabConfMatLab(:,1));
ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),sum(subjinds),size(LabConfMatLab,2));

subjinds=find(subjinds);

LabHomeCounts=zeros(length(Envir_Activities),15);
for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(LabConfMatHome,2)
        ConfMatAll(:,:,ind,j)=LabConfMatHome{ind,j}(Act_order2,Act_order2);
        if j==1
            LabHomeCounts(:,i)=sum(LabConfMatHome{ind,j},2);
        end
    end
end
ConfMatAll=sum(ConfMatAll,4);
subjs_w_All=all(sum(ConfMatAll,2),1);

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
subplot(2,3,2); imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Lab 1 to Stroke Home');
set(gca,'XTickLabel',Envir_Activities(Act_order2))
set(gca,'YTickLabel',Envir_Activities(Act_order2))
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))

addtexttoConfMat(ConfMatAll)

ConfMatSimp(1,1)=nansum(nansum(ConfMatAll(actSed2,actSed2)));
ConfMatSimp(1,2)=nansum(nansum(ConfMatAll(actSed2,actAmb2)));
ConfMatSimp(2,1)=nansum(nansum(ConfMatAll(actAmb2,actSed2)));
ConfMatSimp(2,2)=nansum(nansum(ConfMatAll(actAmb2,actAmb2)));
correctones = sum(ConfMatSimp,2);
correctones = repmat(correctones,[1 2]);
class_perc=ConfMatSimp./correctones .*100;

% Misclassification (confusing Sed and Amb)
Misclass_Amb_Sed_LabHome=class_perc(2,1);
Misclass_Sed_Amb_LabHome=class_perc(1,2);


% Confusion Matrix: Home --> Home
subjinds=cellfun(@(x) ~isempty(x), HometoHome(:,1));
ConfMatAll=zeros(length(Envir_Activities),length(Envir_Activities),sum(subjinds),size(HometoHome,2));

subjinds=find(subjinds);

StrokeHomeCounts=zeros(length(Envir_Activities),15);
for i=1:length(subjinds)
    ind=subjinds(i);
    for j=1:size(HometoHome,2)
        ConfMatAll(:,:,ind,j)=HometoHome{ind,j}(Act_order2,Act_order2);
        if j==1
            StrokeHomeCounts(:,i)=sum(HometoHome{ind,j},2);
        end
    end
end
ConfMatAll=sum(ConfMatAll,4);
subjs_w_All=all(sum(ConfMatAll,2),1);

ConfMatAll=sum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 length(Envir_Activities)]);
subplot(2,3,3); imagesc(ConfMatAll./correctones, [0 1]); colorbar
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke Home to Stroke Home');
set(gca,'XTickLabel',Envir_Activities(Act_order2))
set(gca,'YTickLabel',Envir_Activities(Act_order2))
set(gca,'XTick',1:length(Envir_Activities))
set(gca,'YTick',1:length(Envir_Activities))

addtexttoConfMat(ConfMatAll)

ConfMatSimp(1,1)=nansum(nansum(ConfMatAll(actSed2,actSed2)));
ConfMatSimp(1,2)=nansum(nansum(ConfMatAll(actSed2,actAmb2)));
ConfMatSimp(2,1)=nansum(nansum(ConfMatAll(actAmb2,actSed2)));
ConfMatSimp(2,2)=nansum(nansum(ConfMatAll(actAmb2,actAmb2)));
correctones = sum(ConfMatSimp,2);
correctones = repmat(correctones,[1 2]);
class_perc=ConfMatSimp./correctones .*100;

% Misclassification (confusing Sed and Amb)
Misclass_Amb_Sed_HomeHome=class_perc(2,1);
Misclass_Sed_Amb_HomeHome=class_perc(1,2);


% Accuracy 
for i=1:length(LabConfMatLab)
    indSub=i;
    Acc_Lab1Lab2(i,:)=calc_classacc(LabConfMatLab{indSub});
    Acc_Lab1Home(i,:)=calc_classacc(LabConfMatHome{indSub});
end

subjinds=cellfun(@(x) ~isempty(x), LabHomeConfMatHome(:,1));
subjinds=subjinds & permute(subjs_w_All,[3 2 1]);
subjinds=find(subjinds);
for i=1:length(subjinds)
    indSub=subjinds(i);
    
    Acc_HomeHome(i,:)=calc_classacc(HometoHome{indSub});
    HometoHome_sub=cat(3,HometoHome{indSub,:});
    Acc_HomeHome(i,:)=calc_classacc(sum(HometoHome_sub,3));
end

% Box plots: Environment-specific
BalAcc_Lab1Lab2=nanmean(Acc_Lab1Lab2,2);
BalAcc_Lab1Home=nanmean(Acc_Lab1Home,2);
BalAcc_HomeHome=nanmean(Acc_HomeHome,2);

subplot(2,3,4)
boxplot([Acc_Lab1Lab2(:,Act_order2) BalAcc_Lab1Lab2]);
ylim([0 1.1]);
title('Lab to Lab');

subplot(2,3,5)
boxplot([Acc_Lab1Home(:,Act_order2) BalAcc_Lab1Home]);
ylim([0 1.1]);
title('Lab to Home');

subplot(2,3,6)
boxplot([Acc_HomeHome(:,Act_order2) BalAcc_HomeHome]);
ylim([0 1.1]);
title('Home to Home');

