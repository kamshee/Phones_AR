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
load('DirectComp_LabvsHome');

% Confusion Matrix: Lab --> Home
subjinds=cellfun(@(x) ~isempty(x), LabConfMatHome(:));
ConfMatAll=zeros(length(Activities),length(Activities),sum(subjinds),size(LabConfMatHome,2));

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
        conf_str=num2str(ConfMatAll(j,i));
        if ConfMatAll(j,i)/correctones(j,i)<0.15
            txtclr='w';
        else
            txtclr='k';
        end
        text(i-0.25,j,conf_str,'Color',txtclr);
    end
end

% Confusion Matrix: Lab+Home --> Home 
subjinds=cellfun(@(x) ~isempty(x), LabHomeConfMatHome(:,1));
ConfMatAll=zeros(length(Activities),length(Activities),sum(subjinds),size(LabHomeConfMatHome,2));

subjinds=find(subjinds);

StrokeHomeCounts=zeros(6,15);
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
        conf_str=num2str(ConfMatAll(j,i));
        if ConfMatAll(j,i)/correctones(j,i)<0.15
            txtclr='w';
        else
            txtclr='k';
        end
        text(i-0.25,j,conf_str,'Color',txtclr);
    end
end

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

% Box plots: Environment-specific
figure;
subplot(2,4,1);
boxplot(Acc_Lab_HomeHome,Activities);
ylim([0 1.1]);
title('Stroke Lab-Home to Home');

subplot(2,4,2);
boxplot(Acc_LabHome,Activities);
boxplot_fill('y')
ylim([0 1.1]);
title('Stroke Lab to Stroke Home');

subplot(2,4,3);
boxplot(Acc_HometoHome,Activities);
ylim([0 1.1]);
title('Stroke Home to Home');

subplot(2,4,4);
boxplot(Acc_LabHomeHome,Activities);
boxplot_fill([1 0.5 0])
ylim([0 1.1]);
title('Stroke Lab+Home to Stroke Home');

subplot(2,4,[5:8])
BalAcc_LabLab=nanmean(Acc_Lab_HomeHome,2);
BalAcc_LabHome=nanmean(Acc_LabHome,2);
BalAcc_LabHomeLab=nanmean(Acc_HometoHome,2);
BalAcc_LabHomeHome=nanmean(Acc_LabHomeHome,2);
mdl = [repmat({'Lab to Lab'}, length(BalAcc_LabLab), 1); ...
    repmat({'Lab to Home'}, length(BalAcc_LabHome), 1); ...
    repmat({'Lab+Home to Lab'}, length(BalAcc_LabHomeLab), 1); ...
    repmat({'Lab+Home to Home'}, length(BalAcc_LabHomeHome), 1)];

boxplot([BalAcc_LabLab; BalAcc_LabHome; BalAcc_LabHomeLab; BalAcc_LabHomeHome],mdl)
boxplot_fill('y',3); boxplot_fill([1 0.5 0],1)
ylim([0 1.1]); ylabel('Balanced Accuracy');

%% Stroke to Stroke Population

% Confusion Matrix
for i=1:size(PopConfMat,2)
    ConfMatAll(:,:,i)=PopConfMat{i}./repmat(sum(PopConfMat{i},2),[1 6]);
end

ConfMatAll=nansum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure, subplot(2,3,3), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Stroke to Stroke')

for i=1:numAct
    for j=1:numAct
        conf_str=num2str(.01*round(10000*ConfMatAll(j,i)/correctones(j,i)),'%10.3g');
        % Add trailing zeros
        if length(conf_str)<4 && ~strcmp('0',conf_str)
            if isempty(regexp(conf_str,'\.','once'))
                if length(conf_str)==2
                    conf_str=[conf_str '.0'];
                elseif length(conf_str)==1
                    conf_str=[conf_str '.00'];
                end
            else
                conf_str=[conf_str '0'];
            end
        end 
            
        if ConfMatAll(j,i)/correctones(j,i)<0.15
            txtclr='w';
        else
            txtclr='k';
        end
        text(i-0.25,j,conf_str,'Color',txtclr);
    end
end

% Accuracy
for indSub=1:length(PopConfMat)
    Acc_StrokePop(indSub,:)=calc_classacc(PopConfMat{indSub});
end


%% Healthy to Healthy

load('RUSConfusion');

% Confusion Matrix
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i}./repmat(sum(ConfMat{i},2),[1 6]);
end

ConfMatAll=nansum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
subplot(2,3,1), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Healthy')

for i=1:numAct
    for j=1:numAct
        conf_str=num2str(.01*round(10000*ConfMatAll(j,i)/correctones(j,i)),'%10.3g');
        % Add trailing zeros
        if length(conf_str)<4 && ~strcmp('0',conf_str)
            if isempty(regexp(conf_str,'\.','once'))
                if length(conf_str)==2
                    conf_str=[conf_str '.0'];
                elseif length(conf_str)==1
                    conf_str=[conf_str '.00'];
                end
            else
                conf_str=[conf_str '0'];
            end
        end        
        
        if ConfMatAll(j,i)/correctones(j,i)<0.15
            txtclr='w';
        else
            txtclr='k';
        end
        text(i-0.25,j,conf_str,'Color',txtclr);
    end
end

% Accuracy
for indSub=1:length(ConfMat)
    Acc_Health(indSub,:)=calc_classacc(ConfMat{indSub});
end

% ActivityCounts
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i};
end
HealthyCounts=sum(sum(ConfMatAll,3),2);

%% Healthy to Stroke Home

load('ConfusionMat_strokeAll.mat')

% Confusion Matrix
for i=1:size(ConfMat,2)
    ConfMatAll(:,:,i)=ConfMat{i}./repmat(sum(ConfMat{i},2),[1 6]);
end

ConfMatAll=nansum(ConfMatAll,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
subplot(2,3,2), imagesc(ConfMatAll./correctones); colorbar; caxis([0 1])
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
xlabel('Predicted Activities'); ylabel('True Activities');
title('Healthy to Stroke')

for i=1:numAct
    for j=1:numAct
        conf_str=num2str(.01*round(10000*ConfMatAll(j,i)/correctones(j,i)),'%10.3g');
        % Add trailing zeros
        if length(conf_str)<4 && ~strcmp('0',conf_str)
            if isempty(regexp(conf_str,'\.','once'))
                if length(conf_str)==2
                    conf_str=[conf_str '.0'];
                elseif length(conf_str)==1
                    conf_str=[conf_str '.00'];
                end
            else
                conf_str=[conf_str '0'];
            end
        end 
        
        if ConfMatAll(j,i)/correctones(j,i)<0.15
            txtclr='w';
        else
            txtclr='k';
        end
        text(i-0.25,j,conf_str,'Color',txtclr);
    end
end

% Accuracy
for i=1:30%length(subjinds)
    indSub=i;%subjinds(i);
    Acc_Stroke(i,:)=calc_classacc(ConfMat{indSub});
end

for i=1:size(ConfMat,2)
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
    bar(7*(i-1)+1:7*i-1,StrokeHomeCounts(:,i)/sum(StrokeHomeCounts(:,i)),'FaceColor',[1 .5 0],'BarWidth',1)
    ticks=[ticks 7*(i-1)+1:7*i-1];
    ticklabels=[ticklabels Activities_abr];
    for j=1:6
        if StrokeHomeCounts(j,i)
            text(7*(i-1)+j,StrokeHomeCounts(j,i)/sum(StrokeHomeCounts(:,i))+.015,num2str(StrokeHomeCounts(j,i)),'Rotation',90)
        end
    end
end
ax=gca;
ax.XTick=ticks;
ax.XTickLabel=ticklabels;
ax.XTickLabelRotation=90;