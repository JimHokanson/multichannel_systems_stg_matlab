# Multi Channel Systems Stimulus Generator Interface

Multi-Channel Systems (MCS) provides software that allows for communication with their stimulus generators (STG). This Matlab code wraps their drivers.

## Status

The code currently has dependencies which I need to remove (see section on Dependencies). Many functions exposed by the driver are not yet implemented in Matlab, although most are relatively trivial to implement.

## Basic Usage

Here is a basic usage example.
```matlab
%This assumes that only one device is present or that we want the first one.
d = mcs.getStimulator();

%By default we have only 1 repeat, 0 means infinite repeats
d.trigger_settings.repeats(1) = 0;

%Lots of options here.
%This will create a 40 Hz, 500 uA train of biphasic pulses
pt = 500*mcs.stg.pulse_train.fixed_rate(40);

%TODO: Working on sync mirroring ...
d.sentDataToDevice(1,pt);
d.startStim;

d.stopStim;
```

## Dependencies

Currently the code relies on my Matlab Standard Library (https://github.com/JimHokanson/matlab_standard_library) although I will remove this dependency at some point ...

## How this Code Works

This code relies on a driver provided by MCS.

https://www.multichannelsystems.com/software/mcsusbnetdll

I've found some bugs in the driver and others may still remain (so test your code). I've downloaded the driver and placed it into the code. (See /+mcs/+stg/@sdk - currently in a version folder of 3_2_71).

Documentation for the driver is provided in 'McsUsbNet_for_STG.chm'

## Stimulus Design

TODO: Describe this
