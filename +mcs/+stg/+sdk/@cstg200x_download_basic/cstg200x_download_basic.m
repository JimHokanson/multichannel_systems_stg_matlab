classdef cstg200x_download_basic < mcs.stg.sdk.cstg200x_basic
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_download_basic
    
    %{
    
        d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
        d.setupTrigger;
    
        device = d.h;
    
        %1 nA
        %1 uV
    


       	device.PrepareAndSendData(0, Amplitude, Duration, Mcs.Usb.STG_DestinationEnumNet.channeldata_current);

    
        device.PrepareAndSendData(0, AmplitudeNet, DurationNet, STG_DestinationEnumNet.channeldata_voltage);
        device.SendStart(1);
    
    %}
    
    methods
        function obj = cstg200x_download_basic(h)
            %
            %   obj = mcs.stg.sdk.cstg200x_download_basic(h)
            
            obj = obj@mcs.stg.sdk.cstg200x_basic(h);

        end
        function setupTrigger(obj)
            
            %TODO: Allow inputs ...
            %TODO: Allow 
            
%             virtual void SetupTrigger  ( uint32_t  first_trigger,  
%   array< uint32_t >^  channelmap,  
%   array< uint32_t >^  syncoutmap,  
%   array< uint32_t >^  repeat  
%  )  [virtual] 

            %   Inputs
            %   ------
            %   first_trigger :
            %   chan_map : 
            %       Which channels get triggered by a trigger (as bit mask)
            %   sync_map :
            %       Which syncs get triggered by a trigger (as bit mask)
            %   repeat : 

            %repeat
            %-------------
            %0 - forever
            %
            
            first_trigger = 0;
            channel_map = uint32([1 2]);
            syncout_map = uint32([1 2]);
            repeat = uint32([0 0 ]);

            obj.h.SetupTrigger(first_trigger,channel_map,syncout_map,repeat)

        end
        
        function s3 = getTrigger(obj)
            c = uint32([0 0]);
            s = uint32([0 0]);
            r = uint32([0 0]);

            c2 = NET.convertArray(c,'System.UInt32');
            s2 = NET.convertArray(s,'System.UInt32');
            r2 = NET.convertArray(r,'System.UInt32');
            obj.h.GetTrigger(c2,s2,r2);
            keyboard
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
