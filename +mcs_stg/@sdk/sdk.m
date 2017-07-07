classdef sdk < handle
    %
    %   Class:
    %   mcs_stg.sdk
    %
    %   http://www.multichannelsystems.com/software/mcsusbnetdll
    
    %Not sure what functionality we want to explore in this class.
    
    properties
    end
    
    methods
        function obj = sdk()
            %
            %   obj = mcs_stg.sdk()
            
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
deviceList.Initialize(DeviceEnumNet.MCS_STG_DEVICE);

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