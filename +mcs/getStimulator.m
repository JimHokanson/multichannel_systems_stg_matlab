function d = getStimulator(id)
%x Return a connected stimulator object
%
%   d = mcs.getStimulator(*index)
%
%   d = mcs.getStimulator(*serial)
%
%   d = mcs.getStimulator(*product)
%
%   Inputs
%   ------
%   index : default 1 (1 based)
%       Allows us to specify which stimulator to work with (if multiple
%       stimulators are connected.
%   serial : string
%       The serial number of the device.
%   product : string
%       The type of stimulator (see example). Note that unlike a serial or
%       an index a product string does not uniquelly identify a stimulator.
%
%   Outputs
%   -------
%   d : mcs.stg.sdk.cstg200x_download
%
%   Examples
%   --------
%   %By Product
%   d = mcs.getStimulator('STG4002')
%
%   Notes
%   -----
%   1) Streaming interface not supported
%
%   Improvements
%   ------------
%   1) When a product make sure that we only have 1 match

if nargin == 0
    id = 1;
end

if isnumeric(id)
    %   mcs.stg.sdk.cstg200x_download
    d = mcs.stg.sdk.cstg200x_download.fromIndex(id);
return
end

%We'll assume that serial and product don't overlap ...
devs = mcs.getDevicesInfo();
if isempty(devs)
    error('No stimulators found connected to computer')
end

for i = 1:length(devs)
    d = devs(i);
    if strcmpi(d.product,id) || strcmp(d.serial_number,id)
        d = d.getDownloadInterface();
        return
    end
end

error('Unable to find specified stimulator')


end