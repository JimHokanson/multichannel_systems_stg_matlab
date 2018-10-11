classdef pulse_train < matlab.mixin.Copyable
    %
    %   Class:
    %   mcs.stg.pulse_train
    %
    %   Constructors
    %   ------------
    %   mcs.stg.pulse_train.fixed_rate
    %   mcs.stg.pulse_train.fromTimes
    %
    %   This holds onto a specification of a stimulus. Essentially
    %   amplitudes and durations of those amplitudes.
    %
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
    
    %{
    
    
    
    %}
        
    properties
        output_type  %'voltage' or 'current'
        
        amplitudes   %Amplitude is in uA or mV
        durations    %Durations are in seconds
        start_times
        stop_times
        total_duration_s
        
        user_summary %This is optional and can be used to keep a 
        %user-defined summary along with the pulse train.
    end
        
    methods (Static)
        function obj = fromTimes(times,varargin)
            %
            %   pt = mcs.stg.pulse_train.fromTimes(times,varargin)
            %   
            
            error('Not yet implemented')
            
            in.amp_units = 'uA';
            in.waveform = []; %mcs.stg.waveform
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(in.waveform)
                waveform = mcs.stg.waveform.biphasic(1,0.1,'amp_units',in.amp_units);
            else
                waveform = in.waveform;
            end
            
            %JAH: At this point ...
            
            keyboard
            
        end
        function obj = fixed_rate(rate,varargin)
            %
            %   obj = fixed_rate(rate,varargin)
            %
            %   Inputs
            %   ------
            %   rate : 
            %       Frequency of pulses, e.g. 20 Hz
            %
            %   Optional Inputs
            %   ---------------
            %   amp_units : string
            %       - 'mA'
            %       - 'uA' (default)
            %       - 'nA'
            %       - 'mV'
            %   waveform : default 1 amp_unit, 100 us, biphasic
            %       The waveform that gets replicated.
            %
            %   n_pulses : (default 1)
            %       # of pulses in a train. Note with only one pulse
            %       and no train, an infinite repeat will yield the desired
            %       stim rate because of the duration of zero amplitude
            %       that follows the pulse.
            %   pulses_duration : units (s)
            %       Used to compute the # of pulses in a train if n_pulses
            %       is not specified.
            %       
            %
            %   trains_rate :
            %       Rate of repetition of a series of n_pulses.
            %
            %   n_trains : Default of 1 train 
            %       
            %   trains_duration : 
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
            %   Improvements
            %   ------------
            %   1) Clarify meaning of duration (start of pulse? end of
            %   pulse? - what determines # of pulses?
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
            %   w = mcs.stg.waveform.monophasic(1,200,'amp_units','mA','duration_units','us')
            %   plot(w) %Verify this looks ok
            %   pt3 = mcs.stg.pulse_train.fixed_rate(20,'waveform',w)
            %   %Let's make it 5 mA
            %   pt3_5mA = 5*pt3;
            %
            %   % 4) 100 Hz pulses for 10 seconds
            %   pt4 = mcs.stg.pulse_train.fixed_rate(100,'pulses_duration',10)
            %   %Note, this takes up a decent amount of memory. Any longer
            %   %and it would be bettter to specify repeats of a single 
            %   %pulse.
            %
            %
            %   See Also
            %   ---------
            %   mcs.stg.waveform.biphasic
            
            ERR_ID = 'mcs:stg:pulse_train:fixed_rate';
            
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
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(in.waveform)
                %1 uA, 0.1 ms
                waveform = mcs.stg.waveform.biphasic(1,0.1,'amp_units',in.amp_units);
            else
                waveform = in.waveform;
            end
            
            %Creation of a train
            %--------------------------------------------------------------
            dt = 1/rate;
            between_pulse_dt = dt - waveform.total_duration_s;
            if between_pulse_dt < 0
               error(ERR_ID,'Stimulation rate is too high given the waveform duration')
            end
            
            if ~isempty(in.pulses_duration)
                n_pulses = floor(in.pulses_duration)/dt;
            elseif ~isempty(in.n_pulses)
                n_pulses = in.n_pulses;
            else
                n_pulses = 1;
            end
            
            obj = mcs.stg.pulse_train;
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
                    n_trains = floor(in.trains_duration)/dt;
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
        function [a,d] = getStimValues(obj)
            %
            %   This is for uploading to the stimulator.
            %
            %   We need to convert to integers for upload.
            %
            %   1 nA int32
            %   1 uV int32
            %   1 us uint64
            %
            %mV
            %uA
            a = int32(1000*obj.amplitudes);
            d = uint64(1e6*obj.durations);
        end
        function new_obj = repeat(obj,n)
        	new_obj = mcs.stg.pulse_train;
            new_obj.output_type = obj.output_type;
            new_obj.amplitudes = repmat(obj.amplitudes,[1 n]);
            new_obj.durations = repmat(obj.durations,[1 n]);
            h__initTimes(new_obj);
        end
        function addValue(obj,amplitude,duration)
            obj.amplitudes = [obj.amplitudes amplitude];
            obj.durations = [obj.durations duration];
            obj.start_times = [obj.start_times obj.stop_times(end)];
            obj.total_duration_s = obj.total_duration_s + duration;
            obj.stop_times = [obj.stop_times obj.total_duration_s];
        end
        function dropLastValue(obj)
           obj.amplitudes(end) = [];
           temp = obj.durations(end);
           obj.durations(end) = [];
           obj.start_times(end) = [];
           obj.stop_times(end) = [];
           obj.total_duration_s = obj.total_duration_s - temp;
        end
        function plot(obj)
            temp = [obj.start_times(:) obj.stop_times(:)]';
            temp2 = [obj.amplitudes(:) obj.amplitudes(:)]';
            
            plot(temp(:),temp2(:));
            sl.plot.postp.scaleAxisLimits();
        end
        function out = mtimes(a,b)
            %x Multiply by scalar
            %   
            %   This allows us to scale the object by a given value
            
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
        %Using mixin for now ...
%         function new_object = copy(obj)
%             new_object = mcs.stg.pulse_train();
%             
%         end
    end
    
end

function h__initTimes(obj)
    csum = cumsum(obj.durations);
	obj.start_times = [0 csum(1:end-1)];
 	obj.stop_times = csum;
    obj.total_duration_s = csum(end);

end
