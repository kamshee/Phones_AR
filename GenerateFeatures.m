%% Generate Features from Clips
% Run after GenerateClips.m

dirname='Z:\RERC- Phones\Server Data\Clips\';
featdirname='Z:\RERC- Phones\Server Data\Features\';

%% Identify Subject IDs based on folders containing processed data
filenames=dir([dirname '*.mat']);

ClipData=load(filenames(1).name, 'SubjClips');
ClipData=ClipData.SubjClips;

[FeatV, FeatLab]=getFeatures(ClipData.Acc(:,:,1).');

