%% GenerateClips
% Generates clips from phone data
% Run after GenerateRawData.m

% TODO: Add Features for barometer data

clear all

AccGyrFeat=131; % Number of features for Acc and Gyr
BarFeat=5; % Number of features for Bar

dirname='Z:\RERC- Phones\Server Data\DataByDate\Raw Data\';
savedirname='Z:\RERC- Phones\Server Data\DataByDate\Clips\';

clipDur=3; % Clip length in s
clipOverlap=.5; % Percent overlap of clips

filenames=dir('Z:\RERC- Phones\Server Data\DataByDate\');
NotDirectories=cellfun(@(x) x==0, {filenames.isdir});
filenames(NotDirectories)=[];
filenames=filenames(cellfun(@(x) strcmp(x(1),'3'), {filenames.name}));
Subjects={filenames.name};

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
% Activities={'Sitting', 'Lying', 'Standing', 'Walking'};
% Sensors={'Acc'};
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
        
        Dates=dir([dirname 'ACC\' Subject]);
        NotDir=cellfun(@(x) x==0,{Dates.isdir});
        Dates(NotDir)=[];
        Dates(1:2)=[];

        for indDates=1:length(Dates)
            Date=Dates(indDates).name;
        
        for indSens=1:length(Sensors)
                 
            Sensor=Sensors{indSens};
            Fs=Fss(indSens);
            clipLength=clipDur*Fs;
            overlapLength=ceil(clipLength*clipOverlap);
                
            % Read Raw data
            SensorData=readtable([dirname Sensor '\' Subject '\' Date '\' Activity '_RAW.csv'],'ReadVariableNames',false);
            SensorData=cell2mat(table2cell(SensorData));
            
            if indSens==1
                numClips=floor((length(SensorData)-overlapLength)/(clipLength-overlapLength));
                feat=zeros(numClips,AccGyrFeat*2+BarFeat);
            end
            
            % Pre-allocate clips data
            if strcmp(Sensor, 'Bar')
                clipData=zeros(clipLength,1,numClips);
            else
                clipData=zeros(clipLength,3,numClips);
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
            end
            % Stores Clip Data with other data from the same sensor and
            % subject
            if indSens==1
                AccData=clipData;
            elseif indSens==2
                GyrData=clipData;
            elseif indSens==3
                BarData=clipData;
            end
            
        end
            if ~exist([savedirname Subject '\' Date],'dir')
                mkdir([savedirname Subject '\' Date])
            end

            parsave([savedirname Subject '\' Date '\' Activity '_Clips.mat'],AccData,GyrData,BarData,feat)
%             save([savedirname Subject '\' Date '\PhoneData_Feat.mat'],'AllFeat', '-v7.3')
        end
        SubjFeat=[SubjFeat; feat];
    end
end