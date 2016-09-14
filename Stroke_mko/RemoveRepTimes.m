function SensorData = RemoveRepTimes(SensorData)
% -------------------------------------------------------------------------
% RemoveRepTimes.m

% When a timestamp is recorded more than once, this function averages the 
% sensor data in those repeated timestamps and removes the repeats.

% Input: sensor data (e.g. Acc, Gyr, Bar) with possible repeated timestamps
% Output: sensor data (e.g. Acc, Gyr, Bar) with repeated timestamps removed
% -------------------------------------------------------------------------

Repeats=find(diff(SensorData(:,1))==0);

while ~isempty(Repeats)
    for j=1:length(Repeats)
        SensorData(Repeats(j)-j+1,:)=(SensorData(Repeats(j)-j+1,:)+SensorData(Repeats(j)-j+2,:))/2;
        SensorData(Repeats(j)-j+2,:)=[];
    end

    Repeats=find(diff(SensorData(:,1))==0);
end