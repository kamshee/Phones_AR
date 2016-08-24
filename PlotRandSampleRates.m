close all
dirname = 'Z:\RERC- Phones\Server Data\Sorted Data' ;

filenames=rdir([dirname '\**\*.csv']);
X=rand(1,length(filenames));

for i=1:length(filenames)
    if X(i)<.01
        SensorData=readtable(filenames(i).name);
        SensorData=cell2mat(table2cell(SensorData));
        
        figure; hist(diff(SensorData(:,1)),100)
        names=textscan(filenames(i).name(41:end-4),'%s %s %s %s','Delimiter','\');
        title(strcat(names{1}, {'\\'}, names{2}, {'\\'}, names{3}, {'\\'}, names{4}))
    else
        continue
    end
end