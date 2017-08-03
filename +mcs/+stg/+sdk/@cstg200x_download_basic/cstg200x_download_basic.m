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
        d1 = '-------- mcs.stg.sdk.cstg200x_download_basic -------' 
    end
    
    properties (Dependent)
        trigger_settings   %mcs.stg.trigger
        
        channel_capacity_current_segment  %Currently broken
        %Should be the # of bytes available per channel
        
        sync_capacity_current_segment
        
        n_sweeps
        n_triggers
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
        function vlaue = get.n_triggers(obj)
            
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
            % The triggercount tells how many times each trigger was active and is reset to zero on download of new channel data.
            % The sweepcount tells how many times each trigger was already repeated. This count is set to zero on trigger and counts up to repeat in CStg200xDownloadBasicNet::SetupTrigger.
            % Parameters:
            % [out] sweeps on return contains the number of sweeps for each trigger
            % [out] triggers on return contains the number of trigger events seen for each trigger
            
        end
        function setupTrigger(obj,varargin)
            %
            %
            %   Optional Inputs
            %   ---------------
            %   first_trigger : default 1
            %       If this is not 1, it allows updating starting
            %       at a different trigger index.
            %       THIS DOESN'T SEEM TO WORK ...
            %   channel_map : [1 x n_triggers (max)] or 'mcs.utils.bitmask'
            %   syncout_map : [1 x n_triggers (max)]
            %   repeat : [1 x n_triggers (max)]
            %       # of times to repeat the stimulus. 0 means forever.
            %
            %   Examples (Note 'd' is instance of the object)
            %   -----------------------------------------------
            %   % 1) Update repeats for the 2nd trigger only
            %   d.setupTrigger('first_trigger',2,'repeat',10)
            %
            %   % 2) Change to a 1 to 1 mapping for the first 2 triggers
            %   map = mcs.utils.bitmask({1 2}); %{} is important
            %   d.setupTrigger('channel_map',map,'syncout_map',map)
            %
            %   % 2.5) ...
            %   map = mcs.utils.bitmask({1 2 [3 4]});
            %   d.setupTrigger('channel_map',map,'syncout_map',map,'first_trigger',2)
            %
            %   % 3) Let trigger 2 start 2 & 3 together, with trigger 4
            %   %    targeting 4. Syncouts will be updated so that
            %   %    2 goes to 2 and 4 goes to 4
            %
            %   %Note here that the 'bitmask' class is helpful in converting
            %   %from an array ([2 3]) to a single value.
            %   c_map = mcs.utils.bitmask({[2 3],0,4});
            %   s_map = mcs.utils.bitmask({2,0,4});
            %   d.setupTrigger('first_trigger',2,'channel_map',c_map,'syncout_map',s_map);
            %
            
            ERR_ID = 'mcs:stg:sdk:cstg200x_download_basic';
            
            %TODO: Allow passing in the trigger directly ...
            in.first_trigger = 1;
            in.channel_map = [];
            in.syncout_map = [];
            in.repeat = [];
            in = sl.in.processVarargin(in,varargin);
            
            t = obj.getTrigger();
            
            I = in.first_trigger;
            
            %Bitmask to array conversions
            %----------------------------------------
            if isa(in.channel_map,'mcs.utils.bitmask')
                in.channel_map = in.channel_map.value;
            end
            
            if isa(in.syncout_map,'mcs.utils.bitmask')
                in.syncout_map = in.syncout_map.value;
            end
            
            %Length check and retrieval of default values
            %--------------------------------------------
            n_max = max([length(in.channel_map),length(in.syncout_map),length(in.repeat)]);
            if n_max == 0
                error(ERR_ID,'Incorrect usage of function, all aray inputs empty')
            end
            
            %TODO: Check that n_max doesn't exceed the # of triggers
            
            %Check length, must be the same or empty
            if isempty(in.channel_map)
                in.channel_map = t.channel_map.value(I:I+n_max-1);
            elseif length(in.channel_map) ~= n_max
                error(ERR_ID,'Mismatch in length between the max # of elements input and the channel_map array length')
            end
            
            if isempty(in.syncout_map)
                in.syncout_map = t.syncout_map.value(I:I+n_max-1);
            elseif length(in.syncout_map) ~= n_max
                error(ERR_ID,'Mismatch in length between the max # of elements input and the syncout_map array length')
            end
            
            if isempty(in.repeat)
                in.repeat = t.repeat(I:I+n_max-1);
            elseif length(in.repeat) ~= n_max
                error(ERR_ID,'Mismatch in length between the max # of elements input and the repeat array length')
            end
            
            %--------------------------------------------------------
            first_trigger_0b = in.first_trigger-1;
            
            %This is likely not working ....
            
            obj.h.SetupTrigger(uint32(first_trigger_0b),...
                uint32(in.channel_map),uint32(in.syncout_map),uint32(in.repeat))
            
        end
        
        function trigger = getTrigger(obj)
            %
            %
            %   Outputs
            %   -------
            %   trigger : mcs.stg.trigger
            
            
            %This is not working ....
            %In particular, repeats is causing problems ...
            %
            %   Are we not getting array duplication?
            %   but then c2 should equal s2 and r2, which it is not
            %
            %   The problem is with the repeats ...
            
            %Intersting, it seems like instead we need
            %Although we might need to pass in the inputs
            %as well
            
            %keyboard
            %[c2,s2,r2] = obj.h.GetTrigger();
            
            %z = uint32(zeros(1,obj.n_trigger_inputs));
            
            %             c2 = NET.convertArray(zeros(1,obj.n_trigger_inputs),'System.UInt32');
            %             s2 = NET.convertArray(zeros(1,obj.n_trigger_inputs),'System.UInt32');
            %             r2 = NET.convertArray(zeros(1,obj.n_trigger_inputs),'System.UInt32');
            %
            h = obj.h;
            
            [c2,s2,r2] = GetTrigger(h);
            
            trigger = mcs.stg.trigger.fromSDK(uint32(c2),uint32(s2),uint32(r2),...
                obj.n_analog_channels,obj.n_syncout_channels);
        end
        function setChannelCapacity(obj)
            
            
            
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
            
            
            %d.h.SetCapacity(uint32([1000 1000 1000 1000]),uint32([1000 1000 1000 1000]))
            
            %{
           a = NET.convertArray(10000*ones(1,4,'uint32'), 'System.UInt32');
           b  = NET.convertArray(10000*ones(1,4,'uint32'), 'System.UInt32');
           d.h.SetCapacity(a,b);
            %}
            
        end
        function chan_capacity = getChannelCapacity(obj)
            %
            %   In 
            [a,~] = obj.h.GetCapacity();
            chan_capacity = uint32(a);
        end
        function sync_capacity = getSyncCapacity(obj)
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
