classdef stim_gui < handle
    %
    %   Class:
    %   mcs.stg.stim_gui
    %
    %   See Also
    %   --------
    %   mcs.stimGUI
    %
    %   Improvements
    %   ------------
    %   1) Expose monophasic option
    %   2) Fix # of channels per device - make this dynamic based on device
    %   3) Disable controls while stimulating - don't want to turn off
    %   wrong channel
    
    %{
    mcs.stimGUI
    %}
    
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
        %mcs.stg.sdk.cstg200x_download
        stim_flag
    end

    properties (Dependent)
        save_path
    end

    methods
        function value = get.save_path(obj)
            device_info = obj.h_stim.device_info;
            package_root = sl.stack.getPackageRoot();
            save_root = sl.dir.createFolderIfNoExist(package_root,'temp_data','stim_gui');
            chan_id = obj.h.chan_selector.Value;
            file_name = sprintf('%s_%02d.mat',device_info.serial_number,chan_id);
            value = fullfile(save_root,file_name);
        end
    end
    
    methods
        
        function obj = stim_gui(varargin)
            
            %TODO: Expose these as options in mcs.stimGUI
            in.stimulator_id = 1; %Which stimulator to use
            in.n_repeats_all = 0; %might expose this in the GUI itself
            %0 - run forever
            %1+ - run a specific # of times
            in = mcs.sl.in.processVarargin(in,varargin);
            
            obj.h = mcs.stg.stim_gui_app();

            %{
            h = struct;
            h_fig = uifigure();
            h.amplitude = uieditfield(h_fig,"numeric",'')
            %}

            %GUI SETUP HERE
            obj.h.amplitude;
            obj.h.frequency;
            obj.h.pulse_width;
            obj.h.chan_selector;
            obj.h.amp_units.ValueChangedFcn = @(~,~)obj.saveParams();
            obj.h.amp_units.ItemsData = obj.h.amp_units.Items;
            obj.h.pw_units.ValueChangedFcn = @(~,~)obj.saveParams();
            obj.h.pw_units.ItemsData = obj.h.pw_units.Items;
            obj.h.startstim.ButtonPushedFcn = @(~,~)obj.startStim();
            obj.h.stopstim.ButtonPushedFcn = @(~,~)obj.StopStim();
            obj.h.stopstim.Position = obj.h.startstim.Position;
            obj.h.stopstim.Visible = 'off';
            obj.h.amplitude.ValueChangedFcn = @(~,~)obj.saveParams();
            obj.h.frequency.ValueChangedFcn = @(~,~)obj.saveParams();
            obj.h.pulse_width.ValueChangedFcn = @(~,~)obj.saveParams();
            
            %obj.chan_id = obj.h.chan_selector.Value;
            % chan_id = obj.chan_id;
            
            
            obj.stim_flag = false;
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
            %        function delete(obj)
            %    obj.h = [];
            
            %  end
            
            device_info = h_stim.device_info;
            label_string = sprintf('%s:%s',device_info.device_name,device_info.serial_number);
            uilabel(obj.h.UIFigure,'Text',label_string,'Position',[130 275 100 20]);


            if ~h_stim.device_info.is_stg5
                h_stim.setupTrigger('linearize',true,'repeat_all',in.n_repeats_all);
            end

            obj.h_stim = h_stim;
            %Has to occur after stimulator loads
            obj.loadParams;
            
            %TODO: show this in the GUI, maybe as the figure name
            %obj.serial = h_stim.serial_number; %as string
            
            %TODO: Set # of channels in the GUI based on:
            %h_stim.n_analog_channels
            

            
        end
        function loadParams(obj)
            if exist(obj.save_path,'file')
                s = load(obj.save_path);
                try
                    obj.h.amplitude.Value = s.amplitude;
                catch
                    fprintf(2,'Amp loading failed\n');
                end
                try
                    obj.h.frequency.Value = s.frequency;
                catch
                    fprintf(2,'Freq loading failed\n');
                end
                try
                    obj.h.pulse_width.Value = s.pulse_width;
                catch
                    fprintf(2,'PW loading failed\n');
                end
                try
                    obj.h.amp_units.Value = s.amp_units;
                catch
                    fprintf(2,'amp_units loading failed\n');
                end
                try
                    obj.h.pw_units.Value = s.pw_units;
                catch
                    fprintf(2,'PW_units loading failed\n');
                end
            end
        end
        function saveParams(obj)
            s = struct;
            s.amplitude = obj.h.amplitude.Value;
            s.frequency = obj.h.frequency.Value;
            s.pulse_width = obj.h.pulse_width.Value;
            s.amp_units = obj.h.amp_units.Value;
            s.pw_units = obj.h.pw_units.Value;

            save(obj.save_path,'-struct','s')
        end

        %{

        function loadAmplitudeFromDisk(obj)
            AmplitudeFile_path = obj.getAmplitudeSavePath();
            if exist(AmplitudeFile_path,'file')
                h2 = load(AmplitudeFile_path);
                s = h2.s;
                obj.h.amplitude.Value = s.amplitude;
            end
        end
        function loadFrequencyFromDisk(obj)
            FrequencyFile_path = obj.getFrequencySavePath();
            if exist(FrequencyFile_path,'file')
                h2 = load(FrequencyFile_path);
                s = h2.s;
                
            end
        end
        function loadPulse_WidthFromDisk(obj)
            Pulse_WidthFile_path = obj.getPulse_WidthSavePath();
            if exist(Pulse_WidthFile_path,'file')
                h2 = load(Pulse_WidthFile_path);
                s = h2.s;
                obj.h.pulse_width.Value = s.pulse_width;
            end
        end
        function saveAmplitudeToDisk(obj)
            AmplitudeFile_path = obj.getAmplitudeSavePath();
            s = struct;
            s.amplitude = obj.h.amplitude.Value;
            save(AmplitudeFile_path,'s');
        end
        function saveFrequencyToDisk(obj)
            FrequencyFile_path = obj.getFrequencySavePath();
            s = struct;
            s.frequency = obj.h.frequency.Value;
            save(FrequencyFile_path,'s');
        end
        function savePulse_WidthToDisk(obj)
            Pulse_WidthFile_path = obj.getPulse_WidthSavePath();
            s = struct;
            s.pulse_width = obj.h.pulse_width.Value;
            save(Pulse_WidthFile_path,'s');
        end
        function AmplitudeFile_path = getAmplitudeSavePath(obj)
            package_root = sl.stack.getPackageRoot();
            save_root = sl.dir.createFolderIfNoExist(package_root,'temp_data','elite11');
            file_name = sprintf('stim_amplitude_data_%02d.mat',obj.chan_id);
            AmplitudeFile_path = fullfile(save_root,file_name);
        end
        function FrequencyFile_path = getFrequencySavePath(obj)
            package_root = sl.stack.getPackageRoot();
            save_root = sl.dir.createFolderIfNoExist(package_root,'temp_data','elite11');
            file_name = sprintf('stim_frequency_data_%02d.mat',obj.chan_id);
            FrequencyFile_path = fullfile(save_root,file_name);
        end
        function Pulse_WidthFile_path = getPulse_WidthSavePath(obj)
            package_root = sl.stack.getPackageRoot();
            save_root = sl.dir.createFolderIfNoExist(package_root,'temp_data','elite11');
            file_name = sprintf('stim_pulse_width_data_%02d.mat',obj.chan_id);
            Pulse_WidthFile_path = fullfile(save_root,file_name);
        end
        %}
        function startStim(obj)
            %mcs.stg.waveform.biphasic
            %mcs.stg.pulse_train.fixed_rate
            
            % if obj.h.start.Value == 0
            % obj.h.start.Text = 'Start Stim';
            %obj.h.start.BackgroundColor = [0 1 0];
            %chan_id = obj.h.chan_selector.Value;
            
            au = obj.h.amp_units.Value;
            amp_units = au; %au.Items{au.Value};
            % if obj.h.amp_units.Value == 1
            %     amplitude = obj.h.amplitude.Value;
            % else
            %     amplitude = 1000*obj.h.amplitude.Value;
            % end
            
            pw = obj.h.pw_units.Value;
            duration_units = pw; %pw.Items{pw.Value};
            % if obj.h.pw_units.Value == 1
            %     duration = obj.h.pulse_width.Value;
            % else
            %     duration = 1000*obj.h.pulse_width.Value;
            % end
            chan_id2 = obj.h.chan_selector.Value;
            rate = obj.h.frequency.Value;
            duration = obj.h.pulse_width.Value;
            amplitude = obj.h.amplitude.Value;
            waveform = mcs.stg.waveform.biphasic(amplitude,duration,...
                'amp_units',amp_units,'duration_units',duration_units);
            %waveform = mcs.stg.waveform.biphasic(amplitude,duration);


            pattern = mcs.stg.pulse_train.fixed_rate(rate,'waveform',waveform);
            obj.startStimDevice(chan_id2,pattern);
            obj.h.startstim.Visible= 'off';
            obj.h.stopstim.Visible= 'on';
            
            obj.stim_flag = ~obj.stim_flag;
            
        end
        
        
        function StopStim(obj)
           % chan_id=obj.h.chan_selector.Value;
            chan_id2 = obj.h.chan_selector.Value;
            obj.stopStimDevice(chan_id2);
            obj.h.startstim.Visible= 'on';
            obj.h.stopstim.Visible= 'off';
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

