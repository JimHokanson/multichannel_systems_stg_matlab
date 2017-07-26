function list = getDeviceList()
%
%   list = mcs.stg.getDeviceList

    list = mcs.stg.sdk.device_list();
end