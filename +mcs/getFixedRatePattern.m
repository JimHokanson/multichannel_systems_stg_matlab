function pt = getFixedRatePattern(rate,varargin)
%
%   pt = mcs.getFixedRatePattern(rate,varargin)
%
%   Optional Inputs defined at:
%   mcs.stg.pulse_train.fixed_rate
%
%   Examples
%   --------
%   % 1) 10 Hz pulse train
%   pt1 = mcs.getFixedRatePattern(10);
%
%   % 2) 3 pulses at 40 Hz, repeated at 2 Hz train rate
%   pt2 = mcs.getFixedRatePattern(40,'n_pulses',3,'train_rate',2);
%
%   % 3) 20 Hz pulse train with 200 us monophasic pulses 1 mA
%   w = mcs.stg.waveform.monophasic(1,200,'amp_units','mA','duration_units','us')
%   plot(w) %Verify this looks ok
%   pt3 = mcs.getFixedRatePattern(20,'waveform',w)

pt = mcs.stg.pulse_train.fixed_rate(rate,varargin{:});

end