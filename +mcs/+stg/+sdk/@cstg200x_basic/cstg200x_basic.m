classdef cstg200x_basic < handle
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_basic
    %
    %   This class cannot be instantiated directly.
    %
    %   Classes that can are:
    %   mcs.stg.sdk.cstg200x_download
    %   and
    %   a streaming class (not yet implemented)
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk.cstg200x_download_basic
    %   mcs.stg.sdk.cstg200x_download
    %   mcs.stg.sdk
    
    %{
        Test Code
        ---------
        d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    %}
    
    properties (Hidden)
        h
    end
    
    properties
        driver_version
        d1 = '---- mcs.stg.sdk.cstg200x_basic ----'
        serial_number
        device_id
        device_product
        device_name
        channel_modes
    end

    properties (SetAccess = protected)
        active_triggers_1b = []
        % Triggers started through this MATLAB object and not yet stopped
        % through it. Finite-repeat triggers may finish in hardware before
        % this conservative bookkeeping is cleared by stopStim().
    end
    
    properties (Dependent)
        current_range_nA
        current_resolution_nA
        n_analog_channels
        n_syncout_channels
        n_trigger_inputs
        
        %Throwing errors
        %   n_hardware_dacs
        %  	output_rate
        
        version_info
        voltage_range_uV
        voltage_resolution_uV
        total_memory
    end
    
    methods
        function value = get.current_range_nA(obj)
            n_chans = obj.n_analog_channels;
            value = zeros(1,n_chans);
            for i = 1:n_chans
                value(i) = double(obj.h.GetCurrentRangeInNanoAmp(i-1));
            end
        end
        function value = get.current_resolution_nA(obj)
            n_chans = obj.n_analog_channels;
            value = zeros(1,n_chans);
            for i = 1:n_chans
                value(i) = double(obj.h.GetCurrentResolutionInNanoAmp(i-1));
            end
        end
        function value = get.total_memory(obj)
            value = double(obj.h.GetMemory);
        end
        function value = get.n_analog_channels(obj)
            value = double(obj.h.GetNumberOfAnalogChannels);
        end
        function value = get.n_syncout_channels(obj)
            value = double(obj.h.GetNumberOfSyncoutChannels);
        end
        function value = get.n_trigger_inputs(obj)
            value = double(obj.h.GetNumberOfTriggerInputs);
        end
        
        %This is throwing an error
        %         function value = get.n_hardware_dacs(obj)
        %             Message: HCD return STALL PID
        %             Source: McsUsbNet
        %             HelpLink:
        %             value = double(obj.h.GetNumberOfHWDACPaths);
        %         end
        %This is throwing an error
        %         function value = get.output_rate(obj)
        %             Message: HCD return STALL PID
        %             Source: McsUsbNet
        %             value =  double(obj.h.GetOutputRate);
        %         end
        
        function value = get.version_info(obj)
            [a,b] = obj.h.GetStgVersionInfo();
            value = mcs.stg.sdk.stg_version_info;
            value.software_version = char(a);
            value.hardware_version = char(b);
            
        end
        function value = get.voltage_range_uV(obj)
            n_chans = obj.n_analog_channels;
            value = zeros(1,n_chans);
            for i = 1:n_chans
                value(i) = double(obj.h.GetVoltageRangeInMicroVolt(i-1));
            end
        end
        function value = get.voltage_resolution_uV(obj)
            n_chans = obj.n_analog_channels;
            value = zeros(1,n_chans);
            for i = 1:n_chans
                value(i) = double(obj.h.GetVoltageResolutionInMicroVolt(i-1));
            end
        end

    end
    
    methods
        function obj = cstg200x_basic(h,source_entry)
            if nargin < 2
                source_entry = [];
            end

            obj.h = h;

            obj.driver_version = mcs.stg.sdk.DRIVER_VERSION;

            obj.serial_number = char(h.SerialNumber);
            try
                obj.device_id = mcs.stg.device_id(h.GetDeviceId());
            catch
                obj.device_id = [];
            end

            obj.device_product = '';
            obj.device_name = '';
            if ~isempty(source_entry)
                if isempty(obj.device_id)
                    obj.device_id = source_entry.device_id;
                end
                obj.device_product = source_entry.product;
                obj.device_name = source_entry.device_name;
                if isempty(obj.serial_number)
                    obj.serial_number = source_entry.serial_number;
                end
            end

            if isempty(obj.serial_number)
                error('Empty serial number, something is wrong ...')
            end
            
            %Set channel modes
            n_chans = h.GetNumberOfAnalogChannels;
            obj.channel_modes = repmat({'c'},1,n_chans);
            if ~obj.usesDownloadDestinationOutputMode()
                obj.setCurrentMode();
            end
        end
    end
    
    methods (Hidden)
        function delete(obj)
            %A bit map of which triggers will be stopped
            %             device.SendStop(1);
            
            %TODO: Does disconnect work when stimulation is ongoing?
            obj.h.Disconnect();
            obj.h.Dispose();
            delete(obj.h);
        end
    end
    
    methods
        function getAnalogRanges(obj)
            %NYI
        end
        function getAnalogResolution(obj)
            %NYI
        end
        function info = getOutputResolutionInfo(obj,channels_1b)
            %x Return per-channel output range and resolution information.
            %
            %   info = getOutputResolutionInfo(obj,*channels_1b)
            %
            % Values mirror the MCS driver units:
            %   current range/resolution: nA
            %   voltage range/resolution: uV
            %
            % The MCS Python stimulation example prints these values before
            % downloading data; exposing them here makes the same hardware
            % check available from MATLAB and the GUI.

            if nargin < 2 || isempty(channels_1b)
                channels_1b = 1:obj.n_analog_channels;
            end

            channels_1b = double(channels_1b(:)');
            n_channels = length(channels_1b);

            info = repmat(struct(...
                'channel',[],...
                'current_range_nA',[],...
                'current_resolution_nA',[],...
                'voltage_range_uV',[],...
                'voltage_resolution_uV',[]),1,n_channels);

            current_range = obj.current_range_nA;
            current_resolution = obj.current_resolution_nA;
            voltage_range = obj.voltage_range_uV;
            voltage_resolution = obj.voltage_resolution_uV;

            for i = 1:n_channels
                cur_chan = channels_1b(i);
                info(i).channel = cur_chan;
                info(i).current_range_nA = current_range(cur_chan);
                info(i).current_resolution_nA = current_resolution(cur_chan);
                info(i).voltage_range_uV = voltage_range(cur_chan);
                info(i).voltage_resolution_uV = voltage_resolution(cur_chan);
            end
        end
        function startStim(obj,varargin)
            %x Start the program
            %
            %   startStim(obj,varargin)
            %
            %   Optional Inputs
            %   ----------------
            %   triggers : array, default all
            %       Which triggers to start.
            %
            %   Example
            %   --------------------------
            %   Start triggers 1 & 2
            %   d.startStim('triggers',1:2)
            %
            %   Improvements
            %   -------------
            %   1) By default, check that we are not stimulating already
            %   ...
            %
            %   TODO: Let's add an optional check for the program being
            %   present ...
            %   TODO: What happens if there is no program? Silent fail?
            
            in.triggers = [];
            in = mcs.sl.in.processVarargin(in,varargin);
            
            if isempty(in.triggers)
                n_triggers = obj.n_trigger_inputs;
                in.triggers = 1:n_triggers;
            end
            
            trigger_map = mcs.utils.bitmask({in.triggers});

            %TODO: Document what this is looking for ...
            obj.h.SendStart(uint32(trigger_map.values));

            obj.active_triggers_1b = unique([obj.active_triggers_1b double(in.triggers)]);
        end
        function stopStim(obj,varargin)
            %x Stop stimulating
            %
            %   stopStim(obj,varargin)
            %
            %   Optional Inputs
            %   ----------------
            %   triggers : array, default all
            %       Which triggers to stop.
            %
            %   Example
            %   --------------------------
            %   1) Stop triggers 1 & 2
            %   d.stopStim('triggers',1:2)
            %
            %   See Also
            %   --------
            %   mcs.stg.sdk.cstg200x_download_basic.getTrigger
            %   mcs.stg.sdk.cstg200x_download_basic.setupTrigger
            
            in.triggers = [];
            in = mcs.sl.in.processVarargin(in,varargin);
            
            if isempty(in.triggers)
                n_triggers = obj.n_trigger_inputs;
                in.triggers = 1:n_triggers;
            end
            
            trigger_map = mcs.utils.bitmask({in.triggers});

            obj.h.SendStop(trigger_map.values);

            obj.active_triggers_1b = setdiff(obj.active_triggers_1b,double(in.triggers));
        end
        function setCurrentMode(obj,channels_1b)
            %x Enable current-controlled stimulation on a set of channels
            %
            %   setCurrentMode(obj, *channels_1b)
            %
            %   Examples
            %   --------
            %   %1) Sets all channels to current mode ...
            %   d.setCurrentMode()
            %
            %   %2) Sets channels 1 and 2 to current mode
            %   d.setCurrentMode(1:2)
            
            
            % n_chans = obj.n_analog_channels;

            if obj.usesDownloadDestinationOutputMode()
                if nargin == 1
                    obj.channel_modes(:) = {'c'};
                else
                    obj.channel_modes(channels_1b) = {'c'};
                end
                return
            end

            if nargin == 1
                obj.h.SetCurrentMode();
                obj.channel_modes(:) = {'c'};
            else
                obj.channel_modes(channels_1b) = {'c'};
                obj.h.SetCurrentMode(channels_1b - 1);
            end
            
        end
        function setVoltageMode(obj,channels_1b)
            %x Enable voltage-controlled stimulation on a set of channels
            %
            %

            if obj.usesDownloadDestinationOutputMode()
                if nargin == 1
                    obj.channel_modes(:) = {'v'};
                else
                    obj.channel_modes(channels_1b) = {'v'};
                end
                return
            end

            if nargin == 1
                obj.channel_modes(:) = {'v'};
                obj.h.SetVoltageMode();
            else
                obj.channel_modes(channels_1b) = {'v'};
                obj.h.SetVoltageMode(channels_1b - 1);
            end
        end
        function tf = usesDownloadDestinationOutputMode(obj)
            %x STG5 chooses current/voltage via download destination.
            %
            % The bundled 3.2.71 SDK documents SetCurrentMode and
            % SetVoltageMode as STG3008-FA/STG400x only. STG5 products are
            % C248, C249, and C24A in MC_Stimulus III driver INF files.

            tf = false;
            device_text = lower(sprintf('%s %s',obj.device_product,obj.device_name));
            if contains(device_text,'stg5')
                tf = true;
                return
            end

            if isempty(obj.device_id)
                return
            end

            product_text = lower(char(obj.device_id.product.ToString()));
            product_hex = '';
            try
                product_hex = lower(dec2hex(int32(obj.device_id.product)));
            catch
            end

            product_text = sprintf('%s %s',product_text,product_hex);
            tf = contains(product_text,'49736') || ... % 0xC248 STG5
                contains(product_text,'49737') || ...  % 0xC249 STG5-HV
                contains(product_text,'49738') || ...  % 0xC24A STG5-Opto
                contains(product_text,'c248') || ...
                contains(product_text,'c249') || ...
                contains(product_text,'c24a') || ...
                contains(product_text,'stg5');
        end
        function tf = usesExplicitCapacityAllocation(obj)
            %x Return true when the download driver exposes Get/SetCapacity.

            try
                method_names = methods(obj.h);
                tf = any(strcmp(method_names,'GetCapacity')) && ...
                    any(strcmp(method_names,'SetCapacity'));
            catch
                tf = false;
            end
        end
    end

end





%   'AddSoftwareKey'
%     'BurnDacOffset'
%     'CStg200xDownloadNet'
%     'ClearChannelData'
%     'ClearChannel_PrepareAndSendData'
%     'ClearSyncData'
%     'Connect'
%     'CreateWirelessHeadstageSerialNumberString'
%     'DisableAutoReset'
%     'DisableMultiFileMode'
%     'DisableStatusEndpoint'
%     'Disconnect'
%     'Dispose'
%     'EmptyKey'
%     'EnableAutoReset'
%     'EnableExceptions'
%     'EnableMultiFileMode'
%     'EnableStatusEndpoint'
%     'Equals'
%     'EraseEepromRegisterPreconfig'
%     'ForceStatusEvent'
%     'GetAnalogRanges'
%     'GetAnalogResolution'
%     'GetAutocalibrationDisabled'
%     'GetBlankingEnable'
%     'GetCapacity'
%     'GetConfiguration'
%     'GetCurrentRangeInNanoAmp'
%     'GetCurrentResolutionInNanoAmp'
%     'GetDACResolution'
%     'GetDacAmplificationFactor'
%     'GetDacOffset'
%     'GetDeviceCannotStallOutRequests'
%     'GetDeviceCapableSpeed'
%     'GetDeviceId'
%     'GetDeviceRootHubName'
%     'GetDeviceRootHubVendorEnum'
%     'GetDeviceRootHubVendorID'
%     'GetDeviceRootHubVendorName'
%     'GetDeviceSpeed'
%     'GetElectrodeDacMux'
%     'GetElectrodeEnable'
%     'GetElectrodeMode'
%     'GetEnableAmplifierProtectionSwitch'
%     'GetErrorText'
%     'GetFAAmplification'
%     'GetFirmwareVersion'
%     'GetHardwareRevision'
%     'GetHashCode'
%     'GetHeadstage'
%     'GetHeadstageActive'
%     'GetHeadstageID'
%     'GetHeadstagePresent'
%     'GetIdent'
%     'GetImplantatVoltage'
%     'GetLastUSBError'
%     'GetListmodeIndexRange'
%     'GetListmodeTriggerSource'
%     'GetMea21UsbPort'
%     'GetMemory'
%     'GetModuleCurrent'
%     'GetModuleTemp'
%     x 'GetNumberOfAnalogChannels'
%     'GetNumberOfHWDACPaths'
%     'GetNumberOfStimulationElectrodes'
%     'GetNumberOfSyncoutChannels'
%     x 'GetNumberOfTriggerInputs'
%     'GetOutputRate'
%     'GetRFConnectionStatus'
%     'GetSerialNumber'
%     'GetSoftwareKey'
%     'GetSoftwareKeyString'
%     'GetStatus'
%     'GetStatusOfLastCommand'
%     'GetStgProgramInfo'
%     'GetStgVersionInfo'
%     'GetSweepCount'
%     'GetTotalMemory'
%     'GetTrigger'
%     'GetTriggerSource'
%     'GetType'
%     'GetUsbListEntry'
%     'GetVersion'
%     'GetVoltageRangeInMicroVolt'
%     'GetVoltageResolutionInMicroVolt'

