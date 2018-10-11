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
            %   value = prepareData(obj,data)
            %
            %   Inputs
            %   ------
            %   data : struct or object
            %       struct with fields a,d or function [a,d] = data.getStimValues();
            %
            %       TODO: Update documentation, needs type support ...
            %   
            %   Output
            %   ------
            %   value : Mcs.Usb.StimulusDeviceDataAndUnrolledData (.NET)
            %       Note I don't wrap the structure, it is just the raw
            %       output from the function call.
            %       Example:
            %           .UnrolledDuration: [1×1 System.UInt64[]]
            %           .UnrolledSync: [1×1 System.UInt32[]]
            %           .UnrolledAmplitude: [1×1 System.Int32[]]
            %           .DeviceDataLength: 14
            %           .DeviceData: [1×1 System.Byte[]]
            %
            %       
            %
            %   See Also
            %   --------
            %   prepareSyncData
            %   mcs.stg.sdk.cstg200x_download.sentDataToDevice
            
            %var preparedData = device.Stimulus.PrepareData(amplitude, duration,    STG_DestinationEnumNet.channeldata_voltage);
            %int lengthInBytes = preparedData.DeviceDataLength;
            

            if isstruct(data)
                a = data.a;
                d = data.d;
                type = data.type;
            else
                [a,d] = data.getStimValues();
            	if strcmp(data.output_type,'voltage')
                   type = mcs.enum.stg_destination.voltage;
                else
                   type = mcs.enum.stg_destination.current;
                end
            end

            value = obj.h.PrepareData(a,d,type);
        end
        function value = prepareSyncData(obj,data)
            %
            %   TODO: Update documentation, very similar to prepareData
            if isstruct(data)
                a = data.s; %Note we use s here for sync
                d = data.d;
            else
                [a,d] = data.getStimValues();
                a(a ~= 0) = 1;
            end
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