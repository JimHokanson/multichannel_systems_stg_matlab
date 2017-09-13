classdef stg_destination
    %
    %   Class:
    %   mcs.enum.stg_destination
    
    properties (Constant)
        voltage = h__loadValue(1)
        current = h__loadValue(2)
        sync = h__loadValue(3)
        current_and_boost_gnd_sync = h__loadValue(4)
        current_and_sync = h__loadValue(5)
        positive_current = h__loadValue(6)
        positive_current_and_boost_gnd_sync = h__loadValue(7)
        positive_current_and_sync = h__loadValue(8)
    end
    
    methods
    end
    
end

function value_out = h__loadValue(value_in)

    mcs.stg.sdk.load();
    
    switch value_in
        case 1
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_voltage;
        case 2
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_current;
        case 3
            value_out = Mcs.Usb.STG_DestinationEnumNet.syncoutdata;  
            
        %http://multichannelsystems.forumieren.de/t461-mcs-usb-stg_destinationenumnet-descriptions-prepareandsenddata-and-voltage-and-current-modes
        %
        %These apparently relate to the use of stimulation headstages ...
        case 4
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_current_and_boost_gnd_sync;  
        case 5
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_current_and_sync;
        case 6
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_positive_current;
        case 7
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_positive_current_and_boost_gnd_sync;
        case 8
            value_out = Mcs.Usb.STG_DestinationEnumNet.channeldata_positive_current_and_sync;
    end
    
    
end