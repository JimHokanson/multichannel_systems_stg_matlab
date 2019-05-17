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
        
    properties
        output_type     %'current' or 'voltage'
        
        shape_type %Not used, just for reference
        %- monophasic
        %- biphasic
        %- arbitrary - NYI
        
        %This will all be in standard units
        amplitudes     
        internal_amp_units %either uA or mV
        
        durations_ms   %ms
        durations_s
        
        start_times_ms %ms
        stop_times_ms %ms
        total_duration_ms
        total_duration_s
        
        
        d = '--------------  Used only when plotting  -------------'
        plot_amp_units
        plot_duration_units
    end
    
    properties (Hidden)
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
    end
    
    methods
        function plot(obj)
            plot_amplitudes = obj.amplitudes * obj.amp_scalar__prop_to_disp;
            plot_starts = obj.start_times_ms*obj.dur_scalar__prop_to_disp;
            plot_ends = obj.stop_times_ms*obj.dur_scalar__prop_to_disp;
            
            temp = [plot_starts(:) plot_ends(:)]';
            temp2 = [plot_amplitudes(:) plot_amplitudes(:)]';
            
            plot(temp(:),temp2(:));
            mcs.sl.plot.postp.scaleAxisLimits();
            ylabel(sprintf('Amplitude (%s)',obj.plot_amp_units))
            xlabel(sprintf('Duration (%s)',obj.plot_duration_units))
        end
    end
    
end

function h__processDurations(obj,durations,duration_units)
    switch lower(duration_units)
        case 's'
            obj.plot_duration_units = 's';
            obj.durations_ms = 1000*durations;
            obj.dur_scalar__prop_to_disp = 1/1000;
        case 'ms'
            obj.plot_duration_units = 'ms';
            obj.durations_ms = durations;
            obj.dur_scalar__prop_to_disp = 1;
        case 'us'
            obj.plot_duration_units = 'us';
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
            obj.plot_amp_units = 'V';
            obj.amplitudes = 1000*amplitudes;
            obj.amp_scalar__prop_to_disp = 1/1000;
        case 'mv'
            obj.output_type = 'voltage';
            obj.plot_amp_units = 'mV';
        	obj.amplitudes = amplitudes;
            obj.amp_scalar__prop_to_disp = 1;
        case 'uv'
            obj.output_type = 'voltage';
            obj.plot_amp_units = 'uV';
            obj.amplitudes = amplitudes/1000;
            obj.amp_scalar__prop_to_disp = 1000;
        case 'ma'
            obj.output_type = 'current';
            obj.plot_amp_units = 'mA';
            obj.amplitudes = 1000*amplitudes;
            obj.amp_scalar__prop_to_disp = 1/1000;
        case 'ua'
            obj.output_type = 'current';
            obj.plot_amp_units = 'uA';
        	obj.amplitudes = amplitudes;
            obj.amp_scalar__prop_to_disp = 1;
        case 'na'
            obj.output_type = 'current';
            obj.plot_amp_units = 'nA';
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

