%% Create Raw Data Files for RERC Phone Data
% Run after PreprocessFiles.m
% Starting with Acc only
% Creates .csv files containing 
clear all
close all

Set={'Train' 'Test' 'Home'};
for indSet=1:length(Set)

dirname = ['Z:\RERC- Phones\Stroke\TrimmedData\' Set{indSet} '\Updated_mko\'];
WindowSize=0; %Length in s of window around data


%% Search Directory for Subject Directories and Save the Subject IDs in Array
Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};
Sensors={'Acc', 'Gyr', 'Bar'};
Fss=[50,50,6];
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

% Use parfor at subject level to improve speed
for indSens=1:length(Sensors)
    Sensor=Sensors{indSens};
    Fs=Fss(indSens);
    WindowSamples=WindowSize*Fs;
    
    parfor indSub=1:length(Subjects)
        Subject=Subjects{indSub};
        for indAct=1:length(Activities)
            Activity=Activities{indAct};

            filenames=dir([dirname Sensor '\' Subject '_' Activity '*.csv']);

            SensorRaw=[];

            for i=1:length(filenames)
                SensorData=readtable([dirname Sensor '\' filenames(i).name],'ReadVariableNames',false);
                SensorData=cell2mat(table2cell(SensorData));

                if ~any(SensorData)
                    continue
                end
                SensorData(:,1)=SensorData(:,1)-SensorData(1,1);

                %% Combine data from same activity
                SensorRaw=[SensorRaw; SensorData(WindowSamples+1:end-WindowSamples,:)];
            end

            dlmwrite(['Z:\RERC- Phones\Stroke\FinishedData\' Set{indSet} '\' Sensor '\' Subject '_' Activity '_RAW.csv'],SensorRaw,'Precision', 7)
        end
    end
end
end