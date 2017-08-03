# Multi Channel Systems Stimulus Generator Interface

Multi-Channel Systems (MCS) provides software that allows for communication with their stimulus generators (STG). This Matlab code wraps their drivers.

## Status

The code currently has dependencies which I need to remove (see section on Dependencies). Many functions are not yet implemented, although most are relatively trivial to implement ...


## Basic Usage

Here is a basic usage example.
```
%This assumes that only one device is present or that we want the first one.
d = mcs.stg.sdk.cstg200x_download.fromIndex(1);

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

## Stimulus Design

TODO: Describe this