%% 
close all
clear all

Cliplen=100;
ClipOverlap=.5;
ax=3;
dirname='Z:\RERC- Phones\Server Data\DataByDate\';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};
    
ACCfilenames=rdir([dirname '3*\Acc\*.csv']);
GYRfilenames=rdir([dirname '3*\Gyr\*.csv']);
BARfilenames=rdir([dirname '3*\Bar\*.csv']);

for indFile=1:length(ACCfilenames)
    AccData=csvread(ACCfilenames(indFile).name);
    GyrData=csvread(GYRfilenames(indFile).name);
    BarData=csvread(BARfilenames(indFile).name);
    name=strsplit(ACCfilenames(indFile).name(length(dirname)+1:end),{'\' '.' '_'});
    Activity=name{4};
    Subject=name{1};
    Date=name{3};
    Num=name{5};
    
    if ~exist([dirname 'TrimmedData\Acc\' Subject '\' Date],'dir')
        mkdir([dirname 'TrimmedData\Acc\' Subject '\' Date])
    end
    if ~exist([dirname 'TrimmedData\Gyr\' Subject '\' Date],'dir')
        mkdir([dirname 'TrimmedData\Gyr\' Subject '\' Date])
    end
    if ~exist([dirname 'TrimmedData\Bar\' Subject '\' Date],'dir')
        mkdir([dirname 'TrimmedData\Bar\' Subject '\' Date])
    end
    
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
            csvwrite([dirname 'TrimmedData\Acc\' Subject '\' Date '\' Activity '_' Num '.csv'],AccData)
            csvwrite([dirname 'TrimmedData\Gyr\' Subject '\' Date '\' Activity '_' Num '.csv'],GyrData)
            csvwrite([dirname 'TrimmedData\Bar\' Subject '\' Date '\' Activity '_' Num '.csv'],BarData)
            continue
        end

        bursts=diff(X)<10;
        StartInd=find(diff(bursts)==-1,1)+1;
        Start=X(StartInd)+7;
        if isempty(Start)
            csvwrite([dirname 'TrimmedData\Acc\' Subject '\' Date '\' Activity '_' Num '.csv'],AccData)
            csvwrite([dirname 'TrimmedData\Gyr\' Subject '\' Date '\' Activity '_' Num '.csv'],GyrData)
            csvwrite([dirname 'TrimmedData\Bar\' Subject '\' Date '\' Activity '_' Num '.csv'],BarData)
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

        tbar=AccData(Start*ClipOverlap*Cliplen,1):1000/6:AccData(End*ClipOverlap*Cliplen,1);
        
        newAccData=AccData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
        newGyrData=GyrData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
        newBarData=[tbar.' spline(BarData(:,1).',BarData(:,2:end),tbar).'];
%         BarData(ceil(Start*ClipOverlap*Cliplen*6/50):floor(End*ClipOverlap*Cliplen*6/50),:);

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
            csvwrite([dirname 'TrimmedData\Acc\' Subject '\' Date '\' Activity '_' Num '.csv'],AccData)
            csvwrite([dirname 'TrimmedData\Gyr\' Subject '\' Date '\' Activity '_' Num '.csv'],GyrData)
            csvwrite([dirname 'TrimmedData\Bar\' Subject '\' Date '\' Activity '_' Num '.csv'],BarData)
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
    csvwrite([dirname 'TrimmedData\Acc\' Subject '\' Date '\' Activity '_' Num '.csv'],newAccData)
    csvwrite([dirname 'TrimmedData\Gyr\' Subject '\' Date '\' Activity '_' Num '.csv'],newGyrData)
    csvwrite([dirname 'TrimmedData\Bar\' Subject '\' Date '\' Activity '_' Num '.csv'],newBarData)
end
