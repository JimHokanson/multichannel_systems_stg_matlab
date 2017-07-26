classdef pulse_train
    %
    %   
    
    %{
    
    %Amplitude - default 1 uA
    %Waveform - biphasic
    %   - 1 uA
    %   - 100 us per pulse
    
    
    pt1 = mcs.stg.pulse_train.fixed_rate(10);
    pt2 = mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2);
    
    
    pt = mcs.stg.pulse_train.fixed_rate(rate,varargin)
    
        Related
        - pulse_amplitude
        - pulse_duration
        - waveform
    
        Related
        - n pulses
        - train_duration (s)
            - what does this mean - time to start of last pulse?
        - terminate - add zeros at end for regularity
        - train_rate - 
    
        TODO: We can have the concept of content, where we repeat content
        at a given rate
    
    
    
    
    properties
        - summary string?
    
    methods
        - scale - create new pulse ...
        - repeatRate
    
    %}
    
    properties
        amplitudes
        durations
        times
    end
    
    methods (Static)
        function obj = fixed_rate(rate,varargin)
            
%     pt1 = mcs.stg.pulse_train.fixed_rate(10);
%     pt2 = mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2);
%     
%     
%     pt = mcs.stg.pulse_train.fixed_rate(rate,varargin)
%     
%         Related
%         - pulse_amplitude
%         - pulse_duration
%         - waveform
%     
%         Related
%         - n pulses
%         - train_duration (s)
%             - what does this mean - time to start of last pulse?
%         - terminate - add zeros at end for regularity
%         - train_rate -
        end
    end
    
end

