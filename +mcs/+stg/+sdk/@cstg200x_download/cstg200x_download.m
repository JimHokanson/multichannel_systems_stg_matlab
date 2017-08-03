classdef cstg200x_download < mcs.stg.sdk.cstg200x_download_basic
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_download
    %
    %   Wraps:
    %   Mcs.Usb.CStg200xDownloadNet
    
    %{
    
    Test Code
    ----------
    d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    d.setCurrentMode();
    pt2 = 200*mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2,'n_trains',1,'output_type','current');
    
    d = mcs.stg.sdk.cstg200x_download.fromIndex(1);
    d.setVoltageMode();
    pt2 = 200*mcs.stg.pulse_train.fixed_rate(40,'n_pulses',3,'train_rate',2,'n_trains',1,'output_type','voltage');
    
    d.setupTrigger('first_trigger',1,'repeat',0)
    
    d.sentDataToDevice(1,pt2);
    
    d.sendStart(1);
    d.sendStop(1);
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
            entry = dl.getEntry(index_1b);
            obj = entry.getDownloadInterface();
        end
    end
    
    methods
        function obj = cstg200x_download(h)
            %
            %   obj = mcs.stg.sdk.cstg200x_download(h)
            
            obj = obj@mcs.stg.sdk.cstg200x_download_basic(h);
        end
    end
    methods
        function sentDataToDevice(obj,channel_1b,data,varargin)
           %
           %    
           %    Inputs
           %    ------
           %    channel_1b : 
           %    data : mcs.stg.pulse_train OR ...
           %    
           %
           %    Optional Inputs
           %    ---------------
           %    mode : string
           %        - 'new' (default)
           %        - 'append'
           %    target :
           %        - 'sync'
           %        - 'current'
           %        - 'voltage'
           %
           %    TODO: Does specifying current or voltage change the mode?
           %
           %
           %    Implements
           %    ----------
           %    prepareAndSendData
           %    PrepareAndAppendData 
           
           in.mode = 'new';           
           [a,d] = data.getStimValues();
           
           %TODO: Allow specifying sync as well
           

           if strcmp(data.output_type,'voltage')
              type = Mcs.Usb.STG_DestinationEnumNet.channeldata_voltage;
           else
              type = Mcs.Usb.STG_DestinationEnumNet.channeldata_current;
           end

           
           channel_0b = uint32(channel_1b-1);
           
           switch in.mode
               case 'append'
                   obj.h.PrepareAndAppendData(channel_0b, a, d, type);
               case 'new'
                   obj.h.PrepareAndSendData(channel_0b, a, d, type);
               otherwise
                   error('Unrecognized mode')
           end
            
        end
    end
    
end

