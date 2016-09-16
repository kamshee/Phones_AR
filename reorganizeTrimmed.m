

dirname = ['Z:\RERC- Phones\Server Data\TrimmedData\badsub\'];

sensors={'Acc','Gyr','Bar'};
Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'}; %(skip sit-to-stand stand-to-sit, Wheeling)

for indSensor=1:length(sensors)
    

    filenames = dir([dirname sensors{indSensor} '\*.csv']);
    
    for indFile=1:length(filenames)
        fileparts=strsplit(filenames(indFile).name,'_');
        sub=fileparts{1};
        act=fileparts{2};
        trial=fileparts{3}(1:end-4);
        
        savefile=[sensors{indSensor} '_' trial '.csv'];
        savedir=[dirname sub '\' act '\' sensors{indSensor} '\'];
            
        if ~exist(savedir)
            mkdir(savedir);
        end
        %fprintf('%s \n',[savedir savefile])
        copyfile([dirname sensors{indSensor} '\' filenames(indFile).name],[savedir savefile]);
            

    end
end