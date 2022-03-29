classdef (Hidden) test__pulse_train
    %
    %   Class:
    %   mcs.stg.test__pulse_train
    
    
    methods
        function obj = test__pulse_train()
            %TODO: Test in.pulses_duration with rate that requires rounding
            %
            %i.e. 2 seconds at 22.1Hz
            
            %This will be ok, since 22.1 gets rounded
            
            fh_fixed = @mcs.stg.pulse_train.fixed_rate;
            
            pt = fh_fixed(22.1,'pulses_duration',2);
            
            pulse_width = 30; %not realizable
            w = mcs.stg.waveform.monophasic(1,pulse_width,'amp_units','mA','duration_units','us');
            pt = fh_fixed(22.1,'pulses_duration',2,'waveform',w);
            
            pt_1  = fh_fixed(1);
            pt_10 = fh_fixed(10);
            pt_20 = fh_fixed(20);
            pt_6 = fh_fixed(6);
            pt_lr = fh_fixed(40,'n_pulses',3,'train_rate',1/0.5,'n_trains',1);
            pt_sr = fh_fixed(40,'n_pulses',3,'train_rate',1/0.21,'n_trains',1);
            pt_hr = fh_fixed(40,'n_pulses',3,'train_rate',1/0.1250,'n_trains',1);
            
            
            %Left-duration expansion
            %--------------------------------------------------------------
            % 1) --- Expand, allowing overall time growth
            pt = mcs.stg.pulse_train.fixed_rate(10,'n_pulses',100);
            delta_t = 50/1e6; %50 us
            %Only expand positive values
            pt2 = pt.leftExpandDurations(delta_t,'mask',pt.amplitudes > 0,'allow_expanding_time',true);
            
            % 2) --- Prepend 0 to avoid the time shift
            pt = mcs.stg.pulse_train.fixed_rate(10,'n_pulses',100);
            %Add 0.5 seconds with no amplitude
            pt.prependValues(0,0.5);
            delta_t = 50/1e6; %50 us
            
        end
        
        
    end