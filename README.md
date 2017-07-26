# Multi Channel Systems Stimulus Generator Interface

Multi-Channel Systems (MCS) provides software that allows for communication with their stimulus generators (STG). This Matlab code wraps their drivers.

## Status

I'm just getting started. The goal is to get code that works like this:

```
device = mcs.stg.getDevice();
waveform = 
device.
```

The code will also be sufficiently flushed out so as to allow something more complicated like this:

```
%JAH TODO
```

## Dependencies

Currently the code relies on my Matlab Standard Library (https://github.com/JimHokanson/matlab_standard_library) although I will remove this dependency at some point ...