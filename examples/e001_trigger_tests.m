%Set 10 Hz on chan 1 and 40 Hz on chan 3
%1) Start them at the same time
%2) Set them on their own triggers

%Note, trigger settings and everything persists across code reset ...
%How to flush everything???

%This is the default ...
%For 4 channels ...
%Ideally this would be padded in some way
%to avoid the zeros ...
map = mcs.utils.bitmask({[1 2 3 4] 0 0 0});

s = mcs.getStimulator();

amplitude = 1000; %uA

pt1 = 1000*mcs.getFixedRatePattern(10);
pt2 = 1000*mcs.getFixedRatePattern(40);

s.setupTrigger('channel_maps',map,'syncout_maps',map)

s.sentDataToDevice(1,pt1,'mirror_to_sync',true);
%Set pt2 on chan 3
s.sentDataToDevice(3,pt2,'mirror_to_sync',true);

tr = s.trigger_settings;
disp(tr)

s.setupTrigger('repeat_all',0);

s.startStim('triggers',1);
%Stop all triggers
s.stopStim();

s.setupTrigger('linearize',true,'repeat_all',0);
