classdef trigger < handle
    %
    %   Class:
    %   mcs.stg.trigger
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk.cstg200x_download_basic.getTrigger
    %   mcs.stg.sdk.cstg200x_download_basic.setupTrigger
    
    %TODO: Add on a custom display
    
    properties
        n_chans
        n_syncs
        n_triggers
        channel_map %mcs.utils.bitmask
        %A bit map of channels that belong to the trigger
        
        syncout_map %mcs.utils.bitmask
        %A bit map of sync outs that belong to the trigger
        
        repeat %[1 x n_triggers]
        %For each trigger, the # of times the trigger should be repeated
        %0 
    end
    
%     properties (Dependent)
%         channels
%         syncouts
%     end
%     
%     methods 
%         function value = get.channels(obj)
%             value = cell(1,obj.n_triggers);
%             for i = 1:obj.n_triggers
%                 value{i} = find(bitget(obj.channel_map(i),1:obj.n_chans));
%             end
%         end
%         function value = get.syncouts(obj)
%             value = cell(1,obj.n_triggers);
%            	for i = 1:obj.n_triggers
%                 value{i} = find(bitget(obj.syncout_map(i),1:obj.n_syncs));
%             end
%         end
%     end
    
    methods (Static)
        function obj = fromSDK(c_map,s_map,repeat,n_chans,n_syncs)
            %
            %   obj = mcs.stg.trigger.fromSDK(c_map,s_map,repeat,n_chans,n_syncs)
            %
            %   See Also
            %   --------
            %   mcs.stg.sdk.cstg200x_download_basic.getTrigger
            
            obj = mcs.stg.trigger;
            obj.n_chans = n_chans;
            obj.n_syncs = n_syncs;
            obj.n_triggers = length(c_map);
            obj.channel_map = mcs.utils.bitmask(uint32(c_map),'raw',true);
            obj.syncout_map = mcs.utils.bitmask(uint32(s_map),'raw',true);
            obj.repeat = double(repeat);
        end
    end
    methods
        function disp(obj)
            builtin('disp',obj)
            %
            %Display channel map
            %----------------------------
            %              Chans
            %   Trigger
            %
            

            fprintf('   Channels =>   %s\n',char(49:48+obj.n_chans));
            cmap = obj.channel_map.value;
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
            smap = obj.syncout_map.value;
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

