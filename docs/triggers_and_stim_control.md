# Triggers and Stim Control #

Triggers control which stim channels and which syncs to start for a given trigger.

My understanding is that you get one trigger per hardware channel.

So for example trigger 1 could start all channels and all syncs simultaneously (not sure of how time locked they are).

Alternatively, you could let trigger 1 control channel 1 and sync 1 and trigger 2 control channel 2 or sync 2, etc.

The best interface for working with triggers is currently the `setupTrigger()` method in the root stimulator.

```
%My typical goto for trigger setup
s = mcs.getStimulator();
s.setupTrigger('linearize',true,'repeat_all',0);

%Connects trigger 1 to channel 1, trigger 2 to channel 2, etc and sets all repeats to 0.
```

Here's another example where I get a bit fancier with mapping triggers to channels. In this case trigger 1 controls channels 1 & 2. Trigger 2 controls channel 3 and trigger 3 controls channel 4.

JAH NOTE: This is not currently working as expected. See e001_trigger_tests

```
temp = cell(1,4);
temp{1} = 1:2;
temp{2} = 3;
temp{3} = 4;

%TODO: Unfortunately the 0 is necessary to have proper length
map = mcs.utils.bitmask(temp);
s.setupTrigger('channel_maps',map,'syncout_maps',map)
tr = s.trigger_settings;
disp(tr);
```

Note, settings persist across Matlab sessions so it is best to set all trigger settings as desired.