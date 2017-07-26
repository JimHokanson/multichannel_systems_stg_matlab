classdef device_list < sl.obj.display_class
    %
    %   Class:
    %   mcs.stg.sdk.device_list
    %   
    %   Wraps:
    %   Mcs.Usb.CMcsUsbListNet
    
    properties (Hidden)
        h
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
        function obj = device_list()
            %
            %   obj = mcs.stg.sdk.device_list()
            
            mcs.stg.sdk.load();
            obj.h = Mcs.Usb.CMcsUsbListNet();
            
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
        function update(obj)
            %x Update the list of connected devices
            %
            
            %   'Initialize' - Initialize/Update the list of devices 
            %   which are currently connected to the computer. 
            obj.h.Initialize();
            
            %deviceList.Initialize(DeviceEnumNet.mcs.stg_DEVICE);
        end
        function entry = getEntry(obj,index_1b)
            %x Retrieve a specific entry by index
            %
            %   entry = getEntry(obj,index_1b)
            
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
%         function getEntries(obj)
%             
%         end
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