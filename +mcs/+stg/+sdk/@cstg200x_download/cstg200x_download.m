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
    
    %Functions List
    %-----------------
    %mcs.stg.sdk.cstg200x_download_basic.setupTrigger
    %mcs.stg.sdk.cstg200x_basic.startStim
    
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
           %        Which channel or channels to send the data to
           %    data : mcs.stg.pulse_train OR ...
           %        Currently only a pulse train input is supported.
           %        For multiple channels a cell array should be used.
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
           %    use_sync : (default false)
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
           %
           %    Examples
           %    --------
           %
           %
           %
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
           in.use_sync = true;
           in.sync_mode = 'all_pulses';
           in.verify_capacity = true;
           in = mcs.sl.in.processVarargin(in,varargin);
           
           %a - amplitude
           %d - durations
           
           %TODO: Verify memory capacity
           
           %Needed for getting memory requirements for stim
           %c_stim : mcs.stg.sdk.c_stimulus_function
           c_stim = obj.stimulus;
           
           n_channels = length(channel_1b);
           if ~iscell(data)
               data = {data};
           end
           
           if length(data) == 1 && n_channels > 1
               temp = cell(1,n_channels);
               temp(:) = data{1};
               data = temp;
           end
           
           %Setup of raw outputs for hardware
           %----------------------------------------
           raw_data = struct('id',num2cell(channel_1b),'a',[],'d',[],'type','','s',[]);
           for i = 1:n_channels
               cur_data = data{i};
               [a,d] = cur_data.getStimValues();
               
               raw_data(i).a = a;
               raw_data(i).d = d;
               
               if strcmp(cur_data.output_type,'voltage')
                   type = mcs.enum.stg_destination.voltage;
               else
                   type = mcs.enum.stg_destination.current;
               end
               
               raw_data(i).type = type;
               
               if in.use_sync
                   %This could change depending on how we process sync ...
                   a(a ~= 0) = 1;
                   raw_data(i).s = a;
               end
           end
           
           %Memory setup 
           %------------------------------------------
           if in.set_mem
               [chan_capacity,sync_capacity] = obj.getChannelAndSyncCapacity();
               for i = 1:n_channels
                   cur_chan = channel_1b(i);
                   wtf1 = c_stim.prepareData(raw_data(i));
                   len = wtf1.DeviceDataLength;
                   chan_capacity(cur_chan) = len;
                   if in.use_sync
                       wtf1 = c_stim.prepareSyncData(raw_data(i));
                       len = wtf1.DeviceDataLength;
                       sync_capacity(cur_chan) = len;
                   end
               end
               obj.setChannelAndSyncCapacity(chan_capacity,sync_capacity);
           else
              error('Not yet implemented') 
           end
           

           %Upload stim to memory
           %---------------------------------
           sync_type = mcs.enum.stg_destination.sync;
           for i = 1:n_channels
               channel_0b = uint32(channel_1b(i)-1);
               r = raw_data(i);
               switch in.mode
                   case 'append'
                       obj.h.PrepareAndAppendData(channel_0b,r.a,r.d,r.type);
                       if in.use_sync
                          obj.h.PrepareAndAppendData(channel_0b,r.s,r.d,sync_type); 
                       end
                   case 'new'
                       obj.h.PrepareAndSendData(channel_0b,r.a,r.d,r.type);
                       if in.use_sync
                          obj.h.PrepareAndSendData(channel_0b,r.s,r.d,sync_type);
                       end
                   otherwise
                       error('Unrecognized mode')
               end
               if ~in.use_sync
                  %TODO: Need to make sure we clear sync memory ... 
               end
           end

 
        end
    end
end

