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

for indFold=1:length(Home)
    
    if isempty(Home(indFold).Features)
        continue
    end

    Feat=[];
    Label={};

    for i=1:length(Train)
        if i==indFold; continue; end;
        Feat=[Feat; Train(i).Features];
        Label=[Label Train(i).ActivityLabel];
    end
    
    for i=1:length(Test)
        if i==indFold; continue; end;
        Feat=[Feat; Test(i).Features];
        Label=[Label Test(i).ActivityLabel];
    end

    TrainFeat=Feat;
    TrainLabel=Label.';

    TestFeat=Home(indFold).Features;
    TestLabel=Home(indFold).ActivityLabel;        
    TestLabel=TestLabel.';

    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,TestFeat);
    ConfMat{indFold}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF]);
    
    LabConfMat{indFold}=ConfMat;
    
    for i=1:length(Home)
        if i==indFold; continue; end;
        Feat=[Feat; Home(i).Features];
        Label=[Label Home(i).ActivityLabel];
    end
    
    TrainFeat=Feat;
    TrainLabel=Label.';
    
    t = templateTree('MinLeafSize',5);
    RFModel=fitensemble(TrainFeat,TrainLabel,'RUSBoost',ntrees,t,'LearnRate',0.1);
    LabelsRF = predict(RFModel,TestFeat);
    ConfMat{indFold}=confusionmat([Activities'; TestLabel], [Activities'; LabelsRF]);
    
    % reorder rows and columns if out of order
    % classes are put in order of appearence 
    
%     for Aind=1:6
%         L(Aind)=any(strcmp(Activities{Aind},unique(TestLabel)));
%         P(Aind)=any(strcmp(Activities{Aind},unique(LabelsRF)));
%     end
%     
%     P=find(P & ~L); L=find(L); 
%   
%     swaps=0;
%     for i=1:length(P)
%         for j=1:length(L)
%             if P(i)<L(j)
%                 ConfMat{indFold}=ConfMat{indFold}([1:j-1+swaps i+length(L) j+swaps:length(L)+swaps i+length(L)+1:length(P)+length(L)],[1:j-1+swaps i+length(L) j+swaps:length(L)+swaps i+length(L)+1:length(P)+length(L)]);
%                 swaps=swaps+1;
%                 break
%             end
%         end
%     end
%     
%     % Find missing classes and replace them
%     u=unique([TestLabel; LabelsRF]);
%     n_missing=zeros(1,6);
%     for uind=1:length(u)
%         n_missing(strcmp(u(uind),Activities))=1;
%     end
%     z_inds=find(~n_missing);
%     for m=z_inds
%         if m==1
%             ConfMat{indFold}=[zeros(1,size(ConfMat{indFold},2)); ConfMat{indFold}(m:end,:)];
%             ConfMat{indFold}=[zeros(size(ConfMat{indFold},1),1) ConfMat{indFold}(:,m:end)];
%         else
%             ConfMat{indFold}=[ConfMat{indFold}(1:m-1,:); zeros(1,size(ConfMat{indFold},2)); ConfMat{indFold}(m:end,:)];
%             ConfMat{indFold}=[ConfMat{indFold}(:,1:m-1) zeros(size(ConfMat{indFold},1),1) ConfMat{indFold}(:,m:end)];
%         end
%     end
    
    LabHomeConfMat{indFold}=ConfMat{indFold};
    
end

save('ConfusionMat_strokestrokeHome.mat','LabConfMat', 'LabHomeConfMat')
save('ConfusionMat_strokestrokeHome.mat','LabConfMat', 'LabHomeConfMat')

for i=1:size(ConfMat,3)
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

savefig('ConfusionMat_strokestrokeHome')
savefig('ConfusionMat_strokestrokeHome')