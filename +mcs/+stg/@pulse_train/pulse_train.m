classdef pulse_train < matlab.mixin.Copyable
    %
    %   Class:
    %   mcs.stg.pulse_train
    %
    %   Constructors
    %   ------------
    %   mcs.stg.pulse_train.fixed_rate
    %   mcs.stg.pulse_train.fromTimes
    %   mcs.stg.pulse_train.fromAmpDurationArrays
    %
    %   This holds onto a specification of a stimulus; essentially
    %   amplitudes and durations of those amplitudes.
    %
    %   See Also
    %   --------
    %   mcs.stg.waveform
    %
    %   Examples
    %   -----------------------------
    %   pt = 500*mcs.stg.pulse_train.fixed_rate(40);
    %
    %   %This is not yet fully implemented
    %   pt = mcs.stg.pulse_train.fromTimes(times,varargin)
    
    properties (Constant)
        CURRENT_UNITS = 'uA'
        VOLTAGE_UNITS = 'mV'
        TIME_UNITS = 's'
        DEFAULT_MIN_TIME_DT = 20/1e6 %20 us or 50kHz
    end
    
    properties
        d1 = '----  Read only properties ----'
        min_time_dt
        %dt - time between samples
        %The minimum time allowed for a dt value. Internally the signals
        %are not sampled, but this allows us to add checks for values that
        %are not valid given this dt specification.
        
        output_type  %'voltage' or 'current'
        %This is not used much internally, except for plotting. This was
        %added so that the object could be given to the stimulator and the 
        %stimulation instructions could be interpreted accurately. For the 
        %MCS stimulator that can support either voltage or current
        %stimulation instructions this distinction is important.
        
        amplitudes   %row vector, Amplitude is in uA or mV
        %Note internally we don't support different units, only on
        %the input and output.
        
        durations    %row vector, Durations are in seconds
        %This is the duration that the stimulator should stay at the given
        %amplitude.
        
        %These are computed based on 'durations'
        %They are computed once rather than dynamically ...
        start_times
        stop_times
        total_duration_s
    end
    
    properties (Dependent)
        n_samples
        %# of amplitude/durations pairs
        
        net_charge
        %The total charge in the pulse-train.
    end
    
    methods
        function value = get.n_samples(obj)
            value = length(obj.durations);
        end
        function value = get.net_charge(obj)
            value = sum(obj.durations.*obj.amplitudes);
        end
    end
    
    properties
        d2 = '---- read/write properties ----'
        user_summary %This is optional and can be used to keep a
        %user-defined summary along with the pulse train.
    end

    %---------------    Constructors    --------------------
    methods (Static)
        function obj = fromAmpDurationArrays(amps,durations,varargin)
            %x Creates an object from raw amplitudes and durations
            %
            %   pt = mcs.stg.pulse_train.fromAmpDurationArrays(amplitudes,durations,varargin)
            %
            %   Inputs
            %   ------
            %   amplitudes : [uA] or [mV]
            %       Array of stimulus amplitudes
            %   durations : [s]
            %       Array of durations of each stimulus amplitude.
            %
            %   Optional Inputs (at end as key/value pairs)
            %   --------------------------------------------
            %   output_type : default 'current'
            %       - 'current'
            %       - 'voltage'
            %   min_time_dt : default mcs.stg.pulse_train.DEFAULT_MIN_TIME_DT
            %
            %   Example
            %   -------
            %   %#1
            %   amplitudes = [-0.5 1 -0.5 0];
            %   durations_ms = [0.1 0.1 0.1 (10-0.3)];
            %   durations_s = durations_ms/1000;
            %   pt = mcs.stg.pulse_train.fromAmpDurationArrays(...
            %           amplitudes,durations_s,'output_type','voltage');
            %   pt2 = pt.repeat(100);
            %   plot(pt2)
            
            in.output_type = 'current';
            in.min_time_dt = mcs.stg.pulse_train.DEFAULT_MIN_TIME_DT;
            in = mcs.sl.in.processVarargin(in,varargin);
            
            obj = mcs.stg.pulse_train;
            obj.min_time_dt = in.min_time_dt;
            obj.output_type = in.output_type;
            obj.amplitudes = amps(:)';
            obj.durations = durations(:)';
            h__initTimes(obj);
            
        end
        function obj = fromTimes(times,varargin)
            %x Create stimulus train from pulses at specified times
            %
            %   pt = mcs.stg.pulse_train.fromTimes(times,varargin)
            %
            %   Place a stimulus waveform at each specified time.
            %
            %   Inputs
            %   ------
            %   times : [s]
            %       Times to stimulate. 
            %
            %   Optional Inputs
            %   ---------------
            %   output_type : default 'current'
            %   min_time_dt : default mcs.stg.pulse_train.DEFAULT_MIN_TIME_DT
            %   amp_units : default 'uA'
            %       This is ignored if a stimulus waveform is specified.
            %       - 'mA'
            %       - 'uA'
            %       - 'nA'
            %       - 'V'
            %       - 'mV'
            %       - 'uV'
            %   waveform : default []
            %       See mcs.stg.waveform for more examples.
            %
            %   Examples
            %   ----------
            %   %#1
            %   isi = randi(50,1,1000)/1000; %/1000 for ms to s conversion
            %   t = cumsum(isi);
            %   pt = mcs.stg.pulse_train.fromTimes(t);
            %
            %   %#2
            %   isi = (1:200)./1000;
            %   t = cumsum(isi);
            %   pt = mcs.stg.pulse_train.fromTimes(t);
            
            in.output_type = 'current';
            in.min_time_dt = mcs.stg.pulse_train.DEFAULT_MIN_TIME_DT;
            in.amp_units = 'uA';
            in.waveform = []; %mcs.stg.waveform
            in = mcs.sl.in.processVarargin(in,varargin);
            
            if isempty(in.waveform)
                waveform = mcs.stg.waveform.biphasic(1,0.1,'amp_units',in.amp_units);
            else
                waveform = in.waveform;
            end
            
            waveform_durations = waveform.durations_s;
            waveform_amplitudes = waveform.amplitudes;
            
            %ISI setup
            %--------------------------------------
            isis = diff(times);
            total_waveform_duration = sum(waveform_durations);
            isi_minus_waveform = isis-total_waveform_duration;
            
            if any(isi_minus_waveform < 0)
               error('Insufficient time between pulses given waveform duration') 
            end

            n_samples_per_pulse = length(waveform_amplitudes);
            %Add 1 for the 0 between pulses
            n_samples_per_isi = n_samples_per_pulse+1;
            n_samples_total = n_samples_per_isi*length(times);
            
            %----|----|----| <= std example => 3 pulses, 3 ISIs
            %|---|--|  <= start with pulse example => 3 pulses, 2 ISIs
            
            if times(1) == 0
                n_samples_total = n_samples_total-1;
            end
            
            %Population of the output
            %------------------------------------
            durations = zeros(1,n_samples_total);
            amplitudes = zeros(1,n_samples_total);
            
            if times(1) ~= 0
                durations(1) = times(1);
                end_I = 1;
            else
                end_I = 0;
            end
            
            %We're populating like this
            %
            %   0000 <= populated above if present
            %   ----|----|--|-------|
            %       11111
            %            222
            %               33333333
            %                       4 <= add on at the end
            
            for i = 1:(length(times)-1)
                start_I = end_I+1;
                end_I = end_I + n_samples_per_pulse;
                durations(start_I:end_I) = waveform_durations;
                amplitudes(start_I:end_I) = waveform_amplitudes;
                end_I = end_I + 1;
                durations(end_I) = isi_minus_waveform(i);
            end
            
            start_I = end_I+1;
            end_I = end_I + n_samples_per_pulse;
         	durations(start_I:end_I) = waveform_durations;
            amplitudes(start_I:end_I) = waveform_amplitudes;
            
           	obj = mcs.stg.pulse_train;
            obj.min_time_dt = in.min_time_dt;
            obj.output_type = waveform.output_type;
            obj.amplitudes = amplitudes;
            obj.durations = durations;
            h__initTimes(obj);
        end
        function obj = fixed_rate(rate,varargin)
            %x Create pulse train at a fixed rate.
            %
            %   obj = mcs.stg.pulse_train.fixed_rate(rate,varargin)
            %
            %   Inputs
            %   ------
            %   rate :
            %       Frequency of pulses, e.g. 20 Hz. The rate is rounded to
            %       the nearest multiple of 'min_time_dt'.
            %
            %   Optional Inputs
            %   ---------------
            %   min_time_dt : default = mcs.stg.pulse_train.DEFAULT_MIN_TIME_DT
            %       
            %   amp_units : string
            %       - 'mA'
            %       - 'uA' (default)
            %       - 'nA'
            %       - 'mV'
            %   waveform : default 1 amp_unit, 100 us, biphasic
            %       This is the waveform that gets replicated.
            %
            %   n_pulses : (default 1)
            %       # of pulses in a train. Note with only one pulse
            %       and no train, an infinite repeat will yield the desired
            %       stim rate because of the duration of zero amplitude
            %       that follows the pulse.
            %   pulses_duration : units (s)
            %       Used to compute the # of pulses in a train if n_pulses
            %       is not specified. Note for this purpose a pulse is
            %       the waveform and the time to the next waveform. Thus
            %       if the pulses_duration is 1.5s and the rate is 1 Hz,
            %       you will get only 1 pulse because the full duration is
            %       (1/1Hz) or 1 s.
            %
            %       ----- Trains are groups of pulses ----
            %
            %   trains_rate :
            %       Rate of repetition of a series of n_pulses.
            %
            %   n_trains : Default of 1 train
            %
            %   trains_duration :
            %       Specifies how long all trains should be.
            %
            %
            %   Visual Parameter Explanation
            %   ----------------------------
            %
            %   -----------  1/train_rate
            %   | | |     | | |      | | |    <= 3 pulses in trains
            %   ---  1/rate
            %   1 2 3 <= based on n_pulses or pulses_duration
            %
            %
            %   Examples
            %   --------
            %   % 1) 10 Hz pulse train
            %   pt1 = mcs.stg.pulse_train.fixed_rate(10);
            %
            %   % 2) 3 pulses at 40 Hz, repeated at 2 Hz train rate
            %   pt2 = mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2);
            %
            %   % 3) 20 Hz pulse train with 200 us monophasic pulses 1 mA
            %   w = mcs.stg.waveform.monophasic(1,200,'amp_units','mA','duration_units','us');
            %   subplot(3,1,1)
            %   plot(w) %Verify this looks ok - it is really boring
            %   title('the monophasic stimulus waveform')
            %   % Use waveform as input to pulse train
            %   pt3 = mcs.stg.pulse_train.fixed_rate(20,'waveform',w);
            %   subplot(3,1,2)
            %   plot(pt3)
            %   title('Pulse at 20 Hz')
            %   %Let's make it 5 mA
            %   pt3_5mA = 5*pt3;
            %   subplot(3,1,3)
            %   plot(pt3_5mA)
            %   title('5x pulse at 20 Hz')
            %
            %   % 4) 100 Hz pulses for 10 seconds
            %   pt4 = mcs.stg.pulse_train.fixed_rate(100,'pulses_duration',10)
            %   %Note, this takes up a decent amount of memory. Any longer
            %   %and it would be bettter to specify repeats of a single
            %   %pulse.
            %
            %
            %
            %   See Also
            %   ---------
            %   mcs.stg.waveform.biphasic
            
            ERR_ID = 'mcs:stg:pulse_train:fixed_rate';
            
            in.min_time_dt = mcs.stg.pulse_train.DEFAULT_MIN_TIME_DT;
            in.amp_units = 'uA';
            in.waveform = []; %mcs.stg.waveform
            %-----------------------------
            in.n_pulses = [];
            in.pulses_duration = [];
            %-----------------------------
            in.train_rate = [];
            in.n_trains = [];
            in.trains_duration = [];
            %-----------------------------
            in = mcs.sl.in.processVarargin(in,varargin);
            
            if isempty(in.waveform)
                %1 uA, 0.1 ms
                waveform = mcs.stg.waveform.biphasic(1,0.1,'amp_units',in.amp_units);
            else
                waveform = in.waveform;
            end
            
            %Creation of a train
            %--------------------------------------------------------------
            dt = 1/rate;
            
            dt = round(dt./in.min_time_dt)*in.min_time_dt;
            if dt == 0
                error('Specified rate was too high based on ''min_time_dt'' specification')
            end
            
            between_pulse_dt = dt - waveform.total_duration_s;
            if between_pulse_dt < 0
                error(ERR_ID,'Stimulation rate is too high given the waveform duration')
            end
            
            if ~isempty(in.pulses_duration)
                n_pulses = floor(in.pulses_duration/dt);
            elseif ~isempty(in.n_pulses)
                n_pulses = in.n_pulses;
            else
                n_pulses = 1;
            end
            
            obj = mcs.stg.pulse_train;
            obj.min_time_dt = in.min_time_dt;
            obj.output_type = waveform.output_type;
            obj.amplitudes = [waveform.amplitudes 0];
            obj.durations = [waveform.durations_s between_pulse_dt];
            h__initTimes(obj);
            if n_pulses > 1
                obj = obj.repeat(n_pulses);
            end
            
            %Train handling
            %--------------------------------------------------------------
            if ~isempty(in.train_rate)
                %For trains, we can't keep the zeroing at the end
                %since we add it back in via train rate
                %
                % | <= pulse
                % - <= zero amplitude spacer
                %
                % |--|--|--  <= pattern before train
                % |--|--|    <= dropping of last zero
                % |--|--|------ <= add zeros for specifying traing rate
                % |--|--|------|--|--|------ <= train pattern
                %
                obj.dropLastValue();
                
                train_dt = 1/in.train_rate;
                between_train_dt = train_dt - obj.total_duration_s;
                if between_train_dt < 0
                    error(ERR_ID,'Train rate is too high given the waveform duration')
                end
                
                obj.addValue(0,between_train_dt);
                
                if ~isempty(in.trains_duration)
                    n_trains = floor(in.trains_duration/train_dt);
                elseif ~isempty(in.n_trains)
                    n_trains = in.n_trains;
                else
                    n_trains = 1;
                end
                
                if n_trains > 1
                    obj = obj.repeat(n_trains);
                end
            end
        end
    end
    
    methods
        function varargout = leftExpandDurations(obj,t,varargin)
            %x Expand the duration of specified points
            %
            %   leftExpandDurations(obj,t,varargin)
            %
            %   Note, this currently consumes durations so that the
            %   total time remains the same, with the exception of the end
            %   value.
            %
            %       ----    Initial
            %   ----    --  
            %
            %     ------    Left-expanded duration
            %   --      --
            %
            %   By default any non-zero amplitudes are left expanded.
            %
            %   Inputs
            %   ------
            %   t : scalar
            %       Time to expand the specified duration segment. A
            %       positive value expands whereas a negative value
            %       will shorten the segment.
            %
            %   Optional Inputs
            %   ---------------
            %   mask : default, non-zero amplitudes
            %       Which segments to left expand. By default we expand 
            %       anything with an amplitude that is not 0.
            %   allow_expanding_time : default false
            %       If true the total time will increase. This will
            %       shift the entire signal back in time if the first
            %       value in the mask is true. This would not be desirable
            %       if you're trying to sync 2 signals
            %
            %   Examples
            %   --------
            %   %#1 --- Expand, allowing overall time growth
            %   pt = mcs.stg.pulse_train.fixed_rate(10,'n_pulses',100);
            %   dt = 50/1e6; %50 us
            %   %Only expand positive values
            %   pt2 = pt.leftExpandDurations(dt,'mask',pt.amplitudes > 0,'allow_expanding_time',true);
            %   plot(pt)
            %   hold on
            %   plot(pt2)
            %   hold off
            %   %TODO: Zooming in by default would help
            %   title('This left shift looks wrong because we extended time for the first pulse')
            %
            %   %#2 --- Prepend 0 to avoid the time shift
            %   pt = mcs.stg.pulse_train.fixed_rate(10,'n_pulses',100);
            %   %Add 0.5 seconds with no amplitude
            %   pt.prependValues(0,0.5);
            %   dt = 50/1e6; %50 us
            %   pt2 = pt.leftExpandDurations(dt,'mask',pt.amplitudes > 0);
            %   plot(pt)
            %   hold on
            %   plot(pt2)
            %   hold off
            %   title('This left shift looks good, because we expand into the leading 0 for the first pulse')
            
            in.mask = -1;
            in.allow_expanding_time = false;
            in = mcs.sl.in.processVarargin(in,varargin);
            
            if nargout
                obj = copy(obj);
            end
            
            durations_local = obj.durations;
            
            if in.mask == -1
                in.mask = obj.amplitudes ~= 0;
            end
            
            if length(in.mask) ~= length(obj.amplitudes)
                error('The mask length must be the same as the amplitude array')
            end
            
            expand_first_value = false;
            if in.mask(1)
                if in.allow_expanding_time
                    expand_first_value = true;
                    in.mask(1) = false;
                else
                    error('Unable to expand duration for first sample, change with ''allow_expanding_time'' option')
                end
            end
            
            I = find(in.mask);
            if t > 0
                prev_durations = obj.durations(I-1);
                if any(prev_durations < t)
                    error('Unable to expand past multiple values, one of the preceeding durations is too short')
                end
            else 
                %TODO: Test this
                cur_durations = obj.durations(I);
                if any(cur_durations < abs(t))
                    error('Unable to shorten current duration beyond having a 0 duration')
                end
            end
            
            %The actual expansion, expand by taking from neighbor
            %----------------------------------------------------
            for i = 1:length(I)
                cur_I = I(i);
                %Note the checks above ensure
                durations_local(cur_I) = durations_local(cur_I) + t;
                durations_local(cur_I-1) = durations_local(cur_I-1) - t;
            end
            
            if expand_first_value
                durations_local(1) = durations_local(1) + t;
            end
            
            obj.durations = durations_local;
            h__initTimes(obj)
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = rightExpandDurations(obj,t,varargin)
            %x Expand duration to the right of specified segments
            %
            %   rightExpandDurations(obj,t,varargin)
            %
            %   Note, this currently consumes durations so that the
            %   total time remains the same, with the exception of the end
            %   value.
            %
            %   Note, any consecutive true values in the mask may lead
            %   to unexpected results as the expansion of one duration
            %   will eat into the expansion of its neighbor's duration.
            %
            %       ----        Initial
            %   ----    ----  
            %
            %       ------    Right-expanded duration
            %   ----      --
            %
            %   Inputs
            %   ------
            %   t : scalar
            %       Time to expand the duration ...
            %
            %   Optional Inputs
            %   ---------------
            %   mask : default, non-zero amplitudes
            %       Which values to right-expaned. By default we expand 
            %       anything with an amplitude that is not 0.
            %   allow_expanding_time : default true
            %       If true the total time will increase. This may be
            %       undesirable if we have two signals that we are keeping
            %       in sync.
            %
            %   Examples
            %   --------
            %   %#1
            %   pt = mcs.stg.pulse_train.fixed_rate(10,'n_pulses',100);
            %   dt = 50/1e6; %50 us
            %   %Only expand negative amplitude values
            %   pt2 = pt.rightExpandDurations(dt,'mask',pt.amplitudes < 0);
            %   plot(pt)
            %   hold on
            %   plot(pt2)
            %   hold off
            %   legend('original','right expanded')
            
            in.mask = -1;
            in.allow_expanding_time = true;
            in = mcs.sl.in.processVarargin(in,varargin);
            
            if nargout
                obj = copy(obj);
            end
            
            durations_local = obj.durations;
            
            if in.mask == -1
                in.mask = obj.amplitudes ~= 0;
            end
            
            if length(in.mask) ~= length(obj.amplitudes)
                error('The mask length must be the same as the amplitude array')
            end
            
            expand_last_value = false;
            if in.mask(end)
                if in.allow_expanding_time
                    expand_last_value = true;
                    in.mask(end) = false;
                else
                    error('Unable to expand duration for last sample, change with ''allow_expanding_time'' option')
                end
            end
            
            I = find(in.mask);
            if t > 0
                next_durations = obj.durations(I+1);
                if any(next_durations < t)
                    error('Unable to expand past multiple values, one of the subsequent values is too short')
                end
            else 
                %TODO: Test this
                cur_durations = obj.durations(I);
                if any(cur_durations < abs(t))
                    error('Unable to shorten current duration beyond having a 0 duration')
                end
            end
            
            %The actual expansion, expand by taking from neighbor
            %----------------------------------------------------
            for i = 1:length(I)
                cur_I = I(i);
                %Note the checks above ensure
                durations_local(cur_I) = durations_local(cur_I) + t;
                durations_local(cur_I+1) = durations_local(cur_I+1) - t;
            end
            
            if expand_last_value
                durations_local(end) = durations_local(end) + t;
            end
            
            obj.durations = durations_local;
            h__initTimes(obj)
            
            if nargout
                varargout{1} = obj;
            end
            
        end
        function new_obj = createSyncSignal(obj,varargin)
            %x Creates signal for sync or blanking
            %
            %   A sync signal has a single amplitude at any amplitudes in
            %   the original signal which are not zero.
            %
            %   This can also be used for blanking.
            %
            %
            %   Optional Inputs
            %   ---------------
            %   simplify : default true
            %       If true values with the same amplitude in the sync
            %       signal (from taking absolute value) are merged into one
            %       duration segment. This can be useful for later
            %       duration expansion.
            %   output_type : default 'voltage'
            %       - 'current'
            %       - 'voltage'
            %   sync_amp : default 1
            %       By default the non-zero amplitude is 1. This can be
            %       changed here or it can be modified afterwards by
            %       multiplication, as per the example.
            %
            %   Examples
            %   --------
            %   pt = mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3);
            %   pt2 = pt.createSyncSignal();
            %   plot(pt)
            %   yyaxis right
            %   plot(100*pt2)
            %   %to see the negative of the original more easily, center
            %   %right side on 0
            %   set(gca,'YLim',[-120 120])
            %       
            
            in.simplify = true;
            in.output_type = 'voltage';
            in.sync_amp = 1;
            in = mcs.sl.in.processVarargin(in,varargin);
            %copy, then take absolute value and simplify
            %   - abs() can create neighboring segments with the same
            %     amplitude
            %
            new_obj = abs(copy(obj));
            if in.simplify
                new_obj = simplify(new_obj);
            end
            
            new_obj.amplitudes(new_obj.amplitudes ~= 0) = in.sync_amp;
            new_obj.output_type = in.output_type;
        end
        function varargout = addLeadingZeroTime(obj,t)
            %x Adds stim at 0 amplitude at beginning of pattern
            %
            %   %#1 In place modification:
            %       pt.addLeadingZeroTime(t)
            %
            %   %#2 Modification of copy
            %       pt2 = pt.addLeadingZeroTime(t)
            %
            %   Inputs
            %   ------
            %   t : scalar
            %   
            %   See Also
            %   --------
            %   prependValues     
            
            if nargout
                obj = copy(obj);
            end
            
            stim_amp = 0;
            obj.prependValues(stim_amp,t);
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = prependValues(obj,amplitudes,durations)
            %x Add amplitude/duration pairs to the beginning of the train
            %
            %   %#1 Modify in place
            %   pt.prependValues(amplitudes,durations)
            %
            %   %#2 Modify a copy
            %   pt2 = pt1.prependValues(amplitudes,durations)
            %
            %   Inputs
            %   ------
            %   amplitudes :
            %   durations :
            %
            %   Example
            %   -------
            %   pt1 = mcs.stg.pulse_train.fixed_rate(40);
            %   amplitudes = [-1 1 0];
            %   durations = [1 1 100]/1000;
            %   pt2 = pt1.prependValues(amplitudes,durations);
            %   plot(pt2)
            %
            %   See Also
            %   --------
            %   addLeadingZeroTime
            
            if nargout
                obj = copy(obj);
            end
            
            obj.amplitudes = [amplitudes obj.amplitudes];
            obj.durations = [durations obj.durations];
            h__initTimes(obj);
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = appendValues(obj,amps,durations)
            %x Add amplitude/duration pairs to the end of the train
            %
            %   %#1 Modify in place
            %   pt.appendValues(amplitudes,durations)
            %
            %   %#2 Modify a copy
            %   pt2 = pt1.appendValues(amplitudes,durations)
            %
            %   Inputs
            %   ------
            %   amplitudes :
            %   durations :
            %
            %   Example
            %   -------
            %   pt1 = mcs.stg.pulse_train.fixed_rate(40);
            %   amplitudes = [-1 1 0];
            %   durations = [1 1 100]/1000;
            %   pt2 = pt1.appendValues(amplitudes,durations);
            %   plot(pt2)
            %
            %   See Also
            %   --------
            %   prependValues
            
            if nargout
                obj = copy(obj);
            end
            
            obj.amplitudes = [obj.amplitudes amps];
            obj.durations = [obj.durations durations];
            h__initTimes(obj);
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = simplify(obj)
            %x Merge repeated amplitudes into one with single duration value
            %
            %   Calling Forms
            %   -------------
            %   %#1 Modify in-place
            %   pt.simplify();
            %
            %   %#2 Modify a copy
            %   pt2 = pt1.simplify();
            %
            %   Example
            %   -------
            %   pt = mcs.stg.pulse_train.fixed_rate(10,'n_pulses',10);
            %   pt2 = abs(pt);
            %   pt3 = pt2.simplify();
            %   plot(pt2)
            %   hold on
            %   plot(pt3)
            %   hold off
            %   legend('original','simplified')
            %   title(sprintf('Number of points in original vs simplified %d vs %d',pt2.n_samples,pt3.n_samples))
            %
            
            if nargout
                obj = copy(obj);
            end
            
            amplitudes_local = obj.amplitudes;
            durations_local = obj.durations;
            
            target_I = 1;
            for i = 2:length(amplitudes_local)
                if amplitudes_local(i) == amplitudes_local(target_I)
                    %If same amplitude as the current target, then just
                    %add their durations
                    durations_local(target_I) = durations_local(target_I) + durations_local(i);
                elseif durations_local(i) == 0
                    %remove - don't need to do anything ...
                else
                    %Create a new entry
                    target_I = target_I + 1;
                    amplitudes_local(target_I) = amplitudes_local(i);
                    durations_local(target_I) = durations_local(i);
                end
            end
            
            obj.amplitudes = amplitudes_local(1:target_I);
            obj.durations = durations_local(1:target_I);
            h__initTimes(obj);
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = abs(obj)
            %x Rectifies all stimuli
            %
            %   %#1 modify in place
            %   pt.abs()
            %
            %   %#2 modify a copy
            %   pt2 = abs(pt1)
            %
            %   Written to help in creating sync signal
            %
            
            if nargout
                obj = copy(obj);
            end
            
            obj.amplitudes = abs(obj.amplitudes);
            
            if nargout
                varargout{1} = obj;
            end
        end
        %TODO: Create getSampledArrays function which takes in multiple
        %pulse train objects
        %[amplitudes,dt,time_array] = getSampledArrays(obj1,other_objects,dt,varargin)
        %
        %   other_objects - either a cell array or regular array
        %
        %   gets shared dt and also does a duration check
        %
        %   output units
        
        function [amplitude,dt,time_array] = getSampledArray(obj,dt,varargin)
            %x Helper function for returning array as samples ...
            %
            %   [amplitude,dt] = obj.getSampledArray(dt,varargin)
            %
            %   Inputs
            %   ------
            %   dt : scalar
            %       Time between samples, in seconds.
            %       A value of -1 computes largest possible dt
            %
            %
            %   Optional Inputs
            %   ---------------
            %   output_current_units : default 'uA'
            %   output_voltage_units : default 'mV'
            %
            %   Outputs
            %   -------
            %   amplitude :
            %   dt :
            %       Time between samples that was used for amplitude
            %
            %               %start at dt                    %start at 0
            %   NOTE: t = (1:length(amplitude)).*dt OR (0:length(amplitude)-1).*dt
            %
            %   Examples
            %   ---------
            %   %#1 ... Basic Example
            %   % 3 pulses at 40 Hz, repeated at 2 Hz train rate
            %   pt2 = mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2,'trains_duration',30);
            %   %User specified value
            %   dt = 100/1e6; %100 us
            %   amp = pt2.getSampledArray(dt);
            %   t = (0:length(amp)-1).*dt;
            %   stairs(t,amp) %Not plotted as sample and hold ...
            %   hold on
            %   plot(pt2) %This will have sample and hold ...
            %   hold off
            %   legend('sampled','original')
            %
            %   %#2 ... Let code figure out best dt
            %   [amp,dt] = pt2.getSampledArray(-1);
            
            in.output_current_units = '';
            in.output_voltage_units = '';
            in = mcs.sl.in.processVarargin(in,varargin);
            
            %local copies for faster reference
            amplitudes_local = obj.amplitudes;
            
            if strcmp(obj.output_type,'current')
                if ~isempty(in.output_voltage_units)
                    error('For current stimulus not expecting voltage units')
                end
                switch lower(in.output_current_units)
                    case 'ma'
                        amplitudes_local = amplitudes_local.*0.001;
                    case {'ua' ''}
                        %nothing
                    case 'na'
                        amplitudes_local = amplitudes_local.*1000;
                    otherwise
                        error('Unhandled format')
                end
            else
                if ~isempty(in.output_current_units)
                    error('For voltage stimulus not expecting current units')
                end
                switch lower(in.output_voltage_units)
                    case 'v'
                        amplitudes_local = amplitudes_local.*0.001;
                    case {'mv',''}
                        %nothing
                    case 'uv'
                        amplitudes_local = amplitudes_local.*1000;
                    otherwise
                        error('Unhandled format')
                end
            end
            
            
            durations_local = obj.durations;
            
            %If dt == -1, then calculate best dt
            %-----------------------------------------------
            if dt == -1
                dt = h__getDTforDurations(durations_local);
            end
            
            if any(mod(dt,obj.min_time_dt) ~= 0)
                error('dt for sampling is not a multiple of the minimum dt value')
            end
            
            if ~all(mod(obj.durations,dt) == 0)
                error('Not all durations are multiples of dt')
            end
            
            %Population of amplitude array
            %----------------------------------------------------
            %Note, per check above these are all whole numbers
            n_samples_per_duration = durations_local./dt;
            n_samples_total = sum(n_samples_per_duration);
            
            amplitude = zeros(1,n_samples_total);
            end_I = 0;
            for i = 1:length(amplitudes_local)
                start_I = end_I + 1;
                end_I = end_I + n_samples_per_duration(i);
                amplitude(start_I:end_I) = amplitudes_local(i);
            end
            
            if nargout == 3
                time_array = (0:length(amplitude)-1).*dt;
            end
            
        end %end getSampledArray
        function dt = getDTforPatterns(obj,varargin)
            %x Computes a shared dt appropriate for multiple patterns
            %
            %   getDTforPatterns(pt1,pt2,pt3,...)
            %
            %   Inputs
            %   ------
            %   pt1,pt2,pt3 : stimulus pulse train patterns
            %
            %       As many pulse trains as desired can be entered.
            %
            %   Example
            %   -------
            %   %TODO
            %   w = 
            
            all_durations_ca = cell(1,nargin);
            all_durations_ca{1} = obj.durations;
            for i = 2:nargin
                all_durations_ca{i} = unique(varargin{i-1}.durations);
            end
            
            all_durations = [all_durations_ca{:}];
            
            dt = h__getDTforDurations(all_durations);
        end %end getDTforPatterns
        function [a,d] = getStimValues(obj)
            %x Get amplitude and duration pairs for uploading to stimulator
            %
            %   This is for uploading to the MCS stimulator.
            %
            %   We convert to integers for upload.
            %
            %   Expected format for MCS stimulator
            %   ----------------------------------
            %   1 nA int32
            %   1 uV int32
            %   1 us uint64
            %
            %   Outputs
            %   -------
            %   a : amplitude array [int32]
            %   d : duration array [uint64]
            % 
            %   Examples
            %   ---------
            %   %#1 fail durations check
            %   %100 us phase width by default
            %   pt = mcs.stg.pulse_train.fixed_rate(10,'min_time_dt',20/1e6);
            %   %Expand by 15 us, not a multiple of the dt
            %   pt.rightExpandDurations(15/1e6);
            %   [a,d] = pt.getStimValues();
            %
            
            %   Internally we are using units of:
            %   - mV => goes to uV => x1000
            %   - uA => goes to nA => x1000
            %   - s => goes to  us => x1e6
            
            if any(mod(obj.durations,obj.min_time_dt) ~= 0)
                error('dt for sampling is not a multiple of the minimum dt value')
            end
            
            a = int32(1000*obj.amplitudes);
            d = uint64(1e6*obj.durations);
                        
        end %end getStimValues
        function varargout = normalizeToPlusMinusOne(obj)
            %x
            %
            %   Scale amplitude so max absolute amp is at either 1 or -1
            %
            
            if nargout
                obj = copy(obj);
            end
            
            obj = copy(obj);
            a = max(abs(obj.amplitudes));
            obj.amplitudes = obj.amplitudes./a;
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = repeat(obj,n)
            %x   Replicate the pulse train 'n' times
            %
            %   Calling Forms
            %   -------------
            %   %#1 Modify in place
            %   pt.repeat(n)
            %
            %   %#2 Modify copy
            %   pt2 = pt1.repeat(n)
            %
            %   Inputs
            %   ------
            %   n : scalar
            %       # of times to repeat the signal
            %
            %   Example
            %   -------
            %   pt = mcs.stg.pulse_train.fromTimes([3 5 6]);
            %   pt2 = pt.repeat(3);
            %   plot(pt2)
            %   hold on
            %   plot(pt)
            %   hold off
            %   legend('repeated','original')
            
            if nargout
                obj = copy(obj);
            end
            
            obj.amplitudes = repmat(obj.amplitudes,[1 n]);
            obj.durations = repmat(obj.durations,[1 n]);
            h__initTimes(obj);
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = addValue(obj,amplitude,duration)
            %x Adds single amplitude/duration value at the end of the train
            %
            %   Calling Forms
            %   -------------
            %   %#1 Modify in place
            %   pt.addValue(amplitude,duration)
            %
            %   %#2 Modify copy
            %   pt2 = pt1.addValue(amplitude,duration)
            %
            %   Inputs
            %   ------
            %   amplitude : scalar
            %   duration : scalar
            %
            %   Example
            %   -------
            %
            %
            %   See Also
            %   --------
            
            if nargout
                obj = copy(obj);
            end
            
            if length(amplitude) ~= 1 || length(duration) ~= 1
                error('Invalid length of input arguments')
            end
            
            obj.amplitudes = [obj.amplitudes amplitude];
            obj.durations = [obj.durations duration];
            obj.start_times = [obj.start_times obj.stop_times(end)];
            obj.total_duration_s = obj.total_duration_s + duration;
            obj.stop_times = [obj.stop_times obj.total_duration_s];
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = dropLastValue(obj)
            %x Removes last amplitude/duration pair
            %
            %   Although public this is a bit of a helper function
            %   for merging trains
            
            if nargout
                obj = copy(obj);
            end
            
            obj.amplitudes(end) = [];
            temp = obj.durations(end);
            obj.durations(end) = [];
            obj.start_times(end) = [];
            obj.stop_times(end) = [];
            obj.total_duration_s = obj.total_duration_s - temp;
            
            if nargout
                varargout{1} = obj;
            end
        end
        function varargout = plot(obj)
            %x Plot the stimuli
            %
            %   h = plot(obj)
            
            %This is to create a sample and hold look
            temp = [obj.start_times(:) obj.stop_times(:)]';
            temp2 = [obj.amplitudes(:) obj.amplitudes(:)]';
            
            h = plot(temp(:),temp2(:));
            mcs.sl.plot.postp.scaleAxisLimits();
            if strcmp(obj.output_type,'current')
                ylabel('Current (uA)')
            else %voltage
                ylabel('Voltage (mV)')
            end
            xlabel('Time (s)')
            
            if nargout
                varargout{1} = h;
            end
        end
        function out = mtimes(a,b)
            %x Multiply by scalar
            %
            %   This allows us to scale the amplitude of the stimulus
            %   by a given value.
            %
            %   Example
            
            
            %TODO: check the other input type ... 'm'
            if isobject(a)
                m = b;
                obj = a;
            else
                m = a;
                obj = b;
            end
            
            out = copy(obj);
            out.amplitudes = m*out.amplitudes;
        end
        %Using mixin for now ... (implements copying for me)
        %         function new_object = copy(obj)
        %             new_object = mcs.stg.pulse_train();
        %
        %         end
    end
    
end

function h__initTimes(obj)

%TODO: Should really use a dirty flag - low priority
csum = cumsum(obj.durations);
obj.start_times = [0 csum(1:end-1)];
obj.stop_times = csum;
obj.total_duration_s = csum(end);

end

function dt = h__getDTforDurations(durations)
%Round to ns resolution ...
temp_durations = round(1e9*durations);

%Not sure if this is the quickest approach ...
%We could compute gcd over all values but I think this
%would be slower ...
u_durations = unique(temp_durations);
%find gcd for each value versus smallest value
%(which may be the gcd)
%u_durations = [100000    24850000   449800000];
%gcd would be 50000
dt = min(gcd(u_durations,min(u_durations)));
dt = dt/1e9; %Go back to seconds
end
