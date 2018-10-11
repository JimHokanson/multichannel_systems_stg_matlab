classdef trigger < handle
    %
    %   Class:
    %   mcs.stg.trigger
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk.cstg200x_download
    %   mcs.stg.sdk.cstg200x_download_basic.getTrigger
    %   mcs.stg.sdk.cstg200x_download_basic.setupTrigger
    %
    %   Usage
    %   -----
    %   This class can be obtained from a device. You can
    %   change the 'values' property of the channel_maps and syncout_maps
    %   as well as the repeats
    
    properties (Hidden)
        d  %mcs.stg.sdk.cstg200x_download
        h_repeats
    end
    
    properties
        %TODO: The behavior is currently undefined if we switch from
        %false back to true - what do we want then?????
        sync_to_device = true
        %When true, changes to the class are mirrored to the device.
        %
        %The idea (NYI) is that we could setup a trigger that is not
        %connected to the device but that gets added. In other words, that 
        %we could swap between two triggers. This was never really
        %implemented.
        
        
        n_chans
        n_syncs
        n_triggers
    end
    
    properties
        d1 = '------ Writeable -----'
        
        %TODO: Support rewriting of these vales as well, not
        %just their sub-properties
        %Would need to redo listeners :/
        
        channel_maps %mcs.utils.bitmask
        %A bit map of channels that belong to the trigger
        
        syncout_maps %mcs.utils.bitmask
        %A bit map of sync outs that belong to the trigger
        
    end

    properties (Dependent)
        repeats %[1 x n_triggers]
        %For each trigger, the # of times the trigger should be repeated
        %0 
    end
    
    methods
        function value = get.repeats(obj)
           value = obj.h_repeats; 
        end
        function set.repeats(obj,value)
            %TODO: Check that the # of repeats is correct ...
            obj.h_repeats = value;
            if obj.sync_to_device
                obj.d.setupTrigger('repeats',value);
            end
        end
    end
    
    
    
    methods (Static,Hidden)
        function obj = fromSDK(d,c_map,s_map,repeats,n_chans,n_syncs)
            %x Create a trigger instance based on the value on a device
            %
            %   obj = mcs.stg.trigger.fromSDK(c_map,s_map,repeat,n_chans,n_syncs)
            %
            %   This class should not be called directly.
            %
            %   See Also
            %   --------
            %   mcs.stg.sdk.cstg200x_download_basic.getTrigger
            
            %TODO: Some of this should be in the constructor if we ever
            %get more than one entry point
            
            obj = mcs.stg.trigger;
            obj.d = d;
            obj.n_chans = n_chans;
            obj.n_syncs = n_syncs;
            obj.n_triggers = length(c_map);
            obj.channel_maps = mcs.utils.bitmask(uint32(c_map),'raw',true);
            obj.syncout_maps = mcs.utils.bitmask(uint32(s_map),'raw',true);
            
            addlistener(obj.channel_maps,'values','PostSet',@(~,~)obj.chanMapChanged);
            addlistener(obj.syncout_maps,'values','PostSet',@(~,~)obj.syncMapChanged);
            
            obj.h_repeats = double(repeats);
        end
    end
    
    methods (Hidden)
        function chanMapChanged(obj)
            if obj.sync_to_device
            	obj.d.setupTrigger('channel_maps',obj.channel_maps);
            end
        end
        function syncMapChanged(obj)
            if obj.sync_to_device
            	obj.d.setupTrigger('syncout_maps',obj.syncout_maps);
            end
        end
    end
    
    methods
        function disp(obj)
            %x A nicer object display method
            
            %Display the normal object ...
            builtin('disp',obj)
            
            %Custom Display (Example below)
            %-------------------------------
            %    Channels =>   1234
            %               1) 1111
            % Triggers =>   2) 0000
            %               3) 0000
            %               4) 0000
            % 
            %    sync_out =>   1234
            %               1) 1111
            % Triggers =>   2) 0000
            %               3) 0000
            %               4) 0000

            fprintf('   Channels =>   %s\n',char(49:48+obj.n_chans));
            cmap = obj.channel_maps.values;
            for i = 1:obj.n_chans 
                if i == 2
                    first_string = 'Triggers =>  ';
                else
                    first_string = '             ';
                end
                temp = fliplr(dec2bin(cmap(i),obj.n_chans));
                fprintf('%s %d) %s\n',first_string,i,temp(1:obj.n_chans))
            end
            fprintf('\n');
         	fprintf('   sync_out =>   %s\n',char(49:48+obj.n_chans));
            smap = obj.syncout_maps.values;
            for i = 1:obj.n_chans 
                if i == 2
                    first_string = 'Triggers =>  ';
                else
                    first_string = '             ';
                end
                temp = fliplr(dec2bin(smap(i),obj.n_chans));
                fprintf('%s %d) %s\n',first_string,i,temp(1:obj.n_chans));
            end
            
        end
    end
    
end

