# Stimulus design

A stimulation pattern is currently encompassed in the `mcs.stg.pulse_train` class. In addition, the `mcs.stg.waveform` is relevant as well.

## Initializing the class

The constructors for the pulse train class are as follows:
- mcs.stg.pulse_train.fixed_rate
- mcs.stg.pulse_train.fromTimes
- mcs.stg.pulse_train.fromAmpDurationArrays

`mcs.stg.pulse_train` can be found at '\\+mcs\\+stg\\@pulse_train\pulse_train.m'

```matlab
%fromAmpDurationArrays
%a 3-phase stimulus pulse followed by 0 volts for a total of 10 ms
amplitudes = [-0.5 1 -0.5 0]; %mV since 'voltage' is specified below
durations_ms = [0.1 0.1 0.1 (10-0.3)]; %total period is 10 ms
durations_s = durations_ms/1000;
pt = mcs.stg.pulse_train.fromAmpDurationArrays(...
   amplitudes,durations_s,'output_type','voltage');

%fromTimes
%From a series of ISIs in ms units
isi = randi(50,1,1000)/1000; %/1000 for ms to s conversion
t = cumsum(isi);
pt = mcs.stg.pulse_train.fromTimes(t);

%fixed_rate
%100 Hz pulses for 10 seconds
pt = mcs.stg.pulse_train.fixed_rate(100,'pulses_duration',10)
```

Further options for these constructors are specified in the code.

```
>> help mcs.stg.pulse_train.fixed_rate
 x Create pulse train at a fixed rate.
 
    obj = mcs.stg.pulse_train.fixed_rate(rate,varargin)
 
    Inputs ...
```

Note that varargin represents property/value pairs as specified in optional inputs section of the help documentation.

## Example of modifying standard waveform

Some of the constructors above can take in a waveform as an input parameter, rather than using the default pattern which is a 100 us, biphasic pulse of 1 unit of amplitude (1 uA or 1 mV). Like the pulse train, additional documentation can be found using help.

```
%1 uA, 10 ms
w = mcs.stg.waveform.biphasic(1,10);

%5 uA, 3 ms
w = mcs.stg.waveform.monophasic(5,3);

%100 nA, 100 us
amp = 100; %nA
duration = 100; %us
w = mcs.stg.waveform.biphasic(amp,duration,'amp_units','nA','duration_units','us')

pt = mcs.stg.pulse_train.fixed_rate(100,'waveform',w);
```

## Additional methods

Additional methods exist to modify the pulse train. This can be seen be typing `methods mcs.stg.pulse_train`

```matlab
%Following is an example of using additional methods. This demo is not currently comprehensive ...
pt = mcs.stg.pulse_train.fromTimes([3 5 6]);
%Repeat pattern 10 times
pt.repeat(10);
%Scale the pattern
pt2 = 100*pt; %mtimes()
%Plot the pattern
plot(pt2)
```

Note that most methods can be in place or return a new variable.
```
pt = mcs.stg.pulse_train.fromTimes([3 5 6]);
pt.repeat(10); %in place change, pt is modified
%OR
pt = pt.repeat(10); %or pt2 = pt.repeat(10) to hold onto before and after


pt = mcs.stg.pulse_train.fromTimes([3 5 6]);
pt2 = pt.repeat(5);
plot(pt2)
hold on
plot(pt)
hold off
legend('repeated','original')
```

## Internal workings

The stimulator expects the stimulus to be specified as a series of amplitude/duration pairs (e.g. stimulate at 100 uA for 100 us, followed by 0 uA for 10000 us, etc.). Thus internally the stimulus is tracked as these amplitude/duration pairs.

For other stimulators it may be desirable to work with a sampled waveform at a given sampling frequency (i.e. fixed duration between samples), rather than the more abstract amplitude/duration pairs. For example, sending a stimulation pattern to a NI-DAQ requires specifying the stimulation amplitude at every sample (e.g. at 20kHz). To extract a sampled array use the `getSampledArray()` method (example below).

```matlab
sampling_frequency = 1e6;
dt = 1/sampling_frequency;
%Note without min_time_dt the minimum dt defaults to the standard dt for MCS stimulators which is 20 us
pt = mcs.stg.pulse_train.fromTimes([3 5 6],'min_time_dt',dt);
%Note that I've only retrieved the time vector for plotting
[amplitudes,~,time] = pt.getSampledArray(dt);
plot(time,amplitudes)
```

We don't always need to sample so fast, so a value of -1 for the dt will find the minimum dt needed to account for the durations of the stimulus. Since the default waveform is 100 us this is a sufficient dt for the example below.

```matlab
%Note without min_time_dt the minimum dt defaults to the standard dt for MCS stimulators which is 20 us
pt = mcs.stg.pulse_train.fromTimes([3 5 6]);
%-1 tells code to figure out appropriate dt to use
[amplitudes,dt,t] = pt.getSampledArray(-1);
plot(t,amplitudes)
%dt => 0.0001
```

The current implementation uses either uA or mV internally for amplitude units. Some effort is made to provide options to modify this at the inputs or the outputs. 

```matlab
min_time_dt = 1/1e6;
stim_amp = 3;
phase_width = 100;
waveform_options = {'amp_units','mA','duration_units','us'};
w = mcs.stg.waveform.biphasic(stim_amp,phase_width,waveform_options{:});
stim_freq = 2;
stimulus_duration = 5; %[s]
stim_pattern = mcs.stg.pulse_train.fixed_rate(stim_freq,'waveform',w,'pulses_duration',stimulus_duration,'min_time_dt',min_time_dt);
stim_pattern.addLeadingZeroTime(0.5);

%By default the sync-signal has amplitude 1 V wherever the original signals are not zero
blank_pattern = stim_pattern.createSyncSignal();
%Note these methods don't currenty have options for time units ...
blank_pattern.leftExpandDurations(100/1e6); %Expands the sync pulses 100 us to the left - i.e. turns on 100 us before stim pulse
blank_pattern.rightExpandDurations(-50/1e6); %negative value shrinks sync pulse, turns off 50 us before stim pulse

ax(1) = subplot(2,1,1);
plot(stim_pattern);
ax(2) = subplot(2,1,2);
plot(blank_pattern);
linkaxes(ax,'x')

%This allows us to get a 'dt' value which works for multiple signals
shared_dt = stim_pattern.getDTforPatterns(blank_pattern);

%Get raw arrays for uploading to DAQ
%Notice that we specify how we want the output to be scaled
stim_amp_ma = stim_pattern.getSampledArray(shared_dt,'output_current_units','mA');
blanking_amp_v = blank_pattern.getSampledArray(shared_dt,'output_voltage_units','V');
```


