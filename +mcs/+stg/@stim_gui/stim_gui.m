classdef stim_gui
    %
    %   Class:
    %   mcs.stg.stim_gui
    %
    %   See Also
    %   --------
    %   mcs.stimGUI
    %
    %   
    
    %Handles
    %---------------
    %- amplitude
    %- frequency
    %- pulse_width
    %- stim
    %- pw_units
    %- amp_units
    %
    %SOME MAY BE MISSING
    
    properties
        h %GUI handles
        h_stim %Handle to stimulator
    end
    
    methods
        function obj = stim_gui(varargin)
            
            %TODO: Expose these as options in mcs.stimGUI
            in.stimulator_id = 1; %Which stimulator to use
            in.n_repeats_all = 0; %might expose this in the GUI itself
            %0 - run forever
            %1+ - run a specific # of times
            in = sl.in.processVarargin(in,varargin);
            
            obj.h = mcs.stg.stim_gui_app();
            
            
            try
                h_stim = mcs.getStimulator(in.stimulator_id);
            catch ME
                %fprintf(2,'Please close the figure ...\n');
                
                %{
                ****
                If the device is locked usually this can be fixed by
                closing the figure that holds the stimulator. Worse case
                scenario you can close MATLAB or maybe trying power cycling
                the stimulator.
                
                %}
                rethrow(ME)
            end
            h_stim.setupTrigger('linearize',true,'repeat_all',in.n_repeats_all);
            obj.h_stim = h_stim;
            
            %TODO: show this in the GUI, maybe as the figure name
            %obj.serial = h_stim.serial_number; %as string
            
        end
        function startStopStim(obj)
            %mcs.stg.waveform.biphasic
            %mcs.stg.pulse_train.fixed_rate
            
            %Get patterns if starting stim
            %call startStimDevice or stopStimDevice
        end
     	function startStimDevice(obj,chan_id,pattern,varargin)
            %
            %   This is what actually communicates with the stimulator.
            %   
            %   
            %
            %   Inputs
            %   ------
            %   chan_id : array of channels
            %   pattern : cell array of patterns
            %
            %   O
            
            %TODO: 
            in.n_repeats_all = 0;
            in = sl.in.processVarargin(in,varargin);
            
            if ~iscell(pattern)
                pattern = {pattern};
            end
            
            % :/ Unfortunately we need to change this for running
            % this a certain # of times ...

            obj.h_stim.setupTrigger('linearize',true,'repeat_all',in.n_repeats_all);
            obj.h_stim.sentDataToDevice(chan_id,pattern);
            obj.h_stim.startStim('triggers',chan_id);
        end
        function stopStimDevice(obj,chan_id)
            %chan_id - array of channels
            obj.h_stim.stopStim('triggers',chan_id);
        end
    end
end

