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
            entries = dl.getAllEntries();
            if index_1b > length(entries)
                error('mcs:stg:sdk:cstg200x_download:fromIndex',...
                    'Device requested: %d, is greater than the # of STG devices present: %d',...
                    index_1b,length(entries))
            end
            entry = entries(index_1b);

            obj = entry.getDownloadInterface();
        end
    end
    
    methods
        function obj = cstg200x_download(h,varargin)
            %x Constructor for download class
            %
            %   obj = mcs.stg.sdk.cstg200x_download(h)
            %
            %   This class can be created from:
            %   1) The fromIndex() method of this class
            %   2) From getDownloadInterface() of mcs.stg.sdk.device_list_entry
            
            obj = obj@mcs.stg.sdk.cstg200x_download_basic(h,varargin{:});
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
           %    1) Don't allow this if we are stimulating already.
           %       This method may resize channel/sync memory. Use
           %       reserveChannelCapacity() before stimulation and
           %       updateChannelData() during stimulation.
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

           channels_1b = double(channels_1b(:)');
           n_channels = length(channels_1b);
           compute_lengths = obj.usesExplicitCapacityAllocation();
           [raw_data,channel_lengths,sync_lengths] = ...
               obj.prepareRawDataForDevice(channels_1b,data,in.use_sync,compute_lengths);

           %Memory setup
           %------------------------------------------
           if obj.usesExplicitCapacityAllocation()
               %get current values, then override with what we are going
               %to use
               [chan_capacity,sync_capacity] = obj.getChannelAndSyncCapacity();
               for i = 1:n_channels
                   cur_chan = channels_1b(i);
                   chan_capacity(cur_chan) = channel_lengths(i);
                   if in.use_sync
                       sync_capacity(cur_chan) = sync_lengths(i);
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
           end

           obj.uploadRawDataToDevice(raw_data,in.mode,in.use_sync);

        end
        function reserveChannelCapacity(obj,channels_1b,data,varargin)
           %x Reserve channel/sync memory for later runtime uploads
           %
           %   reserveChannelCapacity(obj,channels_1b,data,varargin)
           %
           % This method changes the STG memory layout and should be called
           % before any stimulation is running. It does not upload stimulus
           % data. Use it to allocate enough memory for channels that will
           % receive updateChannelData() calls later.
           %
           % Optional Inputs
           % ---------------
           % use_sync : default true
           % require_no_active_triggers : default true
           %     Refuse to resize memory if this MATLAB object has started
           %     triggers that have not been stopped through this object.
           %
           % For drivers without explicit capacity allocation this method
           % validates the input pattern and returns without calling
           % SetCapacity.

           ERR_ID = 'mcs:stg:sdk:cstg200x_download:reserveChannelCapacity';

           in.use_sync = true;
           in.require_no_active_triggers = true;
           in = mcs.sl.in.processVarargin(in,varargin);

           if ~obj.usesExplicitCapacityAllocation()
               % Keep this helper harmless on drivers that upload directly
               % and do not expose GetCapacity/SetCapacity.
               channels_1b = double(channels_1b(:)');
               obj.prepareRawDataForDevice(channels_1b,data,in.use_sync,false);
               warning(ERR_ID,...
                   ['No capacity reservation was performed for this device family. ',...
                   'Runtime uploads will be sent directly to the target channel ',...
                   'without pre-verifying reserved memory.'])
               return
           end

           if in.require_no_active_triggers && ~isempty(obj.active_triggers_1b)
               error(ERR_ID,...
                   ['Refusing to resize STG memory while triggers [%s] are known active. ',...
                   'Stop stimulation before reserving channel capacity.'],...
                   num2str(obj.active_triggers_1b))
           end

           channels_1b = double(channels_1b(:)');
           [~,channel_lengths,sync_lengths] = ...
               obj.prepareRawDataForDevice(channels_1b,data,in.use_sync,true);

           [chan_capacity,sync_capacity] = obj.getChannelAndSyncCapacity('fallback_to_empty',true);
           for i = 1:length(channels_1b)
               cur_chan = channels_1b(i);
               chan_capacity(cur_chan) = max(chan_capacity(cur_chan),channel_lengths(i));
               if in.use_sync
                   sync_capacity(cur_chan) = max(sync_capacity(cur_chan),sync_lengths(i));
               end
           end

           obj.setChannelAndSyncCapacity(chan_capacity,sync_capacity,'fallback_to_empty',true);
        end
        function updateChannelData(obj,channel_1b,data,varargin)
           %x Replace data on one reserved, idle channel without resizing memory
           %
           %   updateChannelData(obj,channel_1b,data,varargin)
           %
           % This is the guarded runtime upload path. It is intended for
           % uploading a new stimulus to an idle channel while other
           % channels continue running. It refuses to call SetCapacity().
           %
           % Optional Inputs
           % ---------------
           % use_sync : default true
           % verify_capacity : default true when the driver exposes
           %     explicit capacity allocation.
           %     Verify the new data fits in the current channel/sync
           %     capacity before uploading.
           % require_target_idle : default true
           %     Refuse if the target channel is mapped to a trigger known
           %     active through this MATLAB object.

           ERR_ID = 'mcs:stg:sdk:cstg200x_download:updateChannelData';

           in.use_sync = true;
           in.verify_capacity = obj.usesExplicitCapacityAllocation();
           in.require_target_idle = true;
           in = mcs.sl.in.processVarargin(in,varargin);

           if ~isscalar(channel_1b)
               error(ERR_ID,'Runtime updates are restricted to one channel at a time.')
           end

           if in.verify_capacity && ~obj.usesExplicitCapacityAllocation()
               error(ERR_ID,...
                   ['Runtime capacity verification is unavailable because this driver ',...
                   'does not expose GetCapacity/SetCapacity. Call with ',...
                   'verify_capacity=false only after validating this workflow on hardware.'])
           end

           channel_1b = double(channel_1b);
           compute_lengths = in.verify_capacity;
           [raw_data,channel_lengths,sync_lengths] = ...
               obj.prepareRawDataForDevice(channel_1b,data,in.use_sync,compute_lengths);

           if in.require_target_idle
               obj.assertChannelsKnownIdle(channel_1b);
           end

           if in.verify_capacity
               obj.assertReservedCapacity(raw_data,channel_lengths,sync_lengths,in.use_sync);
           end

           obj.uploadRawDataToDevice(raw_data,'new',in.use_sync);
        end
    end
    methods (Access = private)
        function [raw_data,channel_lengths,sync_lengths] = prepareRawDataForDevice(obj,channels_1b,data,use_sync,compute_lengths)
            ERR_ID = 'mcs:stg:sdk:cstg200x_download:prepareRawDataForDevice';

            if nargin < 5
                compute_lengths = true;
            end

            channels_1b = double(channels_1b(:)');
            n_channels = length(channels_1b);
            if n_channels == 0
                error(ERR_ID,'At least one channel must be specified.')
            end

            if ~iscell(data)
                data = {data};
            end

            if isscalar(data) && n_channels > 1
                data = repmat(data,1,n_channels);
            elseif numel(data) ~= n_channels
                error(ERR_ID,...
                    'The number of data entries must match the number of channels.')
            end

            raw_data = repmat(struct(...
                'id',[],...
                'a',[],... %amplitudes
                'd',[],... %durations
                'type',[],...
                'output_type','',...
                's',[],... %sync_amplitude
                'sd',[]),1,n_channels);  %sync_durations

            channel_lengths = zeros(1,n_channels,'uint32');
            sync_lengths = zeros(1,n_channels,'uint32');
            if compute_lengths
                c_stim = obj.stimulus;
            end

            for i = 1:n_channels
                cur_data = data{i};
                [a,d] = cur_data.getStimValues();

                raw_data(i).id = channels_1b(i);
                raw_data(i).a = a;
                raw_data(i).d = d;
                raw_data(i).output_type = cur_data.output_type;

                if strcmp(cur_data.output_type,'voltage')
                    raw_data(i).type = mcs.enum.stg_destination.voltage;
                else
                    raw_data(i).type = mcs.enum.stg_destination.current;
                end

                if use_sync
                    %TODO: Pass this back to the pattern to process.
                    s = a;
                    s(s ~= 0) = 1;
                    raw_data(i).s = s;

                    % Extend very short biphasic sync pulses for 20 kHz
                    % acquisition while preserving the total duration.
                    sd = d;
                    if length(d) == 3 && d(1) == 20 && d(2) == 20 && d(3) >= 40 && s(3) == 0
                        sd(2) = 40; %add 20 to 2nd phase
                        sd(3) = d(3)-20; %remove 20 off zero phase
                    end
                    raw_data(i).sd = sd;
                end

                if compute_lengths
                    prepared_data = c_stim.prepareData(raw_data(i));
                    channel_lengths(i) = uint32(prepared_data.DeviceDataLength);
                    if use_sync
                        prepared_sync = c_stim.prepareSyncData(raw_data(i));
                        sync_lengths(i) = uint32(prepared_sync.DeviceDataLength);
                    end
                end
            end
        end
        function uploadRawDataToDevice(obj,raw_data,mode,use_sync)
            sync_type = mcs.enum.stg_destination.sync;
            for i = 1:length(raw_data)
                r = raw_data(i);
                obj.setChannelModeForRawData(r);
                channel_0b = uint32(r.id-1);
                switch mode
                    case 'append'
                        obj.h.PrepareAndAppendData(channel_0b,r.a,r.d,r.type);
                        if use_sync
                            obj.h.PrepareAndAppendData(channel_0b,r.s,r.sd,sync_type);
                        end
                    case 'new'
                        obj.h.PrepareAndSendData(channel_0b,r.a,r.d,r.type);
                        if use_sync
                            obj.h.PrepareAndSendData(channel_0b,r.s,r.sd,sync_type);
                        end
                    otherwise
                        error('mcs:stg:sdk:cstg200x_download:uploadRawDataToDevice',...
                            'Unrecognized upload mode: %s',mode)
                end
            end
        end
        function setChannelModeForRawData(obj,r)
            if strcmp(r.output_type,'voltage')
                obj.setVoltageMode(r.id);
            else
                obj.setCurrentMode(r.id);
            end
        end
        function assertReservedCapacity(obj,raw_data,channel_lengths,sync_lengths,use_sync)
            ERR_ID = 'mcs:stg:sdk:cstg200x_download:assertReservedCapacity';

            [chan_capacity,sync_capacity] = obj.getChannelAndSyncCapacity();
            for i = 1:length(raw_data)
                cur_chan = raw_data(i).id;
                if chan_capacity(cur_chan) < channel_lengths(i)
                    error(ERR_ID,...
                        ['Channel %d needs %d bytes but only %d bytes are reserved. ',...
                        'Call reserveChannelCapacity() before starting stimulation, ',...
                        'or stop all stimulation before using sentDataToDevice().'],...
                        cur_chan,channel_lengths(i),chan_capacity(cur_chan))
                end

                if use_sync && sync_capacity(cur_chan) < sync_lengths(i)
                    error(ERR_ID,...
                        ['Sync %d needs %d bytes but only %d bytes are reserved. ',...
                        'Call reserveChannelCapacity() before starting stimulation, ',...
                        'or stop all stimulation before using sentDataToDevice().'],...
                        cur_chan,sync_lengths(i),sync_capacity(cur_chan))
                end
            end
        end
        function assertChannelsKnownIdle(obj,channels_1b)
            ERR_ID = 'mcs:stg:sdk:cstg200x_download:assertChannelsKnownIdle';

            if isempty(obj.active_triggers_1b)
                return
            end

            channel_maps = obj.cached_trigger_channel_maps;
            if isempty(channel_maps)
                try
                    trigger = obj.getTrigger();
                    channel_maps = trigger.channel_maps.values;
                catch ME
                    error(ERR_ID,...
                        ['Unable to verify whether the target channel is controlled ',...
                        'by a known active trigger. Call setupTrigger() before ',...
                        'starting stimulation so the trigger map can be cached. ',...
                        'Original MCS error: %s'],ME.message)
                end
            end

            for i = 1:length(obj.active_triggers_1b)
                cur_trigger = obj.active_triggers_1b(i);
                if cur_trigger > length(channel_maps)
                    error(ERR_ID,...
                        ['Unable to verify trigger %d because it is not present ',...
                        'in the cached trigger map. Call setupTrigger() before ',...
                        'starting stimulation so the full trigger map is cached.'],...
                        cur_trigger)
                end
                cur_map = uint32(channel_maps(cur_trigger));
                for j = 1:length(channels_1b)
                    cur_chan = channels_1b(j);
                    if bitget(cur_map,cur_chan)
                        error(ERR_ID,...
                            ['Refusing to update channel %d because trigger %d is ',...
                            'known active and maps to that channel. Stop the ',...
                            'trigger before replacing its channel data.'],...
                            cur_chan,cur_trigger)
                    end
                end
            end
        end
    end
end
