# Hardware specs #

- STG5 time resolution is 5 us in the STG5 manual technical specifications.
- Older STG/STG400x workflows in this repository historically used 20 us as
  the default pulse-train timing step; check the connected device before
  working near the timing limit.
- STG5 Sync Out is a 3.3 V TTL signal. The STG5 manual notes that Sync Out
  precedes analog output by a small offset; the technical specification lists
  about 2.5 us, while the synchronization section describes about 15 us.
- For oscilloscope checks in current mode, measure voltage across a suitable
  resistor because oscilloscopes measure voltage, not current. The STG5 manual
  gives a 10 kOhm resistor example: 100 uA across 10 kOhm should read about
  1 V.
- STG5 technical specifications list voltage output as -8 V to +8 V with
  250 uV resolution. Current ranges are 160 uA, 1.6 mA, and 16 mA, with
  hardware resolution of 6.25 nA, 62.5 nA, and 625 nA respectively.
