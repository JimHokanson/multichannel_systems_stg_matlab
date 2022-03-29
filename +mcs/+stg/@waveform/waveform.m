classdef waveform < handle
    %
    %   Class:
    %   mcs.stg.waveform
    %
    %   A collection of amplitudes and durations.
    %
    %   Constructors
    %   ------------
    %   mcs.stg.waveform.monophasic
    %   mcs.stg.waveform.biphasic
    %   mcs.stg.waveform.custom
        
    properties
        d0 = '----------- read only properties ----------'
        output_type     %'current' or 'voltage'
        
        shape_type %Not used, just for the user's reference
        %- monophasic
        %- biphasic
        %- sinusoid - NYI
        %- custom
        
        %This will all be in standard units
        amplitudes %array of stimulation amplitude values    
        internal_amp_units %either uA or mV
        
        durations_ms   %ms
        durations_s %For reasons that are unclear to me know this is a
        %duplication of the durations
        
        start_times_ms %ms
        stop_times_ms %ms
        total_duration_ms
        total_duration_s
        
        
        d1 = '--------------  Used only when plotting  -------------'
        %Note, the amp unit is now also used by the pulse train
        %for the choice of default units
        user_amp_units
        user_duration_units
    end
    
    properties (Hidden)
        %These are scalar values that convert from the internal units
        %of this class to the user specified units in order to display
        %the data.
        amp_scalar__prop_to_disp
        dur_scalar__prop_to_disp
    end
    
    methods (Static)
        function obj = monophasic(amplitude,duration,varargin)
         	%
            %   obj = mcs.stg.waveform.monophasic(amplitude,duration,varargin)
            %
            %   Inputs
            %   ------
            %   amplitude : 
            %   duration : 
            %
            %   Optional Inputs
            %   ---------------
            %   amp_units : 
            %       - 'mA'
            %       - 'uA' (default)
            %       - 'nA'
            %       - 'V'
            %       - 'mV'
            %       - 'uV'
            %   duration_units : 
            %       - 's'
            %       - 'ms' (default)
            %       - 'us'
            %
            %   Example
            %   ---------------------
            %   %1 uA, 0.1 ms duration
            %   w = mcs.stg.waveform.monophasic(1,0.1)
            %
            %   %+/- 1 mA, 100 us duration each
            %
            %   Improvements
            %   ------------
            %   1) Allow ratio/duration scaling
            %   2) Allow spacing between pulses
            
            in.amp_units = 'uA';
            in.duration_units = 'ms';
            in = mcs.sl.in.processVarargin(in,varargin);
            
            obj = mcs.stg.waveform();
            obj.shape_type = 'monophasic';
            
            h__processAmplitudes(obj,amplitude,in.amp_units)
            
            h__processDurations(obj,duration,in.duration_units)
        end
        function obj = biphasic(amplitude,duration,varargin)
            %
            %   obj = mcs.stg.waveform.biphasic(amplitude,duration,varargin)
            %
            %   Inputs
            %   ------
            %   amplitude : scalar
            %   duration : scalar
            %
            %   Optional Inputs
            %   ---------------
            %   amp_units : 
            %       - 'mA'
            %       - 'uA' (default)
            %       - 'nA'
            %       - 'V'
            %       - 'mV'
            %       - 'uV'
            %   duration_units : 
            %       - 's'
            %       - 'ms' (default)
            %       - 'us'
            %
            %   Example
            %   ---------------------
            %   %1 uA, 0.1 ms duration
            %   w = mcs.stg.waveform.biphasic(1,0.1)
            %
            %   %+/- 1 mA, 100 us duration each
            %
            %   Improvements
            %   ------------
            %   1) Allow ratio/duration scaling
            %   2) Allow spacing between pulses
            
            in.amp_units = 'uA';
            in.duration_units = 'ms';
            in = mcs.sl.in.processVarargin(in,varargin);
            
            obj = mcs.stg.waveform();
            obj.shape_type = 'biphasic';
            
            amplitudes = [amplitude -amplitude];
            
            h__processAmplitudes(obj,amplitudes,in.amp_units)
            
            durations = [duration duration];
            h__processDurations(obj,durations,in.duration_units)
        end
        %TODO: Sinusoid ...
        function obj = custom(amplitudes,durations,varargin)
            %
            %   obj = mcs.stg.waveform.custom(amplitudes,durations,varargin)
            %
            %   Inputs
            %   ------
            %   amplitudes : 
            %       Array of stimulus amplitudes.
            %   durations :
            %       Array of stimulus durations, one per amplitude.
            %
            %   Optional Inputs
            %   ---------------
            %   amp_units : 
            %       - 'mA'
            %       - 'uA' (default)
            %       - 'nA'
            %       - 'V'
            %       - 'mV'
            %       - 'uV'
            %   duration_units : 
            %       - 's'
            %       - 'ms' (default)
            %       - 'us'
            %
            %   Example
            %   ---------------------
            %   %Creating a saw tooth like pattern ...
            %   durations = 100*ones(1,10);
            %   amplitudes = 1:10;
            %   amplitudes = amplitudes - mean(amplitudes);
            %   w = mcs.stg.waveform.custom(amplitudes,durations,'duration_units','us')
            %
            %   %+/- 1 mA, 100 us duration each
            %
            in.amp_units = 'uA';
            in.duration_units = 'ms';
            in = mcs.sl.in.processVarargin(in,varargin);
            
            obj = mcs.stg.waveform();
            obj.shape_type = 'custom';
            
            h__processAmplitudes(obj,amplitudes,in.amp_units)
            
            h__processDurations(obj,durations,in.duration_units)
        end
    end
    
    methods
        function plot(obj)
            %x Plots waveform in user specified units
            %
            % 
            
            plot_amplitudes = obj.amplitudes * obj.amp_scalar__prop_to_disp;
            plot_starts = obj.start_times_ms*obj.dur_scalar__prop_to_disp;
            plot_ends = obj.stop_times_ms*obj.dur_scalar__prop_to_disp;
            
            %This get's us a sample and hold pattern, by replicating
            %the amplitude twice, once at the start and once at the end
            temp = [plot_starts(:) plot_ends(:)]';
            temp2 = [plot_amplitudes(:) plot_amplitudes(:)]';
            
            %Let's have everything start and return to 0
            %=> without this monophasic is a line 
            temp = [plot_starts(1); temp(:); plot_ends(end)];
            temp2 = [0; temp2(:); 0];
            
            plot(temp,temp2);
            mcs.sl.plot.postp.scaleAxisLimits();
            ylabel(sprintf('Amplitude (%s)',obj.user_amp_units))
            xlabel(sprintf('Duration (%s)',obj.user_duration_units))
        end
    end
    
end

function h__processDurations(obj,durations,duration_units)
    switch lower(duration_units)
        case 's'
            obj.user_duration_units = 's';
            obj.durations_ms = 1000*durations;
            obj.dur_scalar__prop_to_disp = 1/1000;
        case 'ms'
            obj.user_duration_units = 'ms';
            obj.durations_ms = durations;
            obj.dur_scalar__prop_to_disp = 1;
        case 'us'
            obj.user_duration_units = 'us';
            obj.durations_ms = durations/1000;
            obj.dur_scalar__prop_to_disp = 1000;
        otherwise
            error('Unrecognized units: %s',duration_units)
    end
      
    csum = cumsum(obj.durations_ms);
	obj.start_times_ms = [0 csum(1:end-1)];
 	obj.stop_times_ms = csum;
    obj.total_duration_ms = csum(end);
    obj.total_duration_s = obj.total_duration_ms/1000;
    obj.durations_s = obj.durations_ms/1000;

end

function h__processAmplitudes(obj,amplitudes,amp_units)
    %amplitudes     %uA or mV
    
    %Standard units
    %--------------
    %mV
    %uA
    
    %TODO: Handle resolution of device ...
    %
    %Make this a method that allows for post-processing ...
    
    
    switch lower(amp_units)
        case 'v'
            obj.output_type = 'voltage';
            obj.user_amp_units = 'V';
            obj.amplitudes = 1000*amplitudes;
            obj.amp_scalar__prop_to_disp = 1/1000;
        case 'mv'
            obj.output_type = 'voltage';
            obj.user_amp_units = 'mV';
        	obj.amplitudes = amplitudes;
            obj.amp_scalar__prop_to_disp = 1;
        case 'uv'
            obj.output_type = 'voltage';
            obj.user_amp_units = 'uV';
            obj.amplitudes = amplitudes/1000;
            obj.amp_scalar__prop_to_disp = 1000;
        case 'ma'
            obj.output_type = 'current';
            obj.user_amp_units = 'mA';
            obj.amplitudes = 1000*amplitudes;
            obj.amp_scalar__prop_to_disp = 1/1000;
        case 'ua'
            obj.output_type = 'current';
            obj.user_amp_units = 'uA';
        	obj.amplitudes = amplitudes;
            obj.amp_scalar__prop_to_disp = 1;
        case 'na'
            obj.output_type = 'current';
            obj.user_amp_units = 'nA';
            obj.amplitudes = amplitudes/1000;
            obj.amp_scalar__prop_to_disp = 1000;
        otherwise
            error('Unrecognized units: %s',amp_units)  
    end
    
    switch obj.output_type
        case 'voltage'
            obj.internal_amp_units = 'mV';
        case 'current'
            obj.internal_amp_units = 'uA';
    end
    
end

