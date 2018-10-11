%e001_trigger_tests

%Set 10 Hz on chan 1 and 40 Hz on chan 3
%1) Start them at the same time
%2) Set them on their own triggers

%Note, trigger settings and everything persists across code reset ...
%How to flush everything???

%This is the default ...
%For 4 channels ...
%Ideally this would be padded in some way
%to avoid the zeros ...
%Basically this says trigger 1 should activate all 4 channels
map = mcs.utils.bitmask({[1 2 3 4] 0 0 0});

s = mcs.getStimulator();

amplitude = 1000; %uA

pt1 = 1000*mcs.getFixedRatePattern(10);
pt2 = 1000*mcs.getFixedRatePattern(40);

%This apparently sends  the first pattern to all channels
%which is not what I expeted ... Is this a bug????
%
%When run I see pt1 on channels 1 & 3....
s.setupTrigger('channel_maps',map,'syncout_maps',map)

s.sentDataToDevice([1 3],{pt1 pt2});

tr = s.trigger_settings;
disp(tr)

s.setupTrigger('repeat_all',0);

%Stimulate with the current trigger setup
%---------------------------------------------
%Not what I expected ... - see above note ...
s.startStim('triggers',1);
%Stop all triggers
s.stopStim();

%Change the trigger setup ...
s.setupTrigger('linearize',true,'repeat_all',0);
s.startStim('triggers',1);
pause(0.5)
s.startStim('triggers',3);
%when ready ...
s.stopStim();

%Start at the same time ...
s.startStim('triggers',[1 3]);
s.stopStim();

