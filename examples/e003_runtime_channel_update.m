%e003_runtime_channel_update
%
% Demonstrates uploading data to one idle channel while another channel is
% already running.
%
% Safety model:
% - On drivers with explicit GetCapacity/SetCapacity support,
%   reserveChannelCapacity() changes the STG memory layout. Call it before
%   starting any stimulation.
% - On drivers without explicit capacity allocation, runtime uploads are
%   sent directly to the idle target channel without pre-verifying reserved
%   capacity.
% - updateChannelData() does not resize memory. It replaces data on the
%   target channel and refuses if the target channel is known active. On
%   devices with explicit capacity, it also refuses if the new pattern is
%   larger than the reserved capacity.
% - Use a one-to-one trigger map so trigger N controls channel N.

s = mcs.getStimulator();

% This also caches the trigger map used by updateChannelData() to avoid
% querying GetTrigger while stimulation is already running.
s.setupTrigger('linearize',true,'repeat_all',0);

if s.usesExplicitCapacityAllocation()
    % Reserve enough memory for any later test patterns on channels 2 and 3.
    % Pick capacity patterns that are at least as long/complex as the largest
    % pattern you plan to upload during the run.
    pt2_capacity = 1000*mcs.getFixedRatePattern(100,'n_pulses',5);
    pt3_capacity = 1000*mcs.getFixedRatePattern(100,'n_pulses',5);
    s.reserveChannelCapacity([2 3],{pt2_capacity,pt3_capacity});
end

% Now upload and start channel 1. On devices with explicit reservation, do
% this after reservation because reservation changes the memory layout.
pt1 = 500*mcs.getFixedRatePattern(10);
s.sentDataToDevice(1,pt1);
s.startStim('triggers',1);

% Minutes later, choose/test a new pattern for channel 2 while channel 1
% continues running. This upload does not call SetCapacity().
pt2_test = 250*mcs.getFixedRatePattern(40,'n_pulses',3);
s.updateChannelData(2,pt2_test);
s.startStim('triggers',2);

% You can repeat this for another idle, pre-reserved channel.
pt3_test = 750*mcs.getFixedRatePattern(20,'n_pulses',4);
s.updateChannelData(3,pt3_test);
s.startStim('triggers',3);

