classdef device_list_entry < handle
    %
    %   Class:
    %   mcs.stg.sdk.device_list_entry
    %
    %   Wraps:
    %   Mcs.Usb.CMcsUsbListEntryNet
    %
    %   See Also
    %   --------
    %   Mcs.Usb.CMcsUsbListEntryNet
    
    properties (Hidden)
        h
    end
    
    properties
        device_id %TODO
        device_path
        hw_version
        serial_number
        device_name
        product
        manufacturer
    end
    
    methods
        function obj = device_list_entry(h)
            obj.h = h;
            
            %TODO: We could make this lazy ...
            
            obj.device_id = mcs.stg.device_id(h.DeviceId);
            obj.device_path = char(h.DevicePath);
            obj.hw_version = char(h.HwVersion);
            obj.serial_number = char(h.SerialNumber);
            obj.device_name = char(h.DeviceName);
            obj.product = char(h.Product);
            obj.manufacturer = char(h.Manufacturer);
        end
        function device = getDownloadInterface(obj)
            %
            %   device = getDownloadInterface(obj)
            %
            %   Outputs
            %   -------
            %   device : mcs.stg.sdk.cstg200x_download
            
            ERR_ID = 'mcs:stg:device_list_entry:getDownloadInterface';
            
            d = Mcs.Usb.CStg200xDownloadNet();
            
            %One reason for failure is if we've already connected to the
            %device and subsequently the device is locked
            error_code = d.Connect(obj.h);
            mcs.stg.sdk.handleError(ERR_ID,'Failed to connect to the device',error_code)
            
            device = mcs.stg.sdk.cstg200x_download(d);
        end
    end
    
end

% device = CStg200xDownloadNet();
% device.Connect(deviceList.GetUsbListEntry(0));