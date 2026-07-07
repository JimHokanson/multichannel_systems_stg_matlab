%e004_multichannel_stim_gui
%
% Launch the multi-channel stimulation GUI.
%
% Each row controls one channel independently. Press Start on an idle row
% to upload that row's parameters with updateChannelData(channel, pattern)
% and start only that channel's trigger. While a row is running its
% parameter controls are disabled; press Stop on that row before changing
% or uploading new parameters for the same channel. Other running rows keep
% stimulating while an idle row is edited or started.
%
% If a previous GUI run left the device locked, close the old GUI window or
% run:
%   mcs.closeStimGUI();
%   clear classes;

gui = mcs.stimGUI();
