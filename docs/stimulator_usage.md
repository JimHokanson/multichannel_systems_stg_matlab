# Voltage Mode

From the manual for easier reference:
- Usually use + and GND outputs
- Voltage between + and - is doubled from specified voltage

#Sync Output

- time lag between sync and voltage output is approximately 15 us
- "  " current, 15 us for continuous mode
- "  " current, 50 us if not continuous mode

# Current Mode

- Usually use + and GND outputs
- Using + and - doubles compliance voltage from 60 to 120V
- For oscilloscope checks, measure the voltage across a suitable resistor
  because the oscilloscope input measures voltage. The STG5 manual recommends
  a 10 kOhm resistor for current-output checks; 100 uA across 10 kOhm should
  read about 1 V.

# STG5 range and resolution checks

The GUI displays current range/resolution for each channel and exposes voltage
details in the tooltip. From MATLAB, use:

```matlab
s = mcs.getStimulator();
info = s.getOutputResolutionInfo();
disp(info);
delete(s);
```

For a non-stimulating hardware check, run:

```matlab
examples/e005_stg5_diagnostics
```

# Matching the MC_Stimulus III oscilloscope test

The attached MC_Stimulus III setup uses channel 1 in current mode with a
400 ms biphasic waveform:

- -1000 uA for 200 ms
- +1000 uA for 200 ms
- continuous mode on

To match this in the MATLAB GUI, set channel 1 to amplitude `-1000 uA`, pulse
width `200 ms`, and frequency `2.5 Hz`. The negative amplitude makes the first
phase negative, like the MC_Stimulus III table. A frequency of 2.5 Hz gives a
400 ms period, so the next biphasic pulse starts immediately after the second
200 ms phase.

The helper `examples/e006_stg5_mc_stimulus_match.m` prints the exact arrays
for this pattern without starting stimulation. Its `do_start` flag is `false`
by default. When `do_start` is set to `true`, it uses `trigger_repeats = 10`
by default, matching the finite-repeat style used by the MCS Python example.
This avoids relying on repeat `0` semantics across device/driver combinations.

# Python example compatibility

The MCS Python stimulation example uses
`CMcsUsbListNet(DeviceEnumNet.MCS_DEVICE_USB)`. That constructor is present in
newer upstream `McsUsbNet.dll` builds, but not in the older bundled 3.2.71 DLL.
The MATLAB wrapper now defaults to the bundled `5_2_3` driver, which supports
STG5 enumeration and MATLAB .NET interop for download-mode stimulation.
