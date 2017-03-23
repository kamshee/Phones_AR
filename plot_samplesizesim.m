
figure; hold on;
xlabel('# Test Subjects'); ylabel('Avg. Bal Acc');

% Healthy to Healthy
load('C:\Users\mobrien\Documents\GitHub\Phones_AR\ssBalAcc_HealthyHealthy.mat');
plot(1:size(BalAcc,1),mean(BalAcc,2),'k-')

% Healthy to Stroke (All)
load('C:\Users\mobrien\Documents\GitHub\Phones_AR\ssBalAcc_HealthyStroke_All.mat');
plot(1:size(BalAcc,1),mean(BalAcc,2),'c-')

% Healthy to Stroke (By Severity)
load('C:\Users\mobrien\Documents\GitHub\Phones_AR\ssBalAcc_bySev.mat');
plot(1:size(BalAcc_Mild,1),mean(BalAcc_Mild,2),'g-')
plot(1:size(BalAcc_Mod,1),mean(BalAcc_Mod,2),'y-')
plot(1:size(BalAcc_Sev,1),mean(BalAcc_Sev,2),'r-')

% Stroke to Stroke
load('C:\Users\mobrien\Documents\GitHub\Phones_AR\ssBalAcc_StrokeStroke.mat');
plot(1:size(BalAcc,1),mean(BalAcc,2),'b-')

legend('H->H','H->S (All)','H->Mild','H->Mod','H->Sev','S-S')