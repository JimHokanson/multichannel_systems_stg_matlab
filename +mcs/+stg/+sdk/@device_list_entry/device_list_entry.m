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

            try
                obj.device_id = mcs.stg.device_id(obj.getValue(h,{'DeviceId','DeviceID'}));
            catch
                obj.device_id = [];
            end
            obj.device_path = obj.getCharValue(h,{'DevicePath','Path','InterfacePath'});
            obj.hw_version = obj.getCharValue(h,{'HwVersion','HardwareVersion'});
            obj.serial_number = obj.getCharValue(h,{'SerialNumber','SerialNo','Serial'});
            obj.device_name = obj.getCharValue(h,{'DeviceName','Name'});
            obj.product = obj.getCharValue(h,{'Product','ProductName'});
            obj.manufacturer = obj.getCharValue(h,{'Manufacturer','ManufacturerName'});
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
            if error_code ~= 0
                try
                    d.Disconnect();
                catch
                end
                try
                    d.Dispose();
                catch
                end
                try
                    delete(d);
                catch
                end
            end
            mcs.stg.sdk.handleError(ERR_ID,'Failed to connect to the device',error_code)

            device = mcs.stg.sdk.cstg200x_download(d,obj);
        end
    end
    methods (Static, Access = private)
        function value = getValue(h,property_names)
            for i = 1:length(property_names)
                try
                    value = h.(property_names{i});
                    return
                catch
                end
            end
            error('mcs:stg:device_list_entry:getValue',...
                'None of the requested properties were available.')
        end
        function value = getCharValue(h,property_names)
            for i = 1:length(property_names)
                try
                    raw_value = h.(property_names{i});
                    if ~isempty(raw_value)
                        value = char(raw_value);
                        return
                    end
                catch
                end
            end
            value = '';
        end
    end

end

% device = CStg200xDownloadNet();
% device.Connect(deviceList.GetUsbListEntry(0));
