classdef cstg200x_download_basic < mcs.stg.sdk.cstg200x_basic
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_download_basic
    %
    %   Wraps:
    %   Mcs.Usb.CStg200xDownloadBasicNet (An abtract class)
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk.cstg200x_basic
    %   mcs.stg.sdk.cstg200x_download
    
    %{
    
        Test Code
        ---------
    
    	d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    	pt2 = 500*mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2,'n_trains',6);
    	d.sentDataToDevice(1,pt2);
      	d.setupTrigger('first_trigger',1,'repeat',0)
            
            a = NET.convertArray(10000*ones(1,4,'uint32'), 'System.UInt32');
           b  = NET.convertArray(10000*ones(1,4,'uint32'), 'System.UInt32');
           d.h.SetCapacity(a,b);
    
    
    
            d.sendStart(1);
            d.sendStop(1)
    
    
        d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
        d.setupTrigger;
    
        device = d.h;
    
        %1 nA
        %1 uV
    


       	device.PrepareAndSendData(0, Amplitude, Duration, Mcs.Usb.STG_DestinationEnumNet.channeldata_current);

    
        device.PrepareAndSendData(0, AmplitudeNet, DurationNet, STG_DestinationEnumNet.channeldata_voltage);
        device.SendStart(1);
    
    %}
    
    
    properties
        d2 = '-------- mcs.stg.sdk.cstg200x_download_basic -------' 
    end
    
    properties (Dependent)
        trigger_settings   %mcs.stg.trigger
        
        channel_capacity_current_segment  %
        %Should be the # of bytes available per channel
        %
        %This was broken at some point and required a firmware update to
        %1.48 (for the STG 4004)
        
        sync_capacity_current_segment
        
        n_sweeps
        n_triggers
        
        stimulus
    end
    
    methods
        function value = get.trigger_settings(obj)
            value = obj.getTrigger();
        end
        function value = get.channel_capacity_current_segment(obj)
            value = obj.getChannelCapacity();
        end
        function value = get.sync_capacity_current_segment(obj)
            value = obj.getSyncCapacity();
        end
        function value = get.n_sweeps(obj)
            
        end
        function value = get.n_triggers(obj)
            
        end
        function value = get.stimulus(obj)
           h = obj.h.Stimulus;
           value = mcs.stg.sdk.c_stimulus_function(h);
        end
    end
    
    methods
        function obj = cstg200x_download_basic(h)
            %
            %   obj = mcs.stg.sdk.cstg200x_download_basic(h)
            
            obj = obj@mcs.stg.sdk.cstg200x_basic(h);
            
        end
        function clearChannelData(obj,channel_1b)
            %x Clears data in a particular channel
            %
            
            %TODO: Allow clearing all as well
            
            obj.h.ClearChannelData(uint32(channel_1b-1));
            
        end
        function getSweepCount(obj)
            %             Get the sweep and trigger count of the STG.
            %
            % The triggercount tells how many times each trigger was active
            % and is reset to zero on download of new channel data. The
            % sweepcount tells how many times each trigger was already
            % repeated. This count is set to zero on trigger and counts up
            % to repeat in CStg200xDownloadBasicNet::SetupTrigger.
            % 
            %   Parameters:
            % [out] sweeps on return contains the number of sweeps for each
            % trigger [out] triggers on return contains the number of
            % trigger events seen for each trigger
            
        end
        function setupTrigger(obj,varargin)
            %x  Setup trigger configuration
            %
            %   setupTrigger(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   linearize : default false
            %       If true, all triggers and sync-outs are mapped to
            %       individual channels.
            %   first_trigger : default 1  CURRENTLY NOT WORKING, BUG IN DLL
            %       If this is not 1, it allows updating starting
            %       at a different trigger index.
            %   channel_maps : [1 x n_triggers (max)] or 'mcs.utils.bitmask'
            %   syncout_maps : [1 x n_triggers (max)]
            %   repeats : [1 x n_triggers (max)]
            %       # of times to repeat the stimulus. 0 means forever.
            %   in.repeat_all : default []
            %       This value gets applied to all triggers.
            %
            %   Examples (Note 'd' is instance of the object)
            %   -----------------------------------------------
            %   % 1) Update repeats for the 2nd trigger only
            %   d.setupTrigger('first_trigger',2,'repeat',10)
            %
            %   % 2) Change to a 1 to 1 mapping for the first 2 triggers
            %   map = mcs.utils.bitmask({1 2}); %{} is important
            %   d.setupTrigger('channel_maps',map,'syncout_map',map)
            %
            %   % 2.5) ...
            %   map = mcs.utils.bitmask({1 2 [3 4]});
            %   d.setupTrigger('channel_maps',map,'syncout_map',map,'first_trigger',2)
            %
            %   % 3) Let trigger 2 start 2 & 3 together, with trigger 4
            %   %    targeting 4. Syncouts will be updated so that
            %   %    2 goes to 2 and 4 goes to 4
            %
            %   %Note here that the 'bitmask' class is helpful in converting
            %   %from an array ([2 3]) to a single value.
            %   c_map = mcs.utils.bitmask({[2 3],0,4});
            %   s_map = mcs.utils.bitmask({2,0,4});
            %   d.setupTrigger('first_trigger',2,'channel_maps',c_map,'syncout_maps',s_map);
            %   %DOESN'T WORK, first_trigger is broken :/
            %
            %   Improvements
            %   ------------
            %   1) Can we have overlapping trigger to channel maps?
            %    Presumably this should be ok, we just can't trigger
            %    both triggers at the same time ...
            
            
            ERR_ID = 'mcs:stg:sdk:cstg200x_download_basic';
            
            in.linearize = false;
            in.first_trigger = 1;
            in.channel_maps = [];
            in.syncout_maps = [];
            in.repeats = [];
            in.repeat_all = false;
            in = mcs.sl.in.processVarargin(in,varargin);
            
            %The default trigger settings
            t = obj.getTrigger();
            
            I = in.first_trigger;
            
            n_triggers = t.n_triggers; %#ok<PROPLC>
            
            if in.linearize
                map = mcs.utils.bitmask(num2cell(1:n_triggers)); %#ok<PROPLC>
                in.channel_maps = map;
                in.syncout_maps = map;
            end
            
            if ~isempty(in.repeat_all)
               in.repeats = in.repeat_all*ones(1,n_triggers); %#ok<PROPLC> 
            end
            
            %Bitmask to array conversions
            %----------------------------------------
            if isa(in.channel_maps,'mcs.utils.bitmask')
                in.channel_maps = in.channel_maps.values;
            end
            
            if isa(in.syncout_maps,'mcs.utils.bitmask')
                in.syncout_maps = in.syncout_maps.values;
            end
            
            %Length check and retrieval of default values
            %--------------------------------------------
            n_max = max([length(in.channel_maps),length(in.syncout_maps),length(in.repeats)]);
            if n_max == 0
                error(ERR_ID,'Incorrect usage of function, all aray inputs empty')
            %elseif n_max > length
            end
            
            %TODO: Check that n_max doesn't exceed the # of triggers
            
            %Check length, must be the same or empty
            if isempty(in.channel_maps)
                in.channel_maps = t.channel_maps.values(I:I+n_max-1);
            elseif length(in.channel_maps) ~= n_max
                error(ERR_ID,'Mismatch in length between the max # of elements input and the channel_map array length')
            end
            
            if isempty(in.syncout_maps)
                in.syncout_maps = t.syncout_maps.values(I:I+n_max-1);
            elseif length(in.syncout_maps) ~= n_max
                error(ERR_ID,'Mismatch in length between the max # of elements input and the syncout_map array length')
            end
            
            if isempty(in.repeats)
                in.repeats = t.repeats(I:I+n_max-1);
            elseif length(in.repeats) ~= n_max
                error(ERR_ID,'Mismatch in length between the max # of elements input and the repeat array length')
            end
            
            %--------------------------------------------------------
            first_trigger_0b = in.first_trigger-1;
            
            obj.h.SetupTrigger(uint32(first_trigger_0b),...
                uint32(in.channel_maps),uint32(in.syncout_maps),uint32(in.repeats))
        end
        function trigger = getTrigger(obj)
            %x Retrieves the trigger setup info
            %
            %   Outputs
            %   -------
            %   trigger : mcs.stg.trigger

            h = obj.h;
            
            [c2,s2,r2] = GetTrigger(h);
            
            trigger = mcs.stg.trigger.fromSDK(obj,uint32(c2),uint32(s2),uint32(r2),...
                obj.n_analog_channels,obj.n_syncout_channels);
        end
        function setChannelCapacity(obj,capacity,varargin)
            %
            %   WARNING - this currently clears both channel and sync memory
            %
            %   TODO: Document function usage ...
            %
            %             Configures the memory layout of the current segment in
            %             download mode.
            %
            % For each segment, the memory layout has to be defined. Each channel and
            % sync output can be given an individual amount of memory space as needed
            % by the application. Make sure the sum does not exceed the memory which is
            % assigned to the currently selected segement.
            %
            % Parameters:
            %   [in] channelCapacity is a list of memeory sizes, with one
            % entry per channel
            %   [in] syncCapacity is a list of memeory sizes, with one
            % entry per syncout
            %
            %   Segment support???
            %   
            
            %TODO: Max memory support?
            
            in.all = false;
            in.start_chan = 1;
            in = sl.in.processVarargin(in,varargin);
            
            a = uint32(obj.getChannelCapacity());
            b = uint32(obj.getSyncCapacity());
            
            if in.all
                a(:) = capacity;
            else
                end_chan = in.start_chan + length(capacity) - 1;
                %TODO: error check on length
                a(in.start_chan:end_chan) = capacity;
            end
            
            obj.h.SetCapacity(a,b);
        end
        function setSyncCapacity(obj,capacity,varargin)
            %
            %   WARNING - this currently clears both data and sync memory
            in.all = true;
            in.start_chan = 1;
            in = sl.in.processVarargin(in,varargin);
            
            %The rest of this is not yet implemented
            
            a = uint32(obj.getChannelCapacity());
            b = uint32(obj.getSyncCapacity());
            
            if in.all && length(capacity) == 1
                b(:) = capacity;
            else
                end_chan = in.start_chan + length(capacity) - 1;
                %TODO: error check on length
                b(in.start_chan:end_chan) = capacity;
            end
            
            obj.h.SetCapacity(a,b);
        end
        function chan_capacity = getChannelCapacity(obj)
            %x Retrieve the # of bytes that each channel can store
            %   In 
            [a,~] = obj.h.GetCapacity();
            chan_capacity = uint32(a);
        end
        function sync_capacity = getSyncCapacity(obj)
            %x Retrieve the # of bytes that each sync channel can store
            
            [~,b] = obj.h.GetCapacity();
            sync_capacity = uint32(b);
        end
    end
    
end

%ClearChannelData
%ClearSyncData
%DisableAutoReset
%EnableAutoReset
%GetCapacity
%GetSweepCount
%GetTrigger
