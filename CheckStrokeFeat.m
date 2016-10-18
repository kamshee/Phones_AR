clear all

ntrees=200;

rmvFeat=0;
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

RFModel=TreeBagger(nTrees, Feat(:, FeatInds), Label,'OOBVarImp','on');
err = RFModel.OOBPermutedVarDeltaError;
