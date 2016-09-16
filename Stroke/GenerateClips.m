%% GenerateClips
% Generates clips from phone data
% Run after GenerateRawData.m

% TODO: Add Features for barometer data

clear all

AccGyrFeat=131; % Number of features for Acc and Gyr
BarFeat=5; % Number of features for Bar

dirname='Z:\RERC- Phones\Stroke\FinishedData\Home\';
savedirname='Z:\RERC- Phones\Stroke\Clips\Home';

clipDur=5; % Clip length in s
clipOverlap=.5; % Percent overlap of clips

Subjects=1:30;

for i=1:length(Subjects)
    val=num2str(Subjects(i));
    if length(val)==1
        temp{i}=['CS00' val];
    else
        temp{i}=['CS0' val];
    end
end
Subjects=temp;

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
Sensors={'Acc', 'Gyr', 'Bar'};
Fss=[50, 50, 6]; % Sample Rates for each sensor

% Preallocate Structures for clips and features
% Improves speed and allows for parfor loop
AllClips=struct('SubjID', '',  'ActivityLabel', Subjects, 'Acc', [], ...
    'Gyr', [], 'Bar', [], 'SamplingT', 20, 'ClipDur', clipDur, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
AllFeat=struct('SubjID', '',  'ActivityLabel', Subjects, 'Features', [], ...
        'SamplingT', 20, 'ClipDur', clipDur, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);   


parfor indSub=1:length(Subjects)
    Subject=Subjects{indSub};
    Label={};
    SubjFeat=[];
    AccData=[];
    GyrData=[];
    BarData=[];
    for indAct=1:length(Activities)
        Activity=Activities{indAct};
  
        for i=1:length(Sensors)
            
            Sensor=Sensors{i};
            Fs=Fss(i);
            clipLength=clipDur*Fs;
            overlapLength=ceil(clipLength*clipOverlap); 
            % Read Raw data
            SensorData=readtable([dirname Sensor '\' Subject '_' Activity '_RAW.csv'],'ReadVariableNames',false);
            SensorData=cell2mat(table2cell(SensorData));

            % Pre-allocate clips data
            numClips(i)=floor((length(SensorData)-overlapLength)/(clipLength-overlapLength));
        end

        numClips=min(numClips);
        
        
        for indSens=1:length(Sensors)
            
            Sensor=Sensors{indSens};
            Fs=Fss(indSens);
            clipLength=clipDur*Fs;
            overlapLength=ceil(clipLength*clipOverlap);
                
            % Read Raw data
            SensorData=readtable([dirname '\' Sensor '\' Subject '_' Activity '_RAW.csv'], 'ReadVariableName',false);
            SensorData=cell2mat(table2cell(SensorData));

            % Pre-allocate clips data
            if strcmp(Sensor, 'Bar')
                clipData=zeros(clipLength,1,numClips);
            else
                clipData=zeros(clipLength,3,numClips);
            end

            if indSens==1
                feat=zeros(numClips,AccGyrFeat*2+BarFeat);
            end
            
            % Store clips along z dimension of clipData
            for i=1:numClips
                startInd=(i-1)*(clipLength-overlapLength);
                clipData(:,:,i)=SensorData(startInd+1:startInd+clipLength,:);

                if ~strcmp(Sensors(indSens),'Bar')
                    [featV, ~]=getFeatures(clipData(:,:,i).');
                    feat(i,(indSens-1)*AccGyrFeat+1:indSens*AccGyrFeat)=featV;
                else
                    [featV, ~]=getBarFeatures(clipData(:,:,i).');
                    feat(i, (indSens-1)*AccGyrFeat+1:(indSens-1)*AccGyrFeat+BarFeat)=featV;
                end
                if indSens==1;
                    Label{end+1}=Activity;
                end
            end
            % Stores Clip Data with other data from the same sensor and
            % subject
            if indSens==1
                [~,~,sz]=size(AccData);
                if sz==1
                    sz=0;
                end
                AccData(:,:,sz+1:sz+numClips)=clipData;
            elseif indSens==2
                [~,~,sz]=size(GyrData);
                if sz==1
                    sz=0;
                end
                GyrData(:,:,sz+1:sz+numClips)=clipData;
            elseif indSens==3
                [~,~,sz]=size(BarData);
                if sz==1
                    sz=0;
                end
                BarData(:,:,sz+1:sz+numClips)=clipData;
            end
        end
        SubjFeat=[SubjFeat; feat];
    end
    
    SubjClips=struct('SubjID', Subject,  'ActivityLabel', {Label}, 'Acc', AccData, ...
        'Gyr', GyrData, 'Bar', BarData, 'SamplingT', 20, 'ClipDur', clipDur, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    SubjFeatures=struct('SubjID', Subject,  'ActivityLabel', {Label}, 'Features', SubjFeat, ...
        'SamplingT', 20, 'ClipDur', clipDur, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);    

    AllClips(indSub)=SubjClips;
    AllFeat(indSub)=SubjFeatures;
end
save([savedirname '_Clips.mat'],'AllClips', '-v7.3')
save([savedirname '_Feat.mat'],'AllFeat', '-v7.3')