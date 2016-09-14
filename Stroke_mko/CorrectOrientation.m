function [newAccData,newGyrData] = CorrectOrientation(AccData,GyrData)
% -------------------------------------------------------------------------
% CorrectOrientation.m

% Uses a quaternion-based rotation matrix from axis-angle pair to reorient
% phone's frame of reference (so y-axis is along gravity vector).

% Cite: Tundo MD, Lemaire E, Baddour N. Correcting smartphone orientation 
% for accelerometer-based analysis. In: IEEE International Symposium on 
% Medical Measurements and Applications Proceedings (MeMeA), 2013. p.
% 58-62.

% Input: all sensor data (Acc, Gyr), trimmed to labeled activity
% Output: all sensor data, rotated
% Sensor data format is [time,x,y,z]
% -------------------------------------------------------------------------

% Initial gravity vector Vi is averaged sampling of x, y, z accelerometer 
% data. Note: Tundo et al. use 10 second window of user standing still.
Vi = mean(AccData(:,2:4),1);

% Desired final gravity vector is oriented with y-axis.
Vf = [0,9.81,0];

% --- AXIS-ANGLE PAIR ---
% axis vector = cross product between initial and final vector
A = cross(Vi,Vf);

% Normalize axis by magnitude
Anorm = [-( Vi(3)/sqrt(Vi(1)*Vi(1)+Vi(3)*Vi(3)) ), ...
    0, ...
    ( Vi(1)/sqrt(Vi(1)*Vi(1)+Vi(3)*Vi(3)) ) ];

% angle between vectors = cosine angle from dot product
alpha = acos( Vi(2)/sqrt(Vi(1)*Vi(1) + Vi(2)*Vi(2) + Vi(3)*Vi(3)) );

% --- QUATERNION ROTATION ---
q0=cos(0.5*alpha);
q1=sin(0.5*alpha)*Anorm(1);
q2=sin(0.5*alpha)*Anorm(2);
q3=sin(0.5*alpha)*Anorm(3);

R = [1-2*(q2*q2+q3*q3) 2*(q1*q2-q0*q3) 2*(q0*q2+q1*q3); ...
    2*(q1*q2+q0*q3) 1-2*(q1*q1+q3*q3) 2*(q2*q3-q0*q1); ...
    2*(q1*q3-q0*q2) 2*(q0*q1+q2*q3) 1-2*(q1*q1+q2*q2)];

for r=1:length(AccData)
    newAccData(:,r) = R*AccData(r,2:4)';
    newGyrData(:,r) = R*GyrData(r,2:4)';
end

% include timestamp
newAccData = [AccData(:,1) newAccData'];
newGyrData = [GyrData(:,1) newGyrData'];