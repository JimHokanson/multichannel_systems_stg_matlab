classdef sdk < handle
    %
    %   Class:
    %   mcs.stg.sdk
    %
    %   http://www.multichannelsystems.com/software/mcsusbnetdll
    %
    %   Actual Stimulator installation software?
    %   http://www.multichannelsystems.com/software/mc-stimulus-ii
    %
    %   Forum:
    %   http://multichannelsystems.forumieren.de/
    
    
    %Not sure what functionality we want to explore in this class.
    
    %TODO: Functionality, detect # of devices again
    
    
    properties
    end
    
    methods (Static)
        function load()
            %
            %   mcs.stg.sdk.load()
            
            persistent obj
            
            if isempty(obj)
               obj = mcs.stg.sdk; 
            end
        end
    end
    
    methods (Access = private)
        function obj = sdk()
            %
            %   obj = mcs.stg.sdk()
            
            %Note, the _v20 means using .NET 2.0 framework, versus
            %the the normal file which uses 4
            
            VER_FOLDER = '3_2_45';
            
            %TODO: Move into local package
            p = sl.stack.getMyBasePath;
            
            dll = NET.addAssembly(fullfile(p,VER_FOLDER,'McsUsbNet.dll'));
            
        end
    end
    
end

%{
dll = NET.addAssembly([pwd '\McsUsbNet.dll']);
import Mcs.Usb.*

deviceList = CMcsUsbListNet();
deviceList.Initialize(DeviceEnumNet.mcs.stg_DEVICE);

fprintf('Found %d STGs\n', deviceList.GetNumberOfDevices());


for i=1:deviceList.GetNumberOfDevices()
   SerialNumber = char(deviceList.GetUsbListEntry(i-1).SerialNumber);
   fprintf('Serial Number: %s\n', SerialNumber);
end

device = CStg200xDownloadNet();
device.Connect(deviceList.GetUsbListEntry(0));


device.SetVoltageMode();



Amplitude = int32([+2000000 -2000000]);  % Amplitude in uV
Duration = uint64([100000 100000]);  % Duration in us

AmplitudeNet = NET.convertArray(Amplitude, 'System.Int32');
DurationNet  = NET.convertArray(Duration, 'System.UInt64');

device.PrepareAndSendData(0, AmplitudeNet, DurationNet, STG_DestinationEnumNet.channeldata_voltage);
device.SendStart(1);

device.Disconnect();

delete(deviceList);
delete(device);
%}

%dll.Enums :
%
%     'Mcs.Usb.SoftwareKeyProgrammIdsNet+ProgrammIdsNet'
%     'Mcs.Usb.DeviceEnumNet'
%     'Mcs.Usb.VendorIdEnumNet'
%     'Mcs.Usb.ProductIdEnumNet'
%     'Mcs.Usb.McsBusTypeEnumNet'
%     'Mcs.Usb.CFirmwareDestinationNet'
%     'Mcs.Usb.DigitalSourceEnumNet'
%     'Mcs.Usb.W2100DigitalSourceEnumNet'
%     'Mcs.Usb.TriggerSourceEnumNet'
%     'Mcs.Usb.AnalogSourceEnumNet'
%     'Mcs.Usb.RetriggerActionEnumNet'
%     'Mcs.Usb.DigOutStimulatorTriggerSlopeEnumNet'
%     'Mcs.Usb.AdapterTypeEnumNet'
%     'Mcs.Usb.MeaLayoutEnumNet'
%     'Mcs.Usb.DataModeEnumNet'
%     'Mcs.Usb.SampleSizeNet'
%     'Mcs.Usb.SampleDstSizeNet'
%     'Mcs.Usb.TcxDeviceTypeEnumNet'
%     'Mcs.Usb.STG_DestinationEnumNet'
%     'Mcs.Usb.ElectrodeModeEnumNet'
%     'Mcs.Usb.DacqGroupChannelEnumNet'
%     'Mcs.Usb.DacqMeaGroupTypeEnumNet'
%     'Mcs.Usb.CMOSMeaValueUnitEnumNet'
%     'Mcs.Usb.CMOSMeaInterfaceADCEnumNet'
%     'Mcs.Usb.CMOSMeaHeadstage1NCBathCurrentEnumNet'
%     'Mcs.Usb.CMOSMeaHeadstage1NCCol2CurrentEnumNet'
%     'Mcs.Usb.CMOSMeaHeadstage1NChipTempEnumNet'
%     'Mcs.Usb.CMOSMeaSTG1DACSignalEnumNet'
%     'Mcs.Usb.CMOSMeaIFDigChannelEnumNet'
%     'Mcs.Usb.CMOSMeaHS1SidebandEnumNet'
%     'Mcs.Usb.CMOSMeaHS1TriggerStatusEnumNet'
%     'Mcs.Usb.AnalogUnitEnumNet'
%     'Mcs.Usb.CMOSMeaPacketFrameContextGroupEnumNet'
%     'Mcs.Usb.CMOSMeaBathModeEnumNet'
%     'Mcs.Usb.PatchServAdcModeEnumNet'
%     'Mcs.Usb.RoboCurrentModeEnumNet'
%     'Mcs.Usb.PlateClampEnumNet'
%     'Mcs.Usb.PlateClampLockEnumNet'
%     'Mcs.Usb.MultiwellPlateTypeEnumNet'
%     'Mcs.Usb.FpgaDeviceIdEnumNet'
%     'Mcs.Usb.UsbVendorIdEnumNet'
%     'Mcs.Usb.FilterBandEnumNet'
%     'Mcs.Usb.FilterFamilyEnumNet'
%     'Mcs.Usb.FilterTypeEnumNet'
%     'Mcs.Usb.W2100_DAC_Range_EnumNet'
%     'Mcs.Usb.PP_Pump_Mode_Type_EnumNet'
%     'Mcs.Usb.MbcChargingModeEnumNet'
%     'Mcs.Usb.MbcChannelStateEnumNet'
%     'Mcs.Usb.PulseGenerator_Mode_EnumNet'
%     'Mcs.Usb.EnSTG200x_STATUS'
%     'Mcs.Usb.EnSTG200x_TRIGGER_STATUS'
%     'Mcs.Usb.enCMosMeaChipType'
%     'Mcs.Usb.HeadStageIDType+HeadstageTypeEnum'