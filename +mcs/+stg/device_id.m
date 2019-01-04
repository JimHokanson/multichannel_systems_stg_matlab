classdef device_id
    %
    %   Class:
    %   mcs.stg.device_id
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk.device_list_entry
    
%          IdVendor: Mcs
%     IdProduct: STG4002
%     BcdDevice: 32768
%       BusType: MCS_USB_BUS
    
    properties (Hidden)
       h 
    end

    properties
        vendor
        product
        bcd_device
        bus_type
    end
    
    methods
        function obj = device_id(h)
            obj.h = h;
            obj.vendor = h.IdVendor;
            obj.product = h.IdProduct;
            obj.bcd_device = h.BcdDevice;
            obj.bus_type = h.BusType;
        end
    end
    
end

