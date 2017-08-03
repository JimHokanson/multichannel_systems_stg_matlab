classdef cstg200x_basic < sl.obj.display_class
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_basic
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
        channel_modes
    end
    
    properties (Dependent)
        current_resolution_nA
        n_analog_channels
        n_syncout_channels
        n_trigger_inputs
        
        %Throwing errors
        %   n_hardware_dacs
        %  	output_rate
        
        version_info
        voltage_resolution_uV
        total_memory
    end
    
    methods
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
        function value = get.voltage_resolution_uV(obj)
            n_chans = obj.n_analog_channels;
            value = zeros(1,n_chans);
            for i = 1:n_chans
                value(i) = double(obj.h.GetVoltageResolutionInMicroVolt(i-1));
            end
        end

    end
    
    methods
        function obj = cstg200x_basic(h)
            obj.h = h;
            
            obj.driver_version = mcs.stg.sdk.DRIVER_VERSION;
            
            obj.serial_number = char(h.SerialNumber);
            
            if isempty(obj.serial_number)
                error('Empty serial number, something is wrong ...')
            end
            
            %Set channel modes
            n_chans = h.GetNumberOfAnalogChannels;
            obj.channel_modes = repmat({'c'},1,n_chans);
            obj.setCurrentMode();
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
            
        end
        function getAnalogResolution(obj)
            
        end
        function startStim(obj,trigger_map)
            %x Start the program
            %
            %   Inputs
            %   ------
            %   trigger_map:
            %       bit-mask of trigger inputs
            %
            %   Example
            %   --------------------------
            %   Start triggers 1 & 2
            %   d.startStim(1+2)
            %
            %   TODO: What happens if there is no program? Silent fail?
            
            
            obj.h.SendStart(uint32(trigger_map));
        end
        function stopStim(obj,trigger_map,options)
            %x Stop the program
            %
            %   Inputs
            %   ------
            %   trigger_map:
            %       bit-mask of trigger inputs
            %
            %   Optional
            %
            %   Example
            %   --------------------------
            %   1) Stop triggers 1 & 2
            %
            %   d.stopStim(1+2)
            %
            %   See Also
            %   --------
            %   mcs.stg.sdk.cstg200x_download_basic.getTrigger
            %   mcs.stg.sdk.cstg200x_download_basic.setupTrigger
            
            
            obj.h.SendStop(trigger_map);
        end
        function setCurrentMode(obj,channels_1b)
            %
            %   setCurrentMode(obj, *channels_1b)
            
            %             n_chans = obj.n_analog_channels;
            
            if nargin == 1
                obj.h.SetCurrentMode();
                obj.channel_modes(:) = {'c'};
            else
                obj.channel_modes(channels_1b) = {'c'};
                obj.h.SetCurrentMode(channels_1b - 1);
            end
            
        end
        function setVoltageMode(obj,channels_1b)
            if nargin == 1
                obj.h.SetVoltageMode();
                obj.channel_modes(:) = {'v'};
            else
                obj.channel_modes(channels_1b) = {'v'};
                obj.h.SetVoltageMode(channels_1b - 1);
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

