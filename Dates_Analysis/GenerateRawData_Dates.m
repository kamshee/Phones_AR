%% Create Raw Data Files for RERC Phone Data
% Run after PreprocessFiles.m
% Starting with Acc only
% Creates .csv files containing 
clear all
close all

dirname = 'Z:\RERC- Phones\Server Data\DataByDate\TrimmedData\';
    
%% Search Directory for Subject Directories and Save the Subject IDs in Array
filenames=dir([dirname 'Acc']);
NotDirectories=cellfun(@(x) x==0, {filenames.isdir});
filenames(NotDirectories)=[];
filenames=filenames(cellfun(@(x) strcmp(x(1),'3'), {filenames.name}));
Subjects={filenames.name};

Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
% Sensors={'Bar'};
% Fss=6;
Sensors={'Acc', 'Gyr', 'Bar'};
Fss=[50,50,6];
% Use parfor at subject level to improve speed
for indSens=1:length(Sensors)
    Sensor=Sensors{indSens};
    Fs=Fss(indSens);
    parfor indSub=1:length(Subjects)
        Subject=Subjects{indSub};
        for indAct=1:length(Activities)
            Activity=Activities{indAct};
            Dates=dir([dirname Sensor '\' Subject]);
            NotDir=cellfun(@(x) x==0,{Dates.isdir});
            Dates(NotDir)=[];
            Dates(1:2)=[];
            for indDate=1:length(Dates)
                Date=Dates(indDate).name;
                %% Sort files in ascending order of size to optimize
                % Also removes files above a certain size (CHANGE LATER)
                filenames=dir([dirname Sensor '\' Subject '\' Date '\' Activity '*.csv']);
                LargeFiles=[filenames(:).bytes]>50000000;
                filenames(LargeFiles)=[];

                S=[filenames(:).bytes];
                [~,Sind]=sort(S);

                filenames=filenames(Sind);

                SensorRaw=[];

                for i=1:length(filenames)
                    SensorData=readtable([dirname Sensor '\' Subject '\' Date '\' filenames(i).name],'ReadVariableNames',false);
                    SensorData=cell2mat(table2cell(SensorData));

%                     SensorData(:,1)=SensorData(:,1)-SensorData(1,1);

                    %% Average and remove duplicate timestamps
%                     Repeats=find(diff(SensorData(:,1))==0);
% 
%                     while ~isempty(Repeats)
%                         for j=1:length(Repeats)
%                             SensorData(Repeats(j)-j+1,:)=(SensorData(Repeats(j)-j+1,:)+SensorData(Repeats(j)-j+2,:))/2;
%                             SensorData(Repeats(j)-j+2,:)=[];
%                         end
% 
%                         Repeats=find(diff(SensorData(:,1))==0);
%                     end
% 
%                     %% ReSample at 50 Hz
% 
%                     tEnd=max(SensorData(:,1));
% 
%                     t=0:1/Fs:tEnd/1000;
%                     if strcmp(Sensor,'Bar')
%                         SensorData=spline((SensorData(:,1).')./1000,SensorData(:,2).',t);
%                     else
%                         SensorData=spline((SensorData(:,1).')./1000,SensorData(:,2:end).',t);
%                     end
%                     SensorData=SensorData.';

                    %% Combine data from same activity
                    SensorRaw=[SensorRaw; SensorData(:,2:end)];
                end

                if ~exist(['Z:\RERC- Phones\Server Data\DataByDate\Raw Data\' Sensor '\' Subject '\' Date],'dir')
                    mkdir(['Z:\RERC- Phones\Server Data\DataByDate\Raw Data\' Sensor '\' Subject '\' Date])
                end

                dlmwrite(['Z:\RERC- Phones\Server Data\DataByDate\Raw Data\' Sensor '\' Subject '\' Date '\' Activity '_RAW.csv'],SensorRaw,'Precision', 7)
            end
        end
    end
end