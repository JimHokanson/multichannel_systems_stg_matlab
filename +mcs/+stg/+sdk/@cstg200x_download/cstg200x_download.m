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
           %    Inputs
           %    ------
           %    channel_1b : 
           %    data : mcs.stg.pulse_train OR ...
           %        Currently only a pulse train input is supported.
           %
           %    Optional Inputs
           %    ---------------
           %    mode : string
           %        - 'new' (default)
           %        - 'append'
           %    mirror_to_sync : (default false)
           %        TODO
           %    sync_mode:
           %        - start
           %        - first_pulse
           %        - all_pulses
           %        - first_and_last_pulses - this could be tricky to
           %        define
           %        - start_and_end
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
           
           
           %    Implements
           %    ----------
           %    prepareAndSendData
           %    PrepareAndAppendData 
           
           in.mode = 'new';  
           in.mirror_to_sync = false;
           in = sl.in.processVarargin(in,varargin);
           [a,d] = data.getStimValues();
           %a - amplitude
           %d - durations
           
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
              
                
                
%               a = abs(a);
%               a(a > 1) = 1;
              
              a(a ~= 0) = 1;
              

              fh(channel_0b, a, d, type);
           else
               %TODO: If not mirrored, if we've previously mirrored to sync
               %the sync data will still be present in memory so the "new"
               %option isn't really "new"
           end
           
           
           
            
        end
    end
end

