classdef c_stimulus_function
    %
    %   Class:
    %   mcs.stg.sdk.c_stimulus_function
    %
    %   See Also
    %   --------
    %   mcs.stg.sdk.cstg200x_download_basic
    %
    %   This is mainly duplicated elsewhere. It was recommended to me
    %   by MCS since it exposes a prepare function which explicitly states
    %   how much memory is needed.
    
    
    %{
    s = d.stimulus
    pt = 500*mcs.stg.pulse_train.fixed_rate(40);
    wtf = s.prepareData(pt);
    %}
    
    properties (Hidden)
        h
    end
    
    properties
        %memory
        %n_analog_channels
        %total_memory
    end
    
    methods
        function obj = c_stimulus_function(h)
            %
            %   obj = mcs.stg.sdk.c_stimulus_function(h)
            
            obj.h = h;
        end
        function value = prepareData(obj,data)
            %
            %
            %
            %   Output
            %   ------
            %   value : Mcs.Usb.StimulusDeviceDataAndUnrolledData (.NET)
            %     .UnrolledDuration: [1×1 System.UInt64[]]
            %     .UnrolledSync: [1×1 System.UInt32[]]
            %     .UnrolledAmplitude: [1×1 System.Int32[]]
            %     .DeviceDataLength: 14
           %      .DeviceData: [1×1 System.Byte[]]
            
            %var preparedData = device.Stimulus.PrepareData(amplitude, duration,    STG_DestinationEnumNet.channeldata_voltage);
            %int lengthInBytes = preparedData.DeviceDataLength;
            
            [a,d] = data.getStimValues();
            if strcmp(data.output_type,'voltage')
               type = mcs.enum.stg_destination.voltage;
            else
               type = mcs.enum.stg_destination.current;
            end
            value = obj.h.PrepareData(a,d,type);
        end
        function value = prepareSyncData(obj,data)
            [a,d] = data.getStimValues();
            a(a ~= 0) = 1;
            type = mcs.enum.stg_destination.sync;
            value = obj.h.PrepareData(a,d,type);
        end
        function clearSyncData(obj)
            %TODO: I'm not sure how to call this since no documentation
            %exists
        end
    end
    
end

%{
CStimulusFunctionNet             
ClearChannelData                 
ClearChannel_PrepareAndSendData  
ClearSyncData                    
CreateSideband                   
Dispose                          
Equals                           
ForceStatusEvent                 
GetCurrentRangeInNanoAmp         
GetCurrentResolutionInNanoAmp    
GetDACResolution                 
GetHashCode                      
GetMemory                        
GetNumberOfAnalogChannels        
GetTotalMemory                   
GetType                          
GetVoltageRangeInMicroVolt       
GetVoltageResolutionInMicroVolt  
PrepareAndAppendData             
PrepareAndSendData               
PrepareData                      
SendPreparedData                 
SendStart                        
SendStop                         
SetupTrigger                     
StartPoll                        
StopPoll                         
ToString                

%}