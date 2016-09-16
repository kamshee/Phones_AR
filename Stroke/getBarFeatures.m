function [fvec, flab] = getBarFeatures(bar)
% INPUT - bar is a 1 x n vector of barometer measurements

fvec=[];
flab={};

% Average Diff
fvec=[fvec mean(diff(bar))]; flab=[flab; 'MeanDiff'];

% Std of Diff
fvec=[fvec std(diff(bar))]; flab=[flab; 'StdDiff'];

%Skewness + Kurtosis of differences (3rd and 4th moments)
if nanstd(diff(bar)) == 0
    X = diff(bar); N = length(X);
    s = 1/N*sum((X-mean(X)).^3)/( sqrt(1/N*sum((X-mean(X)).^2)) + eps )^3; %skewness
    k = 1/N*sum((X-mean(X)).^4)/( 1/N*sum((X-mean(X)).^2) + eps )^2; %kurtosis 
    fvec = [fvec s]; flab = [flab; 'skew diff'];
    fvec = [fvec k]; flab = [flab; 'kurt diff'];
else
    fvec = [fvec skewness(diff(bar))]; flab = [flab; 'skew diff'];
    fvec = [fvec kurtosis(diff(bar))]; flab = [flab; 'kurt diff'];
end


% Linear Regression slope
x=1:length(bar);
X=[ones(length(bar),1) x.'];
Y=bar.';
B=X\Y;

fvec=[fvec B(2)]; flab=[flab; 'RegSlope'];


