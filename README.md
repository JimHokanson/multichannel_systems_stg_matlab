# Multi Channel Systems Stimulus Generator Interface

Multi-Channel Systems (MCS) provides software that allows for communication with their stimulus generators (STG). This Matlab code wraps their drivers.

The streaming interface is not supported. In other words, the goal of this software is to design a stimulus that gets uploaded to the stimulator at one point in time then run. Any changes to the stimulus require reuploading a new stimulus to the stimulator.

\*\***Warning**\*\* At some point there were bugs in the stimulator firmware that made it not work properly with this code. If the code does not appear to be working you may need to update your stimulator firmware .... Otherwise feel free to report issues and I can look into them. Additionally, I currently have minimal testing for the library so please test that your code is working as intended. Any help with adding tests would be appreciated.

\*\***Bonus**\*\* This library contains code which can be used to generate stimulus pulse trains for use in uploading to a DAQ [see here](docs/stimulation_pattern_design.md).

## Status

Many functions exposed by the driver are not yet implemented in Matlab, although most are relatively trivial to implement. Basic functionality of starting and stopping stimuli on channels is implemented. The one big feature not yet supported is to have multiple segments of stimulation, where each segment gets repeated a different number of times. This feature is exposed in the MC Stimulus II GUI (https://www.multichannelsystems.com/software/mc-stimulus-ii) but not yet in this software.  

## Basic Usage

Here is a basic usage example.
```matlab
%This assumes that only one device is present or that we want the first one.
%See help mcs.getStimulator
s = mcs.getStimulator();

%For reference
tr = s.trigger_settings;
disp(tr);

%Typically I run:
%Note this sets all triggers to have infinite repeats (manual stim stopping)
s.setupTrigger('linearize',true,'repeat_all',0);

%Unfortunately you need to get tr again to see the updates. Eventually I'll link everything ...
%See Issue #1
tr = s.trigger_settings;
disp(tr);

%Lots of options here.
%This will create a 40 Hz, 500 uA train of biphasic pulses
pt = 500*mcs.stg.pulse_train.fixed_rate(40);

%Stimulate on channel 1 with this pattern
%Curently pattern is automatically copied to the sync channel as well
s.sentDataToDevice(1,pt);

s.startStim;

%Needed for infinite repeating
s.stopStim;

%------------------------------------------------------------
%Let's use two patterns on two channels:
pt2 = 100*mcs.stg.pulse_train.fixed_rate(10);

%Send the first pattern to channel 1 and the 2nd pattern to channel 3
s.sentDataToDevice([1 3],{pt,pt2});

s.startStim;

s.stopStim;

```

## Dependencies

The driver necessary for this code is included. You might need to have MC Stimulus II installed as well ...

## How this Code Works

This code relies on a driver provided by MCS.

https://www.multichannelsystems.com/software/mcsusbnetdll

I've found some bugs in the driver and others may still remain (so test your code). I've downloaded the driver and placed it into the code. (See /+mcs/+stg/@sdk - currently in a version folder of 3_2_71).

Documentation for the driver is provided in 'McsUsbNet_for_STG.chm'

## Stimulus Design

The design of stimulation patterns is described [here](docs/stimulation_pattern_design.md).
