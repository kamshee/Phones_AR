function [newAccData,newGyrData,newBarData] = TrimData(Activity,AccData,GyrData,BarData,newStart,newEnd)
% -------------------------------------------------------------------------
% TrimData.m

% Trims sensor data to activity only. Removes movement bursts during 
% labeling (pre- and post- activity, i.e. when tapping on the phone and
% putting it away) using sample entropy. Treats sedentary and ambulatory
% activities separately.

% Input: activity, all sensor data (Acc, Gyr, Bar)
% Output: all sensor data, trimmed
% -------------------------------------------------------------------------

Cliplen=80;
ClipOverlap=.5;
datacol=2;
axes=[1:3];

numClips=(length(AccData)-(Cliplen*ClipOverlap))/(Cliplen*(1-ClipOverlap));
numClips=floor(numClips);

if ~isempty(newStart) && ~isempty(newEnd)
    Start=newStart; End=newEnd;
    newAccData=AccData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
    newGyrData=GyrData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
    newBarData=BarData(ceil(Start*ClipOverlap*Cliplen*6/50):floor(End*ClipOverlap*Cliplen*6/50),:);
    return
end


if numClips<=8
    % Change in future: if not enough clips, just return w/o saving
    newAccData=zeros(size(AccData));
    newGyrData=zeros(size(GyrData));
    newBarData=zeros(size(BarData));
    return
end

% SEDENTARY ACTIVITIES
if strcmp(Activity,'Lying') || strcmp(Activity,'Sitting') || strcmp(Activity,'Standing')
    cutOffShort=4;
    cutOffLong=20;
    
    r=.6;

    S=zeros(numClips,length(axes));

    for ax=axes
        for i=1:numClips
            d(:,ax)=AccData((i-1)*Cliplen*(1-ClipOverlap)+1:(i-1)*Cliplen*(1-ClipOverlap)+Cliplen,datacol+ax-1);
            S(i,ax)=SampEn(5,r,d(:,ax));
        end
    end
    s=nanmean(S,2);  % average entropy across three axes (not using nanmean b/c NaNs from any accel is important)

    [val,X]=findpeaks(s);
    X(val<0.5)=[];  % remove indices with peaks < 0.5

    X=find(s>.25);

    if isempty(X) || length(X)<2
        newAccData=AccData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],AccData)
        newGyrData=GyrData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],GyrData)
        newBarData=BarData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],BarData)
        return
    end

    if strcmp(Activity,'Lying')
        cutOff=cutOffLong;
    else
        cutOff=cutOffShort;
    end
    
    bursts=diff(X)<20;
    
    if X(end)<0.33*numClips
        Start=X(end)+cutOffShort;
        End=numClips-cutOffLong;
    elseif X(1)>0.66*numClips
        Start=1+cutOffLong;
        End=X(1)-cutOffShort;
    else
    
        StartInd=find(diff(bursts)==-1,1,'last')+1;
        Start=X(StartInd)+cutOff;
        if isempty(Start)
            Start=1;
            %newAccData=AccData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],AccData)
            %newGyrData=GyrData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],GyrData)
            %newBarData=BarData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],BarData)
            %return
        end

        EndInd=find(diff(bursts)==1,1,'last')+1;
        End=X(EndInd)-cutOff;
        if isempty(End)
            End=X(end)-10;
        end      
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

% AMBULATORY ACTIVITIES
else

    cutOffShort=2;
    cutOffLong=5;
    
    r=.7;

    cutOff=cutOffShort;
    
    s=zeros(numClips,1);

    for ax=axes
        for i=1:numClips
            d(:,ax)=AccData((i-1)*Cliplen*(1-ClipOverlap)+1:(i-1)*Cliplen*(1-ClipOverlap)+Cliplen,datacol+ax-1);
            S(i,ax)=SampEn(5,r,d(:,ax));
        end
    end
    s=nanmean(S,2);  % average entropy across three axes (not using nanmean b/c NaNs from any accel is important)


%             [val,X]=findpeaks(s);
%             rmvinds=find(val<.5);
%             X(rmvinds)=[];

    X=find(s<0.15 | s>.4);

        
        
    if isempty(X)
        newAccData=AccData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Acc\' filenames(indFile).name],AccData)
        newGyrData=GyrData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Gyr\' filenames(indFile).name],GyrData)
        newBarData=BarData; %csvwrite([dirname 'TrimmedData\' Set{indSet} '\Bar\' filenames(indFile).name],BarData)
        return
    end
    bursts=diff(X)<7;
    
    if X(end)<0.33*numClips
        Start=X(end)+cutOffShort;
        End=numClips-cutOffLong;
    elseif X(1)>0.66*numClips
        Start=1+cutOffLong;
        End=X(1)-cutOffShort;
    else
        StartInd=find(bursts==0,1);
        if isempty(StartInd)
            StartInd=1;
        end
        Start=X(StartInd)+cutOffShort;


    % %         EndInd=find(bursts==0,1,'last');
    % %         if isempty(EndInd) || EndInd<StartInd+1
    % %             EndInd=length(X);
    % %         end
    % %         End=X(EndInd);
    % 
        EndInd=find(diff(bursts)==1,1,'last')+1;
        if isempty(EndInd)
            End=X(end)-cutOffShort;
        else
            End=X(EndInd);
        end
    end

    if Start>=End
        Start=1;
        %End=numClips-cutOffLong;
    end

    newAccData=AccData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
    newGyrData=GyrData(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
    newBarData=BarData(ceil(Start*ClipOverlap*Cliplen*6/50):floor(End*ClipOverlap*Cliplen*6/50),:);
    
%             figure; plot(newAccData);
%             dummy=1;
end