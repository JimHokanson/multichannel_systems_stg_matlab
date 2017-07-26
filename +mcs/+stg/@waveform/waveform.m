classdef waveform
    %
    %   Class:
    %   mcs.stg.waveform
    
    %{
    

    
    
    
    waveform
        - replicatable - becomes waveforms
    waveforms - with spacing
        - convertable to pattern
        - replicatable
    
    
    
    
    
    pulse_train
        - regular, rate based
        - nested?
            - for bursting
    
    
    
    
        - 3 pulses
        - 
    %}
    
    properties
        type
        %- monophasic
        %- biphasic
        %- arbitrary
        amplitudes
        durations
    end
    
    methods (Static)
        %Make a class?
        function biphasic(amplitude,duration)
            
        end
    end
    
end

