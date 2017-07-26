classdef cstg200x_download < mcs.stg.sdk.cstg200x_download_basic
    %
    %   Class:
    %   mcs.stg.sdk.cstg200x_download
    %
    %   Wraps:
    %   Mcs.Usb.CStg200xDownloadNet
    
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
        function prepareAndSendData(obj,channel,amplitude,duration,dest_type)
            %
            
%                     Amplitude = int32([+1e5 -1e5 0]);  	
%         Duration = uint64([1000 1000 1e6]);  % Duration in us
% 
%         AmplitudeNet = NET.convertArray(Amplitude, 'System.Int32');
%         DurationNet  = NET.convertArray(Duration, 'System.UInt64');
%                    	device.PrepareAndSendData(0, Amplitude, Duration, Mcs.Usb.STG_DestinationEnumNet.channeldata_current);
% 
%     
%         device.PrepareAndSendData(0, AmplitudeNet, DurationNet, STG_DestinationEnumNet.channeldata_voltage);
            
            
            
                    %             Prepare and send data to a given channel on the STG. Previous data sent to that channel is erased first. 
                    % 
                    % Each datapoint is represented by an signed 32bit integer value. When using voltage stimulation, the values are in multiple of 1 uV, thus the possible range is += 2000 V. When using current stimulation, the values are in multiple of 1 nA, this the possible range is += 2000 mA. 
                    % 
                    % The duration is given as a list of 64 bit integers. Durations are given in units of µs. The STG has a resolution of 20 µs.
                    % 
                    % Parameters:
                    % channel The channel number to send data to. 
                    % Amplitude A list of datapoints as int32. 
                    % Duration A list of durations as uint64. The time is given in units of µs. 
                    % dest_type specifies wheather the data is for syncout, current or voltage stimulation.
                    
                    
                    
                    
                    
                
        end
    end
    
end

