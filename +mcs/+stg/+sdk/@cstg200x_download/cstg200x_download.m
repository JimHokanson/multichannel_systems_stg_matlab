classdef cstg200x_download < mcs.stg.sdk.cstg200x_download_basic
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_download
    %
    %   Wraps:
    %   Mcs.Usb.CStg200xDownloadNet
    %
    %   This class is the non-abstract interface for download-mode control
    %   of the stimulator.
    %
    %   Constructors
    %   ------------
    %   1) mcs.stg.sdk.cstg200x_download.fromIndex
    %   2) Accessing the device list and then retrieval of an entry and 
    %   its download interface.
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk
    %   mcs.stg.sdk.cstg200x_download_basic
    %   mcs.stg.sdk.cstg200x_basic
    
    %{
    
    Test Code
    ----------
    d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    d.setCurrentMode();
    d.setupTrigger('first_trigger',1,'repeats',0)
    pt2 = 600*mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2,'n_trains',1);
    d.sentDataToDevice(1,pt2,'mirror_to_sync',true);
    d.startStim();
    d.stopStim();
    
    
    
    d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    d.setVoltageMode();
    d.setupTrigger('first_trigger',1,'repeats',0)
    pt2 = 500*mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2,'n_trains',1,'amp_units','mV');
    d.sentDataToDevice(1,pt2,'mirror_to_sync',true);
    
    d.startStim();
    d.stopStim();
    %}
    
    properties
        
    end
    
    methods (Static)
        function obj = fromIndex(index_1b)
            %x Create instance from device list index
            %
            %   obj = mcs.stg.sdk.cstg200x_download.fromIndex(index_1b)
            %
            %   Examples
            %   --------
            %   d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
            
            dl = mcs.stg.sdk.device_list();
            
            %mcs.stg.sdk.device_list_entry
            entry = dl.getEntry(index_1b);
            
            obj = entry.getDownloadInterface();
        end
    end
    
    methods
        function obj = cstg200x_download(h)
            %x Constructor for download class
            %
            %   obj = mcs.stg.sdk.cstg200x_download(h)
            %
            %   This class can be created from:
            %   1) The fromIndex() method of this class
            %   2) From getDownloadInterface() of mcs.stg.sdk.device_list_entry
            
            obj = obj@mcs.stg.sdk.cstg200x_download_basic(h);
        end
    end
    methods
        function sentDataToDevice(obj,channel_1b,data,varargin)
           %x Sends data to the device
           %
           %    sentDataToDevice(obj,channel_1b,data,varargin)
           %    
           %    Inputs
           %    ------
           %    channel_1b : 
           %        Which channel to send the data to ...
           %    data : mcs.stg.pulse_train OR ...
           %        Currently only a pulse train input is supported.
           %
           %    Optional Inputs
           %    ---------------
           %    set_mem : default true
           %        This should basically always be true unless you wanted
           %        to append, then all memory management would need to be
           %        done before uploading.
           %    mode : string
           %        - 'new' (default)
           %        - 'append' NYI - requires complicated memory management
           %    mirror_to_sync : (default false)
           %        If true, sync_mode is applied to generate a sync
           %        pattern to play.
           %    sync_mode: NYI (default 'all_pulses')
           %        Only all_pulses is implemented
           %        - 'start' - sync pulse corresponding to t = 0
           %                    => this would require a duration for the
           %                    sync
           %        - 'first_pulse' - only make first pulse show up as sync
           %        - 'all_pulses' - all pulses show up as sync
           %        - 'first_and_last_pulses' - this could be tricky to define
           %                because of repeats
           %        - 'start_and_end' - also tricky, when do we stop
           %
           %        I think it is best to only implement the first 3 and
           %        then provide sync functionality ...
           %
           %    sync_pattern: NYI
           %        The idea here is that we would allow a specification
           %        of the exact sync pattern, similar to how we 
           %        allow a pattern for the data.
           %
           %    TODO: The sync generation should be its own functionality.
           %
           %    Sync can only be 0 or 1
           %
           %    See Also
           %    ---------
           %    
           %
           %    Improvements
           %    -------------
           %    1) Don't allow this if we are stimulating already
           %
           %
           %    Implements
           %    ----------
           %    prepareAndSendData
           %    PrepareAndAppendData 
           
           in.set_mem = true;
           in.mode = 'new';  
           in.mirror_to_sync = false;
           in.sync_mode = 'all_pulses';
           in.verify_capacity = true;
           in = sl.in.processVarargin(in,varargin);
           [a,d] = data.getStimValues();
           %a - amplitude
           %d - durations
           
           %TODO: Verify memory capacity
           
           c_stim = obj.stimulus;
                      
           
           
           if SET_MEM
               wtf1 = c_stim.prepareData(data);
               obj.setChannelCapacity(wtf1.DeviceDataLength,'start_chan',channel_1b);
               if in.mirror_to_sync
                  %I think this call is unecessary, because I think
                  %only the length is needed, which is the same as 1
                  %for now ...
                  wtf2 = c_stim.prepareSyncData(data);
                  obj.setSyncCapacity(wtf2.DeviceDataLength,'start_chan',channel_1b);
               end
           end
           
           %TODO: Allow specifying sync as well
           

           if strcmp(data.output_type,'voltage')
              type = mcs.enum.stg_destination.voltage;
           else
              type = mcs.enum.stg_destination.current;
           end

           channel_0b = uint32(channel_1b-1);
           
           switch in.mode
               case 'append'
                   fh = @(a,b,c,d)obj.h.PrepareAndAppendData(a,b,c,d);
               case 'new'
                   %TODO: Ask about this ...
                   %JAH: I had to provide inputs because 
                   %I couldn't bind to the function otherwise
                   %e.g. fh = @obj.h.PrepareAndSendData;
                   fh = @(a,b,c,d)obj.h.PrepareAndSendData(a,b,c,d);
               otherwise
                   error('Unrecognized mode')
           end
           
          
           %Execute command - append or new
           fh(channel_0b, a, d, type);
           
           if in.mirror_to_sync
              %TODO: Support manipulation of sync (if necessary)

              type = mcs.enum.stg_destination.sync;

              %It appears that the only valid values are 0 and 1
              %
              %other values will cause the sync to dissapear
              %
              %Also, there is a slight shift (20 us?) betwen the sync
              %pulse and the stim output (seen in voltage & current mode)
              %
              %This is documented somewhere in the manual
                % - "  " current, 15 us for continuous mode
                % - "  " current, 50 us if not continuous mode
              a(a ~= 0) = 1;
%               wtf2 = c_stim.prepareSyncData(data);
%               if SET_MEM
%                  %obj.setSyncCapacity(wtf2.DeviceDataLength,'start_chan',channel_1b);
%                  obj.setSyncCapacity(14);
%               end

              

              fh(channel_0b, a, d, type);
           else
               %TODO: If not mirrored, if we've previously mirrored to sync
               %the sync data will still be present in memory so the "new"
               %option isn't really "new"
               %c_stim.ClearSyncData
           end
           
           
           
            
        end
    end
end

