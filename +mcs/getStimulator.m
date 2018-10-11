function d = getStimulator(index)
%
%   d = mcs.getStimulator(*index)
%
%   Inputs
%   ------
%   index : default 1 (1 based)
%       Allows us to specify which stimulator to work with (if multiple
%       stimulators are connected.
%
%   Outputs
%   -------
%   d : mcs.stg.sdk.cstg200x_download

if nargin == 0
    index = 1;
end

d = mcs.stg.sdk.cstg200x_download.fromIndex(index);

end