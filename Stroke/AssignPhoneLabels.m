%% Takes RAW Phone Data from CIMON and Assigns it to subject and group
% Train (Day 1 Lab), Test (Day 2 Lab), Home

clear all

load('Z:\Stroke MC10\Sessions.mat')

filenames=dir('Z:\RERC- Phones\Stroke\RawData\*.csv');

Labels=table2cell(readtable('Z:\RERC- Phones\Stroke\Labels_stroke.csv','ReadVariableNames',false));

for indFile=1:length(filenames)
    name=filenames(indFile).name;
    temp=strsplit(name,{'_' '.'});
    ID=str2double(temp{1});
    Index=str2double(temp{3});
    if Index<71
        continue
    end
    
    Match=Subject_IDs(find(ID==cell2mat(Subject_IDs(:,4))),:);
    if isempty(Match)
        continue
    end
    
    StartUTC=Labels{Index,3};
    StartTime=datetime([1970, 1, 1, 0, 0, StartUTC/1000]);
    
    indM=1;
    stop=0;
    while (StartTime<Match{indM,2} || StartTime>Match{indM,6}) && ~stop
        indM=indM+1;
        if indM>size(Match,1)
            stop=1;
            indM=indM-1;
        end
    end
    
    if stop
        movefile(['Z:\RERC- Phones\Stroke\RawData\' filenames(indFile).name], ...
            ['Z:\RERC- Phones\Stroke\RawData\Other\' filenames(indFile).name])
        continue
    end
    
    Subj=Match{indM,1};
    if StartTime>Match{indM,2} && StartTime<Match{indM,3}
        Group='Train';
    elseif StartTime>Match{indM,5} && StartTime<Match{indM,6}
        Group='Test';
    else
        Group='Home';
    end
    
    movefile(['Z:\RERC- Phones\Stroke\RawData\' filenames(indFile).name], ...
            ['Z:\RERC- Phones\Stroke\RawData\' Group '\' Subj '_' temp{2} '_' temp{3} '.csv'])
end
            
