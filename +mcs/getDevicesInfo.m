function devs = getDevicesInfo()
%
%   devs = mcs.getDevicesInfo()
%
%   Note this only provides high level info. 
%
%   Outputs
%   -------
%   devs : mcs.stg.sdk.device_list_entry

dl = mcs.stg.sdk.device_list();
devs = dl.getAllEntries();

end