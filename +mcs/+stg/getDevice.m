function device = getDevice()
%x Retrieve a device to program
%
%   device = mcs.stg.getDevice()   
%
%   TODO: Add options


%   TODO: We need to flush out retrieval options
%
%   Retreival options
%   - index based
%   - serial number
%   - other options
%
%   Output options
%   - output type (download, streaming, basic)

device = mcs.stg.sdk.cstg200x_download.fromIndex(1);

end