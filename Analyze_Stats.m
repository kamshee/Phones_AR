%% get Statistics
% Population Models

precision=3; % specify precision of values

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};

Pop_Stats{1,1}='H->H F1';
Pop_Stats{2,1}='H->S F1';
Pop_Stats{3,1}='S->S F1';
Pop_Stats{4,1}='H->H Acc';
Pop_Stats{5,1}='H->S Acc';
Pop_Stats{6,1}='S->S Acc';

load RUSConfusion

F1=[];
Acc=[];

for i=1:length(ConfMat)
    F1(:,i)=calc_f1(ConfMat{i});
    Acc(:,i)=calc_classacc(ConfMat{i});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    Pop_Stats{1,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    Pop_Stats{4,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

F1=[];
Acc=[];

Mild=load('ConfusionMat_strokeAll_Mild');
Mod=load('ConfusionMat_strokeAll_Mod');
Sev=load('ConfusionMat_strokeAll_Sev');

Mild_inds=cellfun(@(x) ~isempty(x),Mild.ConfMat);
Mod_inds=cellfun(@(x) ~isempty(x),Mod.ConfMat);
Sev_inds=cellfun(@(x) ~isempty(x),Sev.ConfMat);

StrokeConfMat=cell(1,30);
StrokeConfMat(Mild_inds)=Mild.ConfMat(Mild_inds);
StrokeConfMat(Mod_inds)=Mod.ConfMat(Mod_inds);
StrokeConfMat(Sev_inds)=Sev.ConfMat(Sev_inds);

for i=1:length(StrokeConfMat)
    F1(:,i)=calc_f1(StrokeConfMat{i});
    Acc(:,i)=calc_classacc(StrokeConfMat{i});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    Pop_Stats{2,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    Pop_Stats{5,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

F1=[];
Acc=[];

load ConfusionMat_strokestrokeHome

for i=1:length(PopConfMat)
    F1(:,i)=calc_f1(PopConfMat{i});
    Acc(:,i)=calc_classacc(PopConfMat{i});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    Pop_Stats{3,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    Pop_Stats{6,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

PopStats=table();

PopStats.Model=Pop_Stats(:,1);
PopStats.Sitting=Pop_Stats(:,2);
PopStats.Lying=Pop_Stats(:,3);
PopStats.Standing=Pop_Stats(:,4);
PopStats.StairsUp=Pop_Stats(:,5);
PopStats.StairsDown=Pop_Stats(:,6);
PopStats.Walking=Pop_Stats(:,7);
PopStats.Average=Pop_Stats(:,8);

%% Gait impairment 

GI_Stats{1,1}='H->Mild F1';
GI_Stats{2,1}='H->Mod F1';
GI_Stats{3,1}='H->Sev F1';
GI_Stats{4,1}='H->Mild Acc';
GI_Stats{5,1}='H->Mod Acc';
GI_Stats{6,1}='H->Sev Acc';

F1=[];
Acc=[];

Mild_inds=find(Mild_inds);

for i=1:length(Mild_inds)
    F1(:,i)=calc_f1(Mild.ConfMat{Mild_inds(i)});
    Acc(:,i)=calc_classacc(Mild.ConfMat{Mild_inds(i)});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    GI_Stats{1,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    GI_Stats{4,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

F1=[];
Acc=[];

Mod_inds=find(Mod_inds);

for i=1:length(Mod_inds)
    F1(:,i)=calc_f1(Mod.ConfMat{Mod_inds(i)});
    Acc(:,i)=calc_classacc(Mod.ConfMat{Mod_inds(i)});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    GI_Stats{2,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    GI_Stats{5,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

F1=[];
Acc=[];

Sev_inds=find(Sev_inds);

for i=1:length(Sev_inds)
    F1(:,i)=calc_f1(Sev.ConfMat{Sev_inds(i)});
    Acc(:,i)=calc_classacc(Sev.ConfMat{Sev_inds(i)});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    GI_Stats{3,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    GI_Stats{6,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

GIStats=table();

GIStats.Model=GI_Stats(:,1);
GIStats.Sitting=GI_Stats(:,2);
GIStats.Lying=GI_Stats(:,3);
GIStats.Standing=GI_Stats(:,4);
GIStats.StairsUp=GI_Stats(:,5);
GIStats.StairsDown=GI_Stats(:,6);
GIStats.Walking=GI_Stats(:,7);
GIStats.Average=GI_Stats(:,8);

%% Environmental Models

Activities={'Sitting', 'Standing', 'Stairs', 'Walking'};

load EnvironmentalModels

Env_Stats{1,1}='L->H F1';
Env_Stats{2,1}='L->L F1';
Env_Stats{3,1}='L->H Acc';
Env_Stats{4,1}='L->L Acc';

F1=[];
Acc=[];

for i=1:length(LabConfMatHome)
    F1(:,i)=calc_f1(LabConfMatHome{i});
    Acc(:,i)=calc_classacc(LabConfMatHome{i});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    Env_Stats{1,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    Env_Stats{3,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

F1=[];
Acc=[];

for i=1:length(LabConfMatLab)
    F1(:,i)=calc_f1(LabConfMatLab{i});
    Acc(:,i)=calc_classacc(LabConfMatLab{i});
end

F1_stats=[nanmean(F1,2) nanstd(F1,0,2) sum(~isnan(F1),2); ...
    mean(mean(F1(:,all(~isnan(F1),1)))) std(mean(F1(:,all(~isnan(F1),1)))) sum(all(~isnan(F1),1))];
Acc_stats=[nanmean(Acc,2) nanstd(Acc,0,2) sum(~isnan(Acc),2); ...
    mean(mean(Acc(:,all(~isnan(Acc),1)))) std(mean(Acc(:,all(~isnan(Acc),1)))) sum(all(~isnan(Acc),1))];

for i=1:length(Activities)+1
    Env_Stats{2,i+1}=[num2str(F1_stats(i,1),precision) ' +/- ' num2str(F1_stats(i,2),precision) ...
        ' (' num2str(F1_stats(i,3),'%i') ')'];
end

for i=1:length(Activities)+1
    Env_Stats{4,i+1}=[num2str(Acc_stats(i,1),precision) ' +/- ' num2str(Acc_stats(i,2),precision) ...
        ' (' num2str(Acc_stats(i,3),'%i') ')'];
end

EnvStats=table();

EnvStats.Model=Env_Stats(:,1);
EnvStats.Sitting=Env_Stats(:,2);
EnvStats.Standing=Env_Stats(:,3);
EnvStats.Stairs=Env_Stats(:,4);
EnvStats.Walking=Env_Stats(:,5);
EnvStats.Average=Env_Stats(:,6);

save ModelStats PopStats GIStats EnvStats