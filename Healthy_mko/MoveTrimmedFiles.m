dirname='Z:/RERC- Phones/Server Data/TrimmedData/badsub/';

Subs=dir([dirname '3*']);
Subs={Subs(:).name};

Sensors={'Acc', 'Gyr', 'Bar'};

for indSens=1:length(Sensors)
    filenames=dir([dirname Sensors{indSens} '/3*']);
    for indFile=1:length(filenames)
        fileparts=strsplit(filenames(indFile).name,'_');
        Subj=fileparts{1};
        Activity=fileparts{2};
        Index=fileparts{3}(1:end-4);
        
        newdir=[dirname Subj '/' Activity '/' Sensors{indSens} '/'];
        if ~exist(newdir,'dir')
            mkdir(newdir)
        end
        
        copyfile([dirname Sensors{indSens} '/' filenames(indFile).name],...
            [newdir Sensors{indSens} '_' Index '.csv']);
    end
end
