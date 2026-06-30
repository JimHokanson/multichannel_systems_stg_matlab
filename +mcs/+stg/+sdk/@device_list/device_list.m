classdef device_list < handle
    %
    %   Class:
    %   mcs.stg.sdk.device_list
    %   
    %   Wraps:
    %   Mcs.Usb.CMcsUsbListNet
    
    properties (Hidden)
        h
    end

    properties
        device_filter = 'stg'
    end
    
    properties (Dependent)
        count %This updates as devices connect and disconnect ...
    end
    
    methods
        function value = get.count(obj)
            value = double(obj.h.Count);
        end
    end
    
    methods
        function obj = device_list(varargin)
            %
            %   obj = mcs.stg.sdk.device_list()

            in.device_filter = 'stg';
            in = mcs.sl.in.processVarargin(in,varargin);
            obj.device_filter = in.device_filter;

            mcs.stg.sdk.load();
            obj.h = Mcs.Usb.CMcsUsbListNet();
            obj.update();

            %TODO: Support callbacks ...
            %----------------------------------
            %Note, alternatively this can be made with device arrival and
            %device removal callbacks ...
            %
            %CMcsUsbListNet  ( OnDeviceArrivalRemoval^  devArrival,  
            %   OnDeviceArrivalRemoval^  devRemoval  
            %  ) 

        end
    end
    methods (Hidden)
        function delete(obj)
           obj.h.Dispose(); 
        end
    end
    methods
        function update(obj,varargin)
            %x Update the list of connected devices
            %

            in.device_filter = obj.device_filter;
            in = mcs.sl.in.processVarargin(in,varargin);
            obj.device_filter = in.device_filter;

            %   'Initialize' - Initialize/Update the list of devices
            %   which are currently connected to the computer.
            switch lower(in.device_filter)
                case {'stg','stimulator','stimulators'}
                    obj.initializeStgDevices();
                case {'any','all'}
                    obj.h.Initialize(Mcs.Usb.DeviceEnumNet.MCS_DEVICE_ANY);
                otherwise
                    error('mcs:stg:device_list:update',...
                        'Unrecognized device_filter: %s',in.device_filter)
            end

            %deviceList.Initialize(DeviceEnumNet.MCS_STG_DEVICE);
        end
        function entry = getEntry(obj,index_1b)
            %x Retrieve a specific entry by index
            %
            %   entry = getEntry(obj,index_1b)
            %
            %   Outputs
            %   -------
            %   entry : mcs.stg.sdk.device_list_entry
            
            ERR_ID = 'mcs:stg:device_list:getEntry';
            
            %What happens if we ask out of range?
            %
            %=> A device is returned, but it seems to be null :/
            %I asked about this behavior here:
            %http://multichannelsystems.forumieren.de/t458-throwing-errors-and-getusblistentry-matlab#1501
            
            %Retrieval
            %---------
            temp_h = obj.h.GetUsbListEntry(index_1b - 1);
            
            %Error Handling
            %--------------
            %This is my check for whether or not the device is valid
            %- A different approach may be better ...
            if isempty(char(temp_h.SerialNumber))
                if obj.count == 0
                    error(ERR_ID,'No devices have been detected on the computer')
                elseif index_1b > obj.count
                    error(ERR_ID,'Device requested: %d, is greater than the # of devices present: %d',index_1b,obj.count)
                else
                    %TODO: Check for less than 0
                    error(ERR_ID,'GetUsbListEntry() did not return a valid device')
                end
            end
            
            %Casting to object
            %-----------------
            entry = mcs.stg.sdk.device_list_entry(temp_h);
            
        end
        function devs = getAllEntries(obj)
            temp = cell(1,obj.count);
            for i = 1:obj.count
                temp{i} = obj.getEntry(i);
            end
            devs = [temp{:}];
            if obj.isStgFilter(obj.device_filter)
                devs = devs(arrayfun(@(x)obj.isStgEntry(x),devs));
            end
        end
    end
    methods (Access = private)
        function initializeStgDevices(obj)
            % Prefer the SDK's STG group, then include newer STG5 IDs that
            % are absent from the bundled 3.2.71 enum names.
            obj.h.Initialize(Mcs.Usb.DeviceEnumNet.MCS_STG_DEVICE);
            if obj.count > 0
                return
            end

            try
                obj.h.Initialize(obj.getKnownStgDeviceIds());
                if obj.count > 0
                    return
                end
            catch
            end

            obj.h.Initialize(Mcs.Usb.DeviceEnumNet.MCS_DEVICE_ANY);
        end
    end
    methods (Static, Access = private)
        function tf = isStgEntry(entry)
            entry_text = lower(sprintf('%s %s',entry.product,entry.device_name));
            tf = contains(entry_text,'stg') || contains(entry_text,'stimulus');
            if ~tf && ~isempty(entry.device_id)
                product_text = lower(char(entry.device_id.product.ToString()));
                tf = contains(product_text,'stg') || any(strcmp(product_text,{...
                    '49736','49737','49738'}));
            end
        end
        function device_ids = getKnownStgDeviceIds()
            % MC_Stimulus III driver INF files list STG5 as C248,
            % STG5-HV as C249, and STG5-Opto as C24A.
            product_ids = int32([...
                hex2dec('C104'),...
                hex2dec('C240'):hex2dec('C24B'),...
                hex2dec('C250')]);

            n_ids = length(product_ids);
            device_ids = NET.createArray('Mcs.Usb.DeviceIdNet',n_ids);

            product_type = Mcs.Usb.ProductIdEnumNet.STG4002.GetType();
            vendor = Mcs.Usb.VendorIdEnumNet.Mcs;
            bus = Mcs.Usb.McsBusTypeEnumNet.MCS_USB_BUS;

            for i = 1:n_ids
                product = System.Enum.ToObject(product_type,product_ids(i));
                device_ids(i) = Mcs.Usb.DeviceIdNet(vendor,product,int32(-1),bus);
            end
        end
        function tf = isStgFilter(filter)
            tf = any(strcmpi(filter,{'stg','stimulator','stimulators'}));
        end
    end

end

%{
    'CMcsUsbListNet'
    'Dispose'
    'Equals'
    'GetHashCode'
    'GetNumberOfDevices' - why is this not just 'count' - I think it is ...
    'GetType'
    'GetUsbListEntries'
    'GetUsbListEntry'
    'Initialize' - Initialize/Update the list of devices which are currently connected to the computer. 


    'IsDeviceTypeOf'
    'ReferenceEquals'
    'SetStringFormat'
    'ToString'
    'addlistener'
    'delete'
    'eq'
    'findobj'
    'findprop'
    'ge'
    'gt'
    'isvalid'
    'le'
    'lt'
    'ne'
    'notify'
%}
