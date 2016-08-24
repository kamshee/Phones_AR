close all

dirname = 'Z:\RERC- Phones\Server Data\Sensor_Data_V2' ;
filenames = dir(dirname);
filenames(1:2) = [];
%remove files with 0 bytes
emptyfiles = cellfun(@(x) x==0, {filenames.bytes});
filenames(emptyfiles) = [];
AllFilenames=filenames;

Subjects=zeros(length(filenames),1);


for i=1:length(filenames)
    Subjects(i)=str2double(filenames(i).name(1:15));
end

Rates=zeros(length(filenames),3);

IDs=num2str(unique(Subjects));
% IDs='356420050076868';
Activities={'Sitting', 'Lying', 'Standing', 'Stairs Up', 'Stairs Down', 'Walking'};

%% Split files by subject

[sy, sx]=size(IDs);

AllRates=[];

for indSub=1:sy
    filenames=AllFilenames;
    ID=IDs(indSub,:);
    OtherSubjectFiles = cellfun(@(x) ~strcmp(x(1:15),ID), {filenames.name});
    filenames(OtherSubjectFiles) = [];
    SubjectFilenames=filenames;
    
    
    if ~exist(['Z:\RERC- Phones\Server Data\DataByDate\' ID], 'dir')
        mkdir(['Z:\RERC- Phones\Server Data\DataByDate\' ID])
    end

    %% Split by Activity (skip sit-to-stand stand-to-sit, Wheeling)

    ActRates=[];
    
    for indAct=1:length(Activities)

        Activity=Activities{indAct};

        filenames=SubjectFilenames;
        OtherActivityFiles = cellfun(@(x) ~strcmp(x(17:16+length(Activity)),Activity), {filenames.name});
        filenames(OtherActivityFiles) = [];

        if ~exist(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\' Activity], 'dir')
            mkdir(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\' Activity])
        end

        %% Read File and Separate Data by Sensor

        if ~exist(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Acc'], 'dir')
            mkdir(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Acc'])
        end

        if ~exist(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Gyr'], 'dir')
            mkdir(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Gyr'])
        end

        if ~exist(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Bar'], 'dir')
            mkdir(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Bar'])
        end

        SampleRates=zeros(length(filenames),3);
        
        parfor indFile=1:length(filenames)

            Num=filenames(indFile).name(18+length(Activity):end-4);

            fid=fopen([dirname '\' filenames(indFile).name],'rt');
            A=textscan(fid,'','Delimiter',['|' ',']);
            fclose(fid);

            %%
            temp=sort(A{4});
            tStart=temp(1);
            Date=datetime([1970,1,1,0,0,tStart/1000]);
            Date=datestr(Date,'mm-dd-yy');
             
            Acc=zeros(length(find(A{3}==105)),5);
            Gyr=zeros(length(find(A{3}==115)),5);
            Bar=zeros(length(find(A{3}==135)),2);

            AccInd=1;
            GyrInd=1;
            BarInd=1;
            
            for i=1:length(A{2})
                t=A{4}(i)-tStart;
                indSensor=A{3}(i);
                if indSensor==105
                    Acc(AccInd,:)=[t A{5}(i) A{6}(i) A{7}(i) A{8}(i)];
                    AccInd=AccInd+1;
                elseif indSensor==115
                    Gyr(GyrInd,:)=[t A{5}(i) A{6}(i) A{7}(i) A{8}(i)];
                    GyrInd=GyrInd+1;
                elseif indSensor==135
                    Bar(BarInd,:)=[t A{5}(i)];
                    BarInd=BarInd+1;
                end
            end

            %% Sort to put in chronological order
            
            Acc=sortrows(Acc);
            Gyr=sortrows(Gyr);
            Bar=sortrows(Bar);
            
            %% Remove Data When not all three sensors are recording
            maxInd=min([max(Acc(:,1)) max(Bar(:,1)) max(Gyr(:,1))]);
            minInd=max([min(Acc(:,1)) min(Bar(:,1)) min(Gyr(:,1))]);
            stopInd=find(Acc(:,1)>maxInd,1);
            
            Repeats=find(diff(Acc(:,1))==0);

            while ~isempty(Repeats)
                for j=1:length(Repeats)
                    Acc(Repeats(j)-j+1,:)=(Acc(Repeats(j)-j+1,:)+Acc(Repeats(j)-j+2,:))/2;
                    Acc(Repeats(j)-j+2,:)=[];
                end

                Repeats=find(diff(Acc(:,1))==0);
            end

            Repeats=find(diff(Gyr(:,1))==0);

            while ~isempty(Repeats)
                for j=1:length(Repeats)
                    Gyr(Repeats(j)-j+1,:)=(Gyr(Repeats(j)-j+1,:)+Gyr(Repeats(j)-j+2,:))/2;
                    Gyr(Repeats(j)-j+2,:)=[];
                end

                Repeats=find(diff(Gyr(:,1))==0);
            end
            
            Repeats=find(diff(Bar(:,1))==0);

            while ~isempty(Repeats)
                for j=1:length(Repeats)
                    Bar(Repeats(j)-j+1,:)=(Bar(Repeats(j)-j+1,:)+Bar(Repeats(j)-j+2,:))/2;
                    Bar(Repeats(j)-j+2,:)=[];
                end

                Repeats=find(diff(Bar(:,1))==0);
            end
            
            t=minInd:1000/50:maxInd;
            t_bar=minInd:1000/6:maxInd;
            
            Acc=[t; spline(Acc(:,1).',Acc(:,2:4).',t)].';
            Gyr=[t; spline(Gyr(:,1).',Gyr(:,2:4).',t)].';
            Bar=[t_bar; spline(Bar(:,1).',Bar(:,2).',t_bar)].';
            
            %% Save Files
            dlmwrite(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Acc\' Date '_' Activity '_' Num '.csv'], Acc, 'Precision', 7)
            dlmwrite(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Gyr\' Date '_' Activity '_' Num '.csv'], Gyr, 'Precision', 7)
            dlmwrite(['Z:\RERC- Phones\Server Data\DataByDate\' ID '\Bar\' Date '_' Activity '_' Num '.csv'], Bar, 'Precision', 7)
            
        end       
    end
end