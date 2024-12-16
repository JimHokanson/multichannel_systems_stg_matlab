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
    %   mcs.getDevicesInfo
    
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

    properties (Dependent)
        is_stg5
        is_stg4
    end

    methods
        function value = get.is_stg5(obj)
            value = strcmp(obj.product,'STG5');
        end
        function value = get.is_stg4(obj)
            value = strcmp(obj.product,'STG4004');
        end
    end

    methods
        function obj = device_list_entry(h)
            obj.h = h;
            
            %TODO: We could make this lazy ...
            
            obj.device_id = mcs.stg.device_id(h.DeviceId);
            try
                %This was removed in the new driver
                obj.device_path = char(h.DevicePath);
            catch
                obj.device_path = 'not specified - new driver';
            end
            obj.hw_version = char(h.HwVersion);
            obj.serial_number = char(h.SerialNumber);
            obj.device_name = char(h.DeviceName);
            obj.product = char(h.Product);
            obj.manufacturer = char(h.Manufacturer);
        end
        function t = getDispText(obj) %#ok<MANU>
            t = evalc('disp(obj)');
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
            device.device_info = obj;
        end
    end
    
end

% device = CStg200xDownloadNet();
% device.Connect(deviceList.GetUsbListEntry(0));