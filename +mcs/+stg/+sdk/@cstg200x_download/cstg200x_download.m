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
        function sentDataToDevice(obj,channels_1b,data,varargin)
           %x Sends data to the device
           %
           %    sentDataToDevice(obj,channels_1b,data,varargin)
           %    
           %    Inputs
           %    ------
           %    channels_1b : 
           %        Which channel or channels to send the data to.
           %    data : mcs.stg.pulse_train
           %        Currently only a pulse train input is supported.
           %        For multiple channels a cell array should be used.
           %        e.g. .sentDataToDevice([1 3],{pt1 pt3})
           %
           %    Optional Inputs
           %    ---------------
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
           
           in.mode = 'new';  
           in.use_sync = true;
           in.sync_mode = 'all_pulses';
           in.verify_capacity = true; %NYI ...
           in = mcs.sl.in.processVarargin(in,varargin);
           
           %a - amplitude
           %d - durations
           
           %TODO: Verify memory capacity
           
           %Needed for getting memory requirements for stim
           %c_stim : mcs.stg.sdk.c_stimulus_function
           c_stim = obj.stimulus;
           
           n_channels = length(channels_1b);
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
           %struct for sending to HW
           raw_data = struct(...
               'id',num2cell(channels_1b),...
               'a',[],... %amplitudes
               'd',[],... %durations
               'type','',...
               's',[],... %sync_amplitude
               'sd',[]);  %sync_durations
           
           %Grab stim and sync data
           %---------------------------------
           for i = 1:n_channels
               cur_data = data{i};
               cur_channel = channels_1b(i);
               [a,d] = cur_data.getStimValues();
               
               raw_data(i).a = a;
               raw_data(i).d = d;
               
               if strcmp(cur_data.output_type,'voltage')
                   type = mcs.enum.stg_destination.voltage;
                   obj.setVoltageMode(cur_channel);
               else
                   type = mcs.enum.stg_destination.current;
                   obj.setCurrentMode(cur_channel);
               end
               
               raw_data(i).type = type;
               
               if in.use_sync
                   
                   %TODO: Pass this back to the pattern to process
                   
                   %This could change depending on how we process sync ...
                   a(a ~= 0) = 1;
                   raw_data(i).s = a;
                   
                   %Ideally we would have something like a minimum
                   %high time based on the sampling rate
                   %
                   %TEMP JIM HACK, extend sync for 20k sampling
                   USE_HACK = 1; %set to 0 to revert to old behavior
                   if USE_HACK
                       if length(d) == 3 && d(1) == 20 && d(2) == 20 && d(3) >= 40 && a(3) == 0
                           sd = d;
                           sd(2) = 40; %add 20 to 2nd phase
                           sd(3) = d(3)-20; %remove 20 off zero phase
                       else
                           sd = d;
                       end
                   else
                       sd = d;
                   end
                   raw_data(i).sd = sd;
               end
           end
           
           %Memory setup 
           %------------------------------------------
           %get current values, then override with what we are going
           %to use
           [chan_capacity,sync_capacity] = obj.getChannelAndSyncCapacity();
           for i = 1:n_channels
               cur_chan = channels_1b(i);
               wtf1 = c_stim.prepareData(raw_data(i));
               len = wtf1.DeviceDataLength;
               chan_capacity(cur_chan) = len;
               if in.use_sync
                   %mcs.stg.sdk.c_stimulus_function>prepareSyncData
                   wtf1 = c_stim.prepareSyncData(raw_data(i));
                   len = wtf1.DeviceDataLength;
                   sync_capacity(cur_chan) = len;
               else
                   %TODO: Write test case for this ...
                   %This should mean that if we switch to a stim only
                   %condition the sync doesn't show up still
                   sync_capacity(cur_chan) = 0;
               end
           end
           %Note, this call below must be done simultaneously as 
           %modification of one can impact the other
           obj.setChannelAndSyncCapacity(chan_capacity,sync_capacity);
           

           %Upload stim to memory
           %---------------------------------
           sync_type = mcs.enum.stg_destination.sync;
           for i = 1:n_channels
               channel_0b = uint32(channels_1b(i)-1);
               r = raw_data(i);
               switch in.mode
                   case 'append'
                       obj.h.PrepareAndAppendData(channel_0b,r.a,r.d,r.type);
                       if in.use_sync
                          obj.h.PrepareAndAppendData(channel_0b,r.s,r.sd,sync_type); 
                       end
                   case 'new'
                       obj.h.PrepareAndSendData(channel_0b,r.a,r.d,r.type);
                       if in.use_sync
                          obj.h.PrepareAndSendData(channel_0b,r.s,r.sd,sync_type);
                       end
                   otherwise
                       error('Unrecognized mode')
               end
           end

 
        end
    end
end

