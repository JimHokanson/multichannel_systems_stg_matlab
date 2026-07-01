classdef stim_gui < handle
    %
    %   Class:
    %   mcs.stg.stim_gui
    %
    %   See Also
    %   --------
    %   mcs.stimGUI
    %

    %{
    mcs.stimGUI
    %}

    properties
        h %GUI handles
        h_stim %Handle to stimulator
        %mcs.stg.sdk.cstg200x_download
        stim_flag
        chan_id
        channel_ids
        channel_active
        channel_controls
    end

    methods

        function obj = stim_gui(varargin)

            in.stimulator_id = 1; %Which stimulator to use
            in.channels = [];
            in = mcs.sl.in.processVarargin(in,varargin);

            obj.stim_flag = false;

            h_stim = mcs.getStimulator(in.stimulator_id);
            try
                h_stim.setupTrigger('linearize',true,'repeat_all',0);
            catch ME
                delete(h_stim);
                rethrow(ME)
            end
            obj.h_stim = h_stim;
            h_stim.setCurrentMode;
            obj.h = mcs.stg.stim_gui_app();
            obj.h.UIFigure.Tag = 'mcs_stim_gui';
            obj.h.UIFigure.UserData = obj;
            obj.h.UIFigure.CloseRequestFcn = @(~,~)delete(obj);

            if isempty(in.channels)
                in.channels = 1:h_stim.n_analog_channels;
            end

            obj.channel_ids = double(in.channels(:)');
            obj.channel_active = false(1,length(obj.channel_ids));
            obj.chan_id = obj.channel_ids(1);

            obj.buildMultiChannelUI();
        end

        function delete(obj)
            try
                if ~isempty(obj.h_stim)
                    if ~isempty(obj.channel_active) && any(obj.channel_active)
                        obj.h_stim.stopStim();
                    end
                    delete(obj.h_stim);
                    obj.h_stim = [];
                end
            catch
            end

            try
                h_app = obj.h;
                obj.h = [];
                if ~isempty(h_app) && isvalid(h_app)
                    try
                        h_app.UIFigure.CloseRequestFcn = '';
                        h_app.UIFigure.UserData = [];
                    catch
                    end
                    delete(h_app);
                end
            catch
            end
        end

        function buildMultiChannelUI(obj)
            fig = obj.h.UIFigure;
            delete(fig.Children);

            n_channels = length(obj.channel_ids);
            fig.Name = 'MCS Multi-Channel Stimulus Control';
            fig.Position(3) = 940;
            fig.Position(4) = max(180,75 + 34*n_channels);

            grid = uigridlayout(fig,[n_channels+1 10]);
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 6;
            grid.ColumnSpacing = 8;
            grid.ColumnWidth = {64,82,72,86,88,72,142,76,76,82};

            row_heights = cell(1,n_channels+1);
            row_heights{1} = 24;
            row_heights(2:end) = {28};
            grid.RowHeight = row_heights;

            headers = {'Channel','Amplitude','Amp Units','Frequency','Pulse Width','PW Units','Range / Res','Status','Start','Stop'};
            for i = 1:length(headers)
                label = uilabel(grid,'Text',headers{i},'FontWeight','bold');
                label.Layout.Row = 1;
                label.Layout.Column = i;
            end

            empty_controls = struct(...
                'channel_label',[],...
                'amplitude',[],...
                'amp_units',[],...
                'frequency',[],...
                'pulse_width',[],...
                'pw_units',[],...
                'hardware_info',[],...
                'status',[],...
                'start_button',[],...
                'stop_button',[]);
            obj.channel_controls = repmat(empty_controls,1,n_channels);

            for i = 1:n_channels
                channel_1b = obj.channel_ids(i);
                row = i + 1;

                c = empty_controls;

                c.channel_label = uilabel(grid,'Text',sprintf('Ch %d',channel_1b));
                c.channel_label.Layout.Row = row;
                c.channel_label.Layout.Column = 1;

                c.amplitude = uieditfield(grid,'numeric');
                c.amplitude.Layout.Row = row;
                c.amplitude.Layout.Column = 2;
                c.amplitude.ValueChangedFcn = @(~,~)obj.saveChannelSettings(channel_1b);

                c.amp_units = uidropdown(grid,'Items',{'uA','mA'},'Value','uA');
                c.amp_units.Layout.Row = row;
                c.amp_units.Layout.Column = 3;
                c.amp_units.ValueChangedFcn = @(~,~)obj.saveChannelSettings(channel_1b);

                c.frequency = uieditfield(grid,'numeric');
                c.frequency.Layout.Row = row;
                c.frequency.Layout.Column = 4;
                c.frequency.ValueChangedFcn = @(~,~)obj.saveChannelSettings(channel_1b);

                c.pulse_width = uieditfield(grid,'numeric');
                c.pulse_width.Layout.Row = row;
                c.pulse_width.Layout.Column = 5;
                c.pulse_width.ValueChangedFcn = @(~,~)obj.saveChannelSettings(channel_1b);

                c.pw_units = uidropdown(grid,'Items',{'us','ms'},'Value','us');
                c.pw_units.Layout.Row = row;
                c.pw_units.Layout.Column = 6;
                c.pw_units.ValueChangedFcn = @(~,~)obj.saveChannelSettings(channel_1b);

                [hardware_text,hardware_tooltip] = obj.getHardwareInfoText(channel_1b);
                c.hardware_info = uilabel(grid,'Text',hardware_text);
                c.hardware_info.Layout.Row = row;
                c.hardware_info.Layout.Column = 7;
                try
                    c.hardware_info.Tooltip = hardware_tooltip;
                catch
                end

                c.status = uilabel(grid,'Text','Idle');
                c.status.FontWeight = 'bold';
                c.status.Layout.Row = row;
                c.status.Layout.Column = 8;

                c.start_button = uibutton(grid,'push','Text','Start');
                c.start_button.BackgroundColor = [0.65 1 0.65];
                c.start_button.Layout.Row = row;
                c.start_button.Layout.Column = 9;
                c.start_button.ButtonPushedFcn = @(~,~)obj.startStim(channel_1b);

                c.stop_button = uibutton(grid,'push','Text','Stop');
                c.stop_button.BackgroundColor = [1 0.65 0.65];
                c.stop_button.Enable = 'off';
                c.stop_button.Layout.Row = row;
                c.stop_button.Layout.Column = 10;
                c.stop_button.ButtonPushedFcn = @(~,~)obj.StopStim(channel_1b);

                obj.channel_controls(i) = c;
                obj.loadChannelSettings(channel_1b);
                obj.updateChannelControls(channel_1b);
            end
        end

        function loadChannelSettings(obj,channel_1b)
            idx = obj.getChannelIndex(channel_1b);
            c = obj.channel_controls(idx);

            path = obj.getAmplitudeSavePath(channel_1b);
            if exist(path,'file')
                h2 = load(path);
                if isfield(h2,'s') && isfield(h2.s,'amplitude')
                    c.amplitude.Value = h2.s.amplitude;
                end
            end

            path = obj.getFrequencySavePath(channel_1b);
            if exist(path,'file')
                h2 = load(path);
                if isfield(h2,'s') && isfield(h2.s,'frequency')
                    c.frequency.Value = h2.s.frequency;
                end
            end

            path = obj.getPulse_WidthSavePath(channel_1b);
            if exist(path,'file')
                h2 = load(path);
                if isfield(h2,'s') && isfield(h2.s,'pulse_width')
                    c.pulse_width.Value = h2.s.pulse_width;
                end
            end

            path = obj.getUnitsSavePath(channel_1b);
            if exist(path,'file')
                h2 = load(path);
                if isfield(h2,'s') && isfield(h2.s,'amp_units')
                    c.amp_units.Value = h2.s.amp_units;
                end
                if isfield(h2,'s') && isfield(h2.s,'pw_units')
                    c.pw_units.Value = h2.s.pw_units;
                end
            end
        end

        function loadAmplitudeFromDisk(obj)
            obj.loadChannelSettings(obj.chan_id);
        end
        function loadFrequencyFromDisk(obj)
            obj.loadChannelSettings(obj.chan_id);
        end
        function loadPulse_WidthFromDisk(obj)
            obj.loadChannelSettings(obj.chan_id);
        end
        function saveAmplitudeToDisk(obj)
            obj.saveChannelSettings(obj.chan_id);
        end
        function saveFrequencyToDisk(obj)
            obj.saveChannelSettings(obj.chan_id);
        end
        function savePulse_WidthToDisk(obj)
            obj.saveChannelSettings(obj.chan_id);
        end

        function saveChannelSettings(obj,channel_1b)
            idx = obj.getChannelIndex(channel_1b);
            c = obj.channel_controls(idx);

            s = struct;
            s.amplitude = c.amplitude.Value;
            save(obj.getAmplitudeSavePath(channel_1b),'s');

            s = struct;
            s.frequency = c.frequency.Value;
            save(obj.getFrequencySavePath(channel_1b),'s');

            s = struct;
            s.pulse_width = c.pulse_width.Value;
            save(obj.getPulse_WidthSavePath(channel_1b),'s');

            s = struct;
            s.amp_units = obj.getDropDownText(c.amp_units);
            s.pw_units = obj.getDropDownText(c.pw_units);
            save(obj.getUnitsSavePath(channel_1b),'s');
        end

        function AmplitudeFile_path = getAmplitudeSavePath(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end
            save_root = obj.getSaveRoot();
            file_name = sprintf('stim_amplitude_data_%02d.mat',channel_1b);
            AmplitudeFile_path = fullfile(save_root,file_name);
        end
        function FrequencyFile_path = getFrequencySavePath(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end
            save_root = obj.getSaveRoot();
            file_name = sprintf('stim_frequency_data_%02d.mat',channel_1b);
            FrequencyFile_path = fullfile(save_root,file_name);
        end
        function Pulse_WidthFile_path = getPulse_WidthSavePath(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end
            save_root = obj.getSaveRoot();
            file_name = sprintf('stim_pulse_width_data_%02d.mat',channel_1b);
            Pulse_WidthFile_path = fullfile(save_root,file_name);
        end
        function UnitsFile_path = getUnitsSavePath(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end
            save_root = obj.getSaveRoot();
            file_name = sprintf('stim_units_data_%02d.mat',channel_1b);
            UnitsFile_path = fullfile(save_root,file_name);
        end
        function save_root = getSaveRoot(~)
            package_dir = fileparts(which('mcs.stimGUI'));
            package_root = fileparts(package_dir);
            save_root = fullfile(package_root,'temp_data','elite11');
            if ~exist(save_root,'dir')
                mkdir(save_root);
            end
        end

        function startStim(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end

            idx = obj.getChannelIndex(channel_1b);
            if obj.channel_active(idx)
                obj.reportError(sprintf(...
                    'Channel %d is already active. Stop it before changing or uploading parameters.',...
                    channel_1b));
                return
            end

            try
                [~,pattern] = obj.getStimPatternFromControls(channel_1b);
                obj.startStimDevice(channel_1b,pattern);
                obj.channel_active(idx) = true;
                obj.stim_flag = any(obj.channel_active);
                obj.updateChannelControls(channel_1b);
            catch ME
                obj.reportError(ME);
            end
        end

        function [chan_id,pattern] = getStimPatternFromControls(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end

            idx = obj.getChannelIndex(channel_1b);
            c = obj.channel_controls(idx);

            amplitude = c.amplitude.Value;
            amp_units = obj.getDropDownText(c.amp_units);
            duration = c.pulse_width.Value;
            duration_units = obj.getDropDownText(c.pw_units);
            chan_id = channel_1b;
            rate = c.frequency.Value;

            obj.validateStimSettings(chan_id,amplitude,rate,duration);

            waveform = mcs.stg.waveform.biphasic(amplitude,duration,...
                'amp_units',amp_units,'duration_units',duration_units);
            pattern = mcs.stg.pulse_train.fixed_rate(rate,'waveform',waveform);
        end

        function text = getDropDownText(~,drop_down)
            value = drop_down.Value;
            items = drop_down.Items;
            items_data = drop_down.ItemsData;

            if ~isempty(items_data)
                if iscell(items_data)
                    idx = find(cellfun(@(x)isequal(x,value),items_data),1);
                elseif isnumeric(items_data) && isnumeric(value)
                    idx = find(items_data == value,1);
                else
                    idx = find(strcmp(cellstr(string(items_data)),string(value)),1);
                end

                if ~isempty(idx)
                    text = char(items{idx});
                    return
                end
            end

            text = char(value);
        end


        function StopStim(obj,channel_1b)
            if nargin < 2
                channel_1b = obj.chan_id;
            end

            idx = obj.getChannelIndex(channel_1b);
            try
                obj.stopStimDevice(channel_1b);
                obj.channel_active(idx) = false;
                obj.stim_flag = any(obj.channel_active);
                obj.updateChannelControls(channel_1b);
            catch ME
                obj.reportError(ME);
            end
        end

        function startStimDevice(obj,chan_id,pattern,varargin)
            %
            %   This is what actually communicates with the stimulator.
            %
            %   Inputs
            %   ------
            %   chan_id : scalar channel
            %   pattern : mcs.stg.pulse_train

            if ~isscalar(chan_id)
                error('mcs:stg:stim_gui:startStimDevice',...
                    'GUI stimulation starts one channel at a time.')
            end

            if iscell(pattern)
                pattern = pattern{1};
            end

            if ~isa(pattern,'mcs.stg.pulse_train')
                error('mcs:stg:stim_gui:invalidPattern',...
                    'Expected a pulse_train pattern for channel %d.',chan_id)
            end

            if obj.h_stim.usesExplicitCapacityAllocation() && ~any(obj.channel_active)
                obj.h_stim.sentDataToDevice(chan_id,pattern);
            else
                obj.h_stim.updateChannelData(chan_id,pattern);
            end
            obj.h_stim.startStim('triggers',chan_id);
        end
        function stopStimDevice(obj,chan_id)
            %chan_id - scalar channel
            obj.h_stim.stopStim('triggers',chan_id);
        end
    end

    methods (Access = private)
        function idx = getChannelIndex(obj,channel_1b)
            idx = find(obj.channel_ids == channel_1b,1);
            if isempty(idx)
                error('mcs:stg:stim_gui:invalidChannel',...
                    'Channel %d is not controlled by this GUI.',channel_1b)
            end
        end

        function [text,tooltip] = getHardwareInfoText(obj,channel_1b)
            try
                info = obj.h_stim.getOutputResolutionInfo(channel_1b);

                current_range = obj.formatElectricalValue(...
                    info.current_range_nA,'nA');
                current_resolution = obj.formatElectricalValue(...
                    info.current_resolution_nA,'nA');
                voltage_range = obj.formatElectricalValue(...
                    info.voltage_range_uV,'uV');
                voltage_resolution = obj.formatElectricalValue(...
                    info.voltage_resolution_uV,'uV');

                text = sprintf('I %s / %s',current_range,current_resolution);
                tooltip = sprintf([...
                    'Channel %d hardware output limits\n',...
                    'Current range %s, resolution %s\n',...
                    'Voltage range %s, resolution %s'],...
                    channel_1b,current_range,current_resolution,...
                    voltage_range,voltage_resolution);
            catch ME
                text = 'HW n/a';
                tooltip = sprintf(...
                    'Hardware range/resolution unavailable for channel %d: %s',...
                    channel_1b,ME.message);
            end
        end

        function text = formatElectricalValue(~,value,base_unit)
            value = double(value);

            switch base_unit
                case 'nA'
                    if abs(value) >= 1e6
                        text = sprintf('%.4g mA',value/1e6);
                    elseif abs(value) >= 1e3
                        text = sprintf('%.4g uA',value/1e3);
                    else
                        text = sprintf('%.4g nA',value);
                    end
                case 'uV'
                    if abs(value) >= 1e6
                        text = sprintf('%.4g V',value/1e6);
                    elseif abs(value) >= 1e3
                        text = sprintf('%.4g mV',value/1e3);
                    else
                        text = sprintf('%.4g uV',value);
                    end
                otherwise
                    error('mcs:stg:stim_gui:formatElectricalValue',...
                        'Unrecognized electrical unit: %s',base_unit)
            end
        end

        function updateChannelControls(obj,channel_1b)
            idx = obj.getChannelIndex(channel_1b);
            c = obj.channel_controls(idx);

            if obj.channel_active(idx)
                status_text = 'Running';
                status_color = [0 0.45 0];
                param_enable = 'off';
                start_enable = 'off';
                stop_enable = 'on';
            else
                status_text = 'Idle';
                status_color = [0.25 0.25 0.25];
                param_enable = 'on';
                start_enable = 'on';
                stop_enable = 'off';
            end

            c.status.Text = status_text;
            c.status.FontColor = status_color;
            c.amplitude.Enable = param_enable;
            c.amp_units.Enable = param_enable;
            c.frequency.Enable = param_enable;
            c.pulse_width.Enable = param_enable;
            c.pw_units.Enable = param_enable;
            c.start_button.Enable = start_enable;
            c.stop_button.Enable = stop_enable;
        end

        function reportError(obj,ME)
            if isa(ME,'MException')
                message = ME.message;
                report = getReport(ME,'extended','hyperlinks','off');
                fprintf(2,'%s\n',report);
            else
                message = char(ME);
            end

            try
                uialert(obj.h.UIFigure,message,'Stim GUI Error');
            catch
                fprintf(2,'%s\n',message);
            end
        end

        function validateStimSettings(~,channel_1b,amplitude,rate,pulse_width)
            ERR_ID = 'mcs:stg:stim_gui:invalidStimSettings';

            if ~isnumeric(amplitude) || ~isscalar(amplitude) || ...
                    ~isfinite(amplitude)
                error(ERR_ID,...
                    'Channel %d amplitude must be a finite scalar value.',...
                    channel_1b)
            end

            if ~isnumeric(rate) || ~isscalar(rate) || ~isfinite(rate) || ...
                    rate <= 0
                error(ERR_ID,...
                    'Channel %d frequency must be greater than 0 Hz.',...
                    channel_1b)
            end

            if ~isnumeric(pulse_width) || ~isscalar(pulse_width) || ...
                    ~isfinite(pulse_width) || pulse_width <= 0
                error(ERR_ID,...
                    'Channel %d pulse width must be greater than 0.',...
                    channel_1b)
            end
        end
    end
end
