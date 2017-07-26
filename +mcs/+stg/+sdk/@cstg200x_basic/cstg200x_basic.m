classdef cstg200x_basic < sl.obj.display_class
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_basic
    
    %I think the device is getting deleted after it is constructed ...
    
    %Can we tell, other than a blank serial number, that the connection is
    %failing?
    
    %{
    d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    d.h.GetNumberOfAnalogChannels
    d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    pause(15)
    d.h.GetNumberOfAnalogChannels
    
    %}
    
    
    properties (Hidden)
        h 
    end
    
    properties
        serial_number
        channel_modes
    end
    properties
        n_analog_channels
        n_trigger_inputs
    end
    
    methods
        function value = get.n_analog_channels(obj)
           value = double(obj.h.GetNumberOfAnalogChannels);
        end
        function value = get.n_trigger_inputs(obj)
           value = double(obj.h.GetNumberOfTriggerInputs);
        end
    end
    
    methods
        function obj = cstg200x_basic(h)
            obj.h = h;
            
            obj.serial_number = char(h.SerialNumber);
            
            if isempty(obj.serial_number)
                error('Empty serial number, something is wrong ...')
            end
            
            %Set channel modes 
            n_chans = h.GetNumberOfAnalogChannels;
            obj.channel_modes = repmat({'c'},1,n_chans);
            obj.setCurrentMode();
        end
        function delete(obj)
            %A bit map of which triggers will be stopped
%             device.SendStop(1);
            
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
        function sendStart(obj,trigger_map)
            %x Start the program
            %
            %   Inputs
            %   ------
            %   trigger_map: 
            %       bit-mask of trigger inputs
            %
            %   Example
            %   --------------------------
            %   Start channels 1 & 2
            %   d.sendStart(1+2) 
            %
            %   TODO: What happens if there is no program? Silent fail?
            
            
            obj.h.SendStart(trigger_map);
        end
        function sendStop(obj,trigger_map,options)
            %x Stop the program
            %
            %   Inputs
            %   ------
            %   trigger_map: 
            %       bit-mask of trigger inputs
            %
            %   Example
            %   --------------------------
            %   Stop channels 1 & 2
            %   d.sendStart(1+2) 
            
            
            obj.h.SendStop(trigger_map);
        end
        function setCurrentMode(obj,channels_1b)
            %
            %   setCurrentMode(obj, *channels_1b)
           
%             n_chans = obj.n_analog_channels;
            
            if nargin == 1
                obj.h.SetCurrentMode()
                obj.channel_modes(:) = {'c'};
            else
                obj.channel_modes(channels_1b) = {'c'};
                obj.h.SetCurrentMode(channels_1b - 1);
            end
            
        end
        function setVoltageMode(obj,channels_1b)
          	if nargin == 1
                obj.h.SetCurrentMode()
                obj.channel_modes(:) = {'v'};
            else
                obj.channel_modes(channels_1b) = {'v'};
                obj.h.SetCurrentMode(channels_1b - 1);
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

