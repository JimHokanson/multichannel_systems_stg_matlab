function d = getStimulator(index)
%
%   d = mcs.getStimulator(index)
%
%   Inputs
%   ------

d = mcs.stg.sdk.cstg200x_download.fromIndex(index);

end