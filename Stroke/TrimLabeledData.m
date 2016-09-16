%% 
close all
clear all

Cliplen=100;
ClipOverlap=.5;
ax=2;
dirname='Z:\RERC- Phones\Stroke\';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};
Set={'Train' 'Test' 'Home'};
for indSet=1:length(Set)
    
    filenames=dir([dirname 'RawData\' Set{indSet} '\SortedData\Acc\*.csv']);

    for indFile=1:length(filenames)
        AccData=csvread([dirname 'RawData\' Set{indSet} '\SortedData\Acc\' filenames(indFile).name]);
        GyrData=csvread([dirname 'RawData\' Set{indSet} '\SortedData\Gyr\' filenames(indFile).name]);
        BarData=csvread([dirname 'RawData\' Set{indSet} '\SortedData\Bar\' filenames(indFile).name]);
        name=strsplit(filenames(indFile).name,'_');
        Activity=name{2};  
        ind=find(strcmp(Activity,Activities)==1);
        if isempty(ind)
            continue
        end

        numClips=(length(AccData)-(Cliplen*ClipOverlap))/(Cliplen*(1-ClipOverlap));
        numClips=floor(numClips);
        if numClips<3
            continue
        end

    %     r=.2*std(Data(:,ax));

        % Treats sedentary and ambulatory activities separately
        if ind<4
            r=.5;

            s=zeros(numClips,1);

            for i=1:numClips
                d=AccData((i-1)*Cliplen*(1-ClipOverlap)+1:(i-1)*Cliplen*(1-ClipOverlap)+Cliplen,ax);
                s(i)=SampEn(5,r,d);
            end

            [val,X]=findpeaks(s);
            rmvinds=find(val<.5);
            X(rmvinds)=[];

            X=find(s>.5);
            
            if isempty(X)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],AccData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],GyrData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],BarData)
                continue
            end
            
            bursts=diff(X)<10;
            StartInd=find(diff(bursts)==-1,1)+1;
            Start=X(StartInd)+7;
            if isempty(Start)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],AccData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],GyrData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],BarData)
                continue
            end

            EndInd=find(diff(bursts)==1,1,'last')+1;
            End=X(EndInd)-10;
            if isempty(End)
                End=X(end);
            end

            if Start>=End
                Start=1;
            end           
            
            newAccData=AccData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
            newGyrData=GyrData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
            newBarData=BarData(ceil(Start*ClipOverlap*Cliplen*6/50):floor(End*ClipOverlap*Cliplen*6/50),:);
            
%             figure; plot(newAccData);
%             dummy=1;
%             newAccData=AccData;
%             newGyrData=GyrData;
%             newBarData=BarData;

        else
            r=.5;

            s=zeros(numClips,1);

            for i=1:numClips
                d=AccData((i-1)*Cliplen*(1-ClipOverlap)+1:(i-1)*Cliplen*(1-ClipOverlap)+Cliplen,ax);

                s(i)=SampEn(5,r,d);
            end
            
            
%             [val,X]=findpeaks(s);
%             rmvinds=find(val<.5);
%             X(rmvinds)=[];

            X=find(s>.5);

            if isempty(X)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],AccData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],GyrData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],BarData)
                continue
            end
            bursts=diff(X)<7;
            StartInd=find(bursts==0,1);
            if isempty(StartInd)
                StartInd=1;
            end
            Start=X(StartInd)+4;

    %         EndInd=find(bursts==0,1,'last');
    %         if isempty(EndInd) || EndInd<StartInd+1
    %             EndInd=length(X);
    %         end
    %         End=X(EndInd);
            EndInd=find(diff(bursts)==1,1,'last')+1;
            if isempty(EndInd)
                End=X(end);
            else
                End=X(EndInd)-2;
            end
           
            if Start>=End
                Start=1;
            end

            newAccData=AccData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
            newGyrData=GyrData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
            newBarData=BarData(ceil(Start*ClipOverlap*Cliplen*6/50):floor(End*ClipOverlap*Cliplen*6/50),:);
%             figure; plot(newAccData);
%             dummy=1;
        end
        csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],newAccData)
        csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],newGyrData)
        csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],newBarData)
    end
end
