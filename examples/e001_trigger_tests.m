%e001_trigger_tests
%
%
%   JAH May 2019: This needs some work ...

%Note, trigger settings and everything persists across code reset ...
%TODO: How to flush everything???

%1) GOAL: Stimulation on 2 channels at starting at the same time
%--------------------------------------------------------------------------
%- 10 Hz on channel 1
%- 40 Hz on channel 3

%- This means all 4 channels should be activated by the first trigger.
%- Note I believe this is the default on startup.
chans = cell(1,4); %4 triggers available
chans{1} = 1:4; %trigger 1 starts all 4 channels
map = mcs.utils.bitmask(chans);


s = mcs.getStimulator(); %s : mcs.stg.sdk.cstg200x_download

amplitude = 1000; %uA (default unit)
pt1 = 1000*mcs.getFixedRatePattern(10);
pt2 = 1000*mcs.getFixedRatePattern(40);

%JAH May 2019: Verify that below works and update documentation ...

%This apparently sends the first pattern to all channels
%which is not what I expected ... Is this a bug????
%
%When run I see pt1 on channels 1 & 3....
s.setupTrigger('channel_maps',map,'syncout_maps',map)

s.sentDataToDevice([1 3],{pt1 pt2});

tr = s.trigger_settings;
disp(tr)

%TODO: Indicate how this impacts the maps
s.setupTrigger('repeat_all',0);

%Stimulate with the current trigger setup
s.startStim('triggers',1);
%Stop all triggers
s.stopStim();

%2) Stimulate on each channel when its trigger is specified
%------------------------------------------------------------
%- This example 
%
%Change the trigger setup ...
s = mcs.getStimulator();

amplitude = 1000; %uA (default unit)
pt1 = 1000*mcs.getFixedRatePattern(10);
pt2 = 1000*mcs.getFixedRatePattern(40);

s.setupTrigger('linearize',true,'repeat_all',0);
s.startStim('triggers',1);
pause(0.5)
s.startStim('triggers',3);
%when ready ...
s.stopStim();

%Start at the same time ...
s.startStim('triggers',[1 3]);
s.stopStim();

