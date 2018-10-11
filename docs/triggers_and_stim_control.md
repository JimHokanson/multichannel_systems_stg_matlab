# Triggers and Stim Control #

Triggers control which stim channels and which syncs to start for a given trigger.

My understanding is that you get one trigger per channel ...

So for example trigger 1 could start all channels and all syncs simultaneously (not sure of how time locked they are).

Alternatively, you could let trigger 1 control channel 1 and sync 1 and trigger 2 control channel 2 or sync 2, etc.

The best interface for working with triggers is currently the `setupTrigger()` method in the root stimulator.

```
%My typical goto for trigger setup
s = mcs.getStimulator();
s.setupTrigger('linearize',true,'repeat_all',0);

%Connects trigger 1 to channel 1, trigger 2 to channel 2, etc and sets all repeats to 0.
```