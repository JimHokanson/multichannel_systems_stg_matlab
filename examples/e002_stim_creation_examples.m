%function e002_stim_creation_examples()

%1) - use of the fromTimes constructor:
%--------------------------------------------------------------------------
%The fromTimes constructor is useful when you want to repeat a waveform
%at specified times.

%Let's create a monophasic waveform at 5V and 15 ms in duration.
w = mcs.stg.waveform.monophasic(5,15,'amp_units','V','duration_units','ms');



real_stim_frequency = p.peakFreq+0.5;

dt = 1/real_stim_frequency;
t = 0.031:dt:5;

temp_amp = 0.03; %30 mV from above
pt2 = mcs.stg.pulse_train.fromTimes(t,'waveform',w);

offset = 0.031;
pt3 = mcs.stg.pulse_train.fixed_rate(real_stim_frequency,'pulses_duration',p.stimLenS-offset,'waveform',w);
pt3.prependValues(0,offset);

plot(pt)
hold on
plot(pt2)
plot(pt3)
hold off
legend({'pt','pt2','pt3'})

