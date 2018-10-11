# Multi Channel Systems Stimulus Generator Interface

Multi-Channel Systems (MCS) provides software that allows for communication with their stimulus generators (STG). This Matlab code wraps their drivers.

## Status

The code currently has dependencies which I need to remove (see section on Dependencies). Many functions exposed by the driver are not yet implemented in Matlab, although most are relatively trivial to implement.

## Basic Usage

Here is a basic usage example.
```matlab
%This assumes that only one device is present or that we want the first one.
s = mcs.getStimulator();

%For reference
tr = s.trigger_settings;
disp(tr);

%Typically I run:
%Note this sets all triggers to have infinite repeats (manual stim stopping)
s.setupTrigger('linearize',true,'repeat_all',0);

%Unfortunately you need to get tr again to see the updates. Eventually I'll link everything ...
%Issue #1
tr = s.trigger_settings;
disp(tr);

%Lots of options here.
%This will create a 40 Hz, 500 uA train of biphasic pulses
pt = 500*mcs.stg.pulse_train.fixed_rate(40);

%Stimulate on channel 1 with this pattern
%Curently pattern is automatically copied to the sync channel as well
s.sentDataToDevice(1,pt);

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

TODO: Describe this
