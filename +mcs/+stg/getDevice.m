function device = getDevice()
%x Retrieve a device to program
%
%   device = mcs.stg.getDevice()   
%
%   TODO: Add options
%
%   TODO: replace all instances of this with
%   mcs.getStimulator()


%   TODO: We need to flush out retrieval options
%
%   Retreival options
%   - index based
%   - serial number
%   - other options
%
%   Output options
%   - output type (download, streaming)

device = mcs.stg.sdk.cstg200x_download.fromIndex(1);

end