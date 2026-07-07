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

### Updating an idle channel while another channel is running

Download mode can replace data for a single channel with `PrepareAndSendData`,
but changing the channel/sync capacity can rewrite STG memory. On devices that
use explicit capacity allocation, reserve capacity before starting stimulation,
then update only an idle, pre-reserved channel:

```matlab
s = mcs.getStimulator();
s.setupTrigger('linearize',true,'repeat_all',0);

if s.usesExplicitCapacityAllocation()
    pt2_capacity = 1000*mcs.getFixedRatePattern(100,'n_pulses',5);
    s.reserveChannelCapacity(2,pt2_capacity);
end

pt1 = 500*mcs.getFixedRatePattern(10);
s.sentDataToDevice(1,pt1);
s.startStim('triggers',1);

% Later, while channel 1 continues running:
pt2 = 250*mcs.getFixedRatePattern(40,'n_pulses',3);
s.updateChannelData(2,pt2);
s.startStim('triggers',2);
```

`updateChannelData()` refuses to resize memory, and it refuses to replace data
on a channel that is mapped to a trigger known active through the same MATLAB
object. On drivers that do not expose `GetCapacity`/`SetCapacity`, the wrapper
sends runtime uploads directly to the idle target channel without pre-verifying
reserved capacity. See `examples/e003_runtime_channel_update.m`.

### Multi-channel GUI

The stimulation GUI shows one row per channel, each with independent amplitude,
frequency, pulse width, units, hardware range/resolution, status, and
start/stop controls. A running channel's parameter controls are disabled; stop
that channel before editing or uploading new parameters for it. Other active
channels continue running while a different idle channel is edited or started.

```matlab
gui = mcs.stimGUI();
```

If MATLAB reports that the device is locked after a previous GUI run, close
any open stim GUI window or run:

```matlab
mcs.closeStimGUI();
clear classes;
gui = mcs.stimGUI();
```

`mcs.closeStimGUI()` stops stimulation controlled by an existing stim GUI while
it releases that GUI's device handle.

See `examples/e004_multichannel_stim_gui.m`.

### STG5 diagnostics

Run the non-stimulating STG5 diagnostic to confirm the driver can connect,
print voltage/current range and resolution values, and rewrite the linear
trigger map used by the GUI:

```matlab
examples/e005_stg5_diagnostics
```

This diagnostic does not call `SendStart`. For oscilloscope checks in current
mode, measure across a load resistor; see `docs/relevant_hardware_specs.md`.

## Dependencies

The driver necessary for this code is included. You might need to have MC Stimulus II installed as well ...

## How this Code Works

This code relies on a driver provided by MCS.

https://www.multichannelsystems.com/software/mcsusbnetdll

I've found some bugs in the driver and others may still remain (so test your code). I've downloaded the driver and placed it into the code. (See /+mcs/+stg/@sdk - currently using version folder 5_2_3 by default; older 3_2_71 files are retained for reference).

Documentation for the driver is provided in 'McsUsbNet_for_STG.chm'

## Stimulus Design

The design of stimulation patterns is described [here](docs/stimulation_pattern_design.md).
