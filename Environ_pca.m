clc
clear all
close all

Act_Stat = {'Lying','Sitting','Standing'};
Act_Amb = {'Walking','Stairs Up','Stairs Down'};
Act_All = {'Lying','Sitting','Standing','Walking','Stairs'};

Env = {'Lab1','Lab2','Home'};

rmvFeat=1;
if rmvFeat
    load NormImp
    FeatInds=find(norm_imp>.25);
else
    FeatInds=1:270;
end
%% Load Lab1
load('Z:\RERC- Phones\Stroke\Clips\Train_Feat.mat')
Lab1 = vertcat(AllFeat.Features);
Lab1 = Lab1(:,FeatInds);
ind_Lab1.All = 1:length(Lab1);

% Activity Vector
FeatAct.Lab1 = horzcat(AllFeat.ActivityLabel);

% Subject Vector
idx1=1;
for indSub=1:length(AllFeat)
    idx2=idx1+length(AllFeat(indSub).ActivityLabel)-1;
    if idx2<idx1
        continue
    end
    FeatSub.Lab1(idx1:idx2) = indSub;
    idx1=idx2+1;
end

% Stationary vs. Ambulatory
isStat.Lab1 = ismember(FeatAct.Lab1,Act_Stat)';
isAmb.Lab1 = ismember(FeatAct.Lab1,Act_Amb)';

% Each activity
isLying.Lab1 = ismember(FeatAct.Lab1,'Lying')';
isSitting.Lab1 = ismember(FeatAct.Lab1,'Sitting')';
isStanding.Lab1 = ismember(FeatAct.Lab1,'Standing')';
isWalking.Lab1 = ismember(FeatAct.Lab1,'Walking')';
isStairs.Lab1 = ismember(FeatAct.Lab1,{'Stairs Up','Stairs Down'})';


%% Load Lab2
load('Z:\RERC- Phones\Stroke\Clips\Test_Feat.mat')
Lab2=vertcat(AllFeat.Features);
Lab2 = Lab2(:,FeatInds);
ind_Lab2.All = ind_Lab1.All(end)+1:ind_Lab1.All(end)+length(Lab2);

% Activity Vector
FeatAct.Lab2 = horzcat(AllFeat.ActivityLabel);

% Subject Vector
idx1=1;
for indSub=1:length(AllFeat)
    idx2=idx1+length(AllFeat(indSub).ActivityLabel)-1;
    if idx2<idx1
        continue
    end
    FeatSub.Lab2(idx1:idx2) = indSub;
    idx1=idx2+1;
end

% Stationary vs. Ambulatory
isStat.Lab2 = ismember(FeatAct.Lab2,Act_Stat)';
isAmb.Lab2 = ismember(FeatAct.Lab2,Act_Amb)';

% Each activity
isLying.Lab2 = ismember(FeatAct.Lab2,'Lying')';
isSitting.Lab2 = ismember(FeatAct.Lab2,'Sitting')';
isStanding.Lab2 = ismember(FeatAct.Lab2,'Standing')';
isWalking.Lab2 = ismember(FeatAct.Lab2,'Walking')';
isStairs.Lab2 = ismember(FeatAct.Lab2,{'Stairs Up','Stairs Down'})';

%% Load Home
load('Z:\RERC- Phones\Stroke\Clips\Home_Feat.mat')
Home=vertcat(AllFeat.Features);
Home = Home(:,FeatInds);
ind_Home.All = ind_Lab2.All(end)+1:ind_Lab2.All(end)+length(Home);

% Activity Vector
FeatAct.Home = horzcat(AllFeat.ActivityLabel);

% Subject Vector
idx1=1;
for indSub=1:length(AllFeat)
    idx2=idx1+length(AllFeat(indSub).ActivityLabel)-1;
    if idx2<idx1
        continue
    end
    FeatSub.Home(idx1:idx2) = indSub;
    idx1=idx2+1;
end

% Stationary vs. Ambulatory
isStat.Home = ismember(horzcat(AllFeat.ActivityLabel),Act_Stat)';
isAmb.Home = ismember(horzcat(AllFeat.ActivityLabel),Act_Amb)';

% Each activity
isLying.Home = ismember(FeatAct.Home,'Lying')';
isSitting.Home = ismember(FeatAct.Home,'Sitting')';
isStanding.Home = ismember(FeatAct.Home,'Standing')';
isWalking.Home = ismember(FeatAct.Home,'Walking')';
isStairs.Home = ismember(FeatAct.Home,{'Stairs Up','Stairs Down'})';

%% All Features
AllEnv = vertcat(Lab1,Lab2,Home);

AllEnv_Stat = AllEnv(vertcat(isStat.Lab1,isStat.Lab2,isStat.Home),:);
AllEnv_Amb = AllEnv(vertcat(isAmb.Lab1,isAmb.Lab2,isAmb.Home),:);

AllEnv_Lying = AllEnv(vertcat(isLying.Lab1,isLying.Lab2,isLying.Home),:);
AllEnv_Sitting = AllEnv(vertcat(isSitting.Lab1,isSitting.Lab2,isSitting.Home),:);
AllEnv_Standing = AllEnv(vertcat(isStanding.Lab1,isStanding.Lab2,isStanding.Home),:);
AllEnv_Walking = AllEnv(vertcat(isWalking.Lab1,isWalking.Lab2,isWalking.Home),:);
AllEnv_Stairs = AllEnv(vertcat(isStairs.Lab1,isStairs.Lab2,isStairs.Home),:);


%% Indices in All Features
% Stationary
ind_Lab1.Stat = 1:length(ind_Lab1.All(isStat.Lab1~=0));
ind_Lab2.Stat = ind_Lab1.Stat(end)+1:ind_Lab1.Stat(end)+length(ind_Lab2.All(isStat.Lab2~=0));
ind_Home.Stat = ind_Lab2.Stat(end)+1:ind_Lab2.Stat(end)+length(ind_Home.All(isStat.Home~=0));

% Ambulatory
ind_Lab1.Amb = 1:length(ind_Lab1.All(isAmb.Lab1~=0));
ind_Lab2.Amb = ind_Lab1.Amb(end)+1:ind_Lab1.Amb(end)+length(ind_Lab2.All(isAmb.Lab2~=0));
ind_Home.Amb = ind_Lab2.Amb(end)+1:ind_Lab2.Amb(end)+length(ind_Home.All(isAmb.Home~=0));

% Lying
ind_Lab1.Lying = 1:length(ind_Lab1.All(isLying.Lab1~=0));
ind_Lab2.Lying = ind_Lab1.Lying(end)+1:ind_Lab1.Lying(end)+length(ind_Lab2.All(isLying.Lab2~=0));
ind_Home.Lying = ind_Lab2.Lying(end)+1:ind_Lab2.Lying(end)+length(ind_Home.All(isLying.Home~=0));

% Sitting
ind_Lab1.Sitting = 1:length(ind_Lab1.All(isSitting.Lab1~=0));
ind_Lab2.Sitting = ind_Lab1.Sitting(end)+1:ind_Lab1.Sitting(end)+length(ind_Lab2.All(isSitting.Lab2~=0));
ind_Home.Sitting = ind_Lab2.Sitting(end)+1:ind_Lab2.Sitting(end)+length(ind_Home.All(isSitting.Home~=0));

% Standing
ind_Lab1.Standing = 1:length(ind_Lab1.All(isStanding.Lab1~=0));
ind_Lab2.Standing = ind_Lab1.Standing(end)+1:ind_Lab1.Standing(end)+length(ind_Lab2.All(isStanding.Lab2~=0));
ind_Home.Standing = ind_Lab2.Standing(end)+1:ind_Lab2.Standing(end)+length(ind_Home.All(isStanding.Home~=0));

% Walking
ind_Lab1.Walking = 1:length(ind_Lab1.All(isWalking.Lab1~=0));
ind_Lab2.Walking = ind_Lab1.Walking(end)+1:ind_Lab1.Walking(end)+length(ind_Lab2.All(isWalking.Lab2~=0));
ind_Home.Walking = ind_Lab2.Walking(end)+1:ind_Lab2.Walking(end)+length(ind_Home.All(isWalking.Home~=0));

% Stairs
ind_Lab1.Stairs = 1:length(ind_Lab1.All(isStairs.Lab1~=0));
ind_Lab2.Stairs = ind_Lab1.Stairs(end)+1:ind_Lab1.Stairs(end)+length(ind_Lab2.All(isStairs.Lab2~=0));
ind_Home.Stairs = ind_Lab2.Stairs(end)+1:ind_Lab2.Stairs(end)+length(ind_Home.All(isStairs.Home~=0));

%% PCA: Stationary vs. Ambulatory
[coeff.Stat,score.Stat,latent.Stat,tsquared.Stat,explained.Stat,mu.Stat] = pca(zscore(AllEnv_Stat));
[coeff.Amb,score.Amb,latent.Amb,tsquared.Amb,explained.Amb,mu.Amb] = pca(zscore(AllEnv_Amb));

figure;

% 2d
subplot(2,2,1); hold on;
plot(score.Stat(ind_Lab1.Stat,1),score.Stat(ind_Lab1.Stat,2),'k+');
plot(score.Stat(ind_Lab2.Stat,1),score.Stat(ind_Lab2.Stat,2),'b+');
plot(score.Stat(ind_Home.Stat,1),score.Stat(ind_Home.Stat,2),'r+')
xlabel('Component 1'); ylabel('Component 2');
title('Stationary (2-D)')

subplot(2,2,2); hold on;
plot3(score.Amb(ind_Lab1.Amb,1),score.Amb(ind_Lab1.Amb,2),score.Amb(ind_Lab1.Amb,3),'k+');
plot3(score.Amb(ind_Lab2.Amb,1),score.Amb(ind_Lab2.Amb,2),score.Amb(ind_Lab2.Amb,3),'b+');
plot3(score.Amb(ind_Home.Amb,1),score.Amb(ind_Home.Amb,2),score.Amb(ind_Home.Amb,3),'r+')
xlabel('Component 1'); ylabel('Component 2');
title('Ambulatory (2-D)')

% 3d
subplot(2,2,3); hold on;
plot3(score.Stat(ind_Lab1.Stat,1),score.Stat(ind_Lab1.Stat,2),score.Stat(ind_Lab1.Stat,3),'k+');
plot3(score.Stat(ind_Lab2.Stat,1),score.Stat(ind_Lab2.Stat,2),score.Stat(ind_Lab2.Stat,3),'b+');
plot3(score.Stat(ind_Home.Stat,1),score.Stat(ind_Home.Stat,2),score.Stat(ind_Home.Stat,3),'r+')
xlabel('Component 1'); ylabel('Component 2'); zlabel('Component 3');
title('Stationary (3-D)')

subplot(2,2,4); hold on;
plot(score.Amb(ind_Lab1.Amb,1),score.Amb(ind_Lab1.Amb,2),'k+');
plot(score.Amb(ind_Lab2.Amb,1),score.Amb(ind_Lab2.Amb,2),'b+');
plot(score.Amb(ind_Home.Amb,1),score.Amb(ind_Home.Amb,2),'r+')
xlabel('Component 1'); ylabel('Component 2'); zlabel('Component 3');
title('Ambulatory (3-D)')

%% PCA: Each Activity
[coeff.Lying,score.Lying,latent.Lying,tsquared.Lying,explained.Lying,mu.Lying] = pca(zscore(AllEnv_Lying));
[coeff.Sitting,score.Sitting,latent.Sitting,tsquared.Sitting,explained.Sitting,mu.Sitting] = pca(zscore(AllEnv_Sitting));
[coeff.Standing,score.Standing,latent.Standing,tsquared.Standing,explained.Standing,mu.Standing] = pca(zscore(AllEnv_Standing));
[coeff.Walking,score.Walking,latent.Walking,tsquared.Walking,explained.Walking,mu.Walking] = pca(zscore(AllEnv_Walking));
[coeff.Stairs,score.Stairs,latent.Stairs,tsquared.Stairs,explained.Stairs,mu.Stairs] = pca(zscore(AllEnv_Stairs));

% Subject means
for indAct=1:length(Act_All)
    % Initialize
    eval(['score.bySub.' Act_All{indAct} '=cell(length(AllFeat),length(Env),2);']);  % Each value (cell)
    eval(['score.bySub.' Act_All{indAct} 'mean=NaN*ones(length(AllFeat),length(Env),2);']);  % Mean (matrix)
    eval(['score.bySub.' Act_All{indAct} 'std=NaN*ones(length(AllFeat),length(Env),2);']);   % Std dev (matrix)
    
    for indSub=1:length(AllFeat)
        for indEnv=1:length(Env)
            eval(['A=FeatSub.' Env{indEnv} '(is' Act_All{indAct} '.' Env{indEnv} ');']);
            if ismember(indSub,A)
                % Values
                eval(['score.bySub.' Act_All{indAct} '{indSub,indEnv,1}=score.' Act_All{indAct} '(A==indSub,1);']);
                eval(['score.bySub.' Act_All{indAct} '{indSub,indEnv,2}=score.' Act_All{indAct} '(A==indSub,2);']);
                
                % Mean
                eval(['score.bySub.' Act_All{indAct} 'mean(indSub,indEnv,1)=mean( score.' Act_All{indAct} '(A==indSub,1) );']);
                eval(['score.bySub.' Act_All{indAct} 'mean(indSub,indEnv,2)=mean( score.' Act_All{indAct} '(A==indSub,2) );']);
                
                % Std
                eval(['score.bySub.' Act_All{indAct} 'std(indSub,indEnv,1)=std( score.' Act_All{indAct} '(A==indSub,1) );']);
                eval(['score.bySub.' Act_All{indAct} 'std(indSub,indEnv,2)=std( score.' Act_All{indAct} '(A==indSub,2) );']);
            end
        end
    end
end

%% Plot PCA: Activities, Each value
figure;

% Lying
subplot(2,3,1); title('Lying')
    hold on;
    plot(score.Lying(ind_Lab1.Lying,1),score.Lying(ind_Lab1.Lying,2),'k+');
    plot(score.Lying(ind_Lab2.Lying,1),score.Lying(ind_Lab2.Lying,2),'b+');
    plot(score.Lying(ind_Home.Lying,1),score.Lying(ind_Home.Lying,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');
    legend('Lab1','Lab2','Home')

% Sitting
subplot(2,3,2); title('Sitting');
    hold on;
    plot(score.Sitting(ind_Lab1.Sitting,1),score.Sitting(ind_Lab1.Sitting,2),'k+');
    plot(score.Sitting(ind_Lab2.Sitting,1),score.Sitting(ind_Lab2.Sitting,2),'b+');
    plot(score.Sitting(ind_Home.Sitting,1),score.Sitting(ind_Home.Sitting,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

% Standing
subplot(2,3,3); title('Standing')
    hold on;
    plot(score.Standing(ind_Lab1.Standing,1),score.Standing(ind_Lab1.Standing,2),'k+');
    plot(score.Standing(ind_Lab2.Standing,1),score.Standing(ind_Lab2.Standing,2),'b+');
    plot(score.Standing(ind_Home.Standing,1),score.Standing(ind_Home.Standing,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

% Walking
subplot(2,3,4); title('Walking')
    hold on;
    plot(score.Walking(ind_Lab1.Walking,1),score.Walking(ind_Lab1.Walking,2),'k+');
    plot(score.Walking(ind_Lab2.Walking,1),score.Walking(ind_Lab2.Walking,2),'b+');
    plot(score.Walking(ind_Home.Walking,1),score.Walking(ind_Home.Walking,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

% Stairs
subplot(2,3,5); title('Stairs')
    hold on;
    plot(score.Stairs(ind_Lab1.Stairs,1),score.Stairs(ind_Lab1.Stairs,2),'k+');
    plot(score.Stairs(ind_Lab2.Stairs,1),score.Stairs(ind_Lab2.Stairs,2),'b+');
    plot(score.Stairs(ind_Home.Stairs,1),score.Stairs(ind_Home.Stairs,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');
    
figure;

% Lying
subplot(2,3,1); title('Lying')
    hold on;
    plot(score.bySub.Lyingmean(:,1,1),score.bySub.Lyingmean(:,1,2),'ks','MarkerFaceColor','k','MarkerSize',8)
    plot(score.bySub.Lyingmean(:,2,1),score.bySub.Lyingmean(:,2,2),'bs','MarkerFaceColor','b','MarkerSize',8)
    plot(score.bySub.Lyingmean(:,3,1),score.bySub.Lyingmean(:,3,2),'rs','MarkerFaceColor','r','MarkerSize',8)
    legend('Lab1','Lab2','Home')

subplot(2,3,2); title('Sitting');
    hold on;
    plot(score.Sitting(ind_Lab1.Sitting,1),score.Sitting(ind_Lab1.Sitting,2),'k+');
    plot(score.Sitting(ind_Lab2.Sitting,1),score.Sitting(ind_Lab2.Sitting,2),'b+');
    plot(score.Sitting(ind_Home.Sitting,1),score.Sitting(ind_Home.Sitting,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

% Stadning
subplot(2,3,3); title('Standing')
    hold on;
    plot(score.Standing(ind_Lab1.Standing,1),score.Standing(ind_Lab1.Standing,2),'k+');
    plot(score.Standing(ind_Lab2.Standing,1),score.Standing(ind_Lab2.Standing,2),'b+');
    plot(score.Standing(ind_Home.Standing,1),score.Standing(ind_Home.Standing,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

% Walking
subplot(2,3,4); title('Walking')
    hold on;
    plot(score.Walking(ind_Lab1.Walking,1),score.Walking(ind_Lab1.Walking,2),'k+');
    plot(score.Walking(ind_Lab2.Walking,1),score.Walking(ind_Lab2.Walking,2),'b+');
    plot(score.Walking(ind_Home.Walking,1),score.Walking(ind_Home.Walking,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

% Stairs
subplot(2,3,5); title('Stairs')
    hold on;
    plot(score.Stairs(ind_Lab1.Stairs,1),score.Stairs(ind_Lab1.Stairs,2),'k+');
    plot(score.Stairs(ind_Lab2.Stairs,1),score.Stairs(ind_Lab2.Stairs,2),'b+');
    plot(score.Stairs(ind_Home.Stairs,1),score.Stairs(ind_Home.Stairs,2),'r+')
    xlabel('Component 1'); ylabel('Component 2');

%% PCA: All
% [coeff,score,latent,tsquared,explained,mu] = pca(AllEnv);
% 
% figure;
% plot3(score(Lab1_ind1:Lab1_ind2,1),score(Lab1_ind1:Lab1_ind2,2),score(Lab1_ind1:Lab1_ind2,3),'k+')
% plot3(score(Lab2_ind1:Lab2_ind2,1),score(Lab2_ind1:Lab2_ind2,2),score(Lab2_ind1:Lab2_ind2,3),'b+')
% plot3(score(Home_ind1:Home_ind2,1),score(Home_ind1:Home_ind2,2),score(Home_ind1:Home_ind2,3),'r+')
% 
% xlabel('1st Principal Component')
% ylabel('2nd Principal Component')