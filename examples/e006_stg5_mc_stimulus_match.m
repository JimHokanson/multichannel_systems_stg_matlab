% e006_stg5_mc_stimulus_match
%
% Build the same channel-1 current pattern shown in the MC_Stimulus III
% screenshot:
%   -1000 uA for 200 ms, then +1000 uA for 200 ms.
%
% By default this prints the arrays that would be downloaded and does not
% start stimulation. Set do_start to true only when the output is connected
% to the intended test load/oscilloscope.

if ~exist('do_start','var')
    do_start = false;
end
if ~exist('trigger_repeats','var')
    trigger_repeats = 10;
end

channel = 1;
amplitudes_uA = [-1000 1000 0];
durations_ms = [200 200 0];

pt = mcs.stg.pulse_train.fromAmpDurationArrays(...
    amplitudes_uA,durations_ms,...
    'amp_units','uA',...
    'dur_units','ms');

[download_amplitudes_nA,download_durations_us] = pt.getStimValues();
fprintf('Download amplitudes (nA):\n');
disp(download_amplitudes_nA);
fprintf('Download durations (us):\n');
disp(download_durations_us);

if ~do_start
    fprintf('do_start is false; no data was downloaded and SendStart was not called.\n');
else
    h__runStim(channel,pt,trigger_repeats);
end

function h__runStim(channel,pt,trigger_repeats)

    s = mcs.getStimulator();
    cleanup_obj = onCleanup(@()h__stopAndDelete(s,channel));

    s.setupTrigger('linearize',true,'repeat_all',trigger_repeats);
    s.sentDataToDevice(channel,pt,'use_sync',false);
    s.startStim('triggers',channel);

    fprintf('Started channel %d with MC_Stimulus-match pattern and %d trigger repeats. Press a key to stop.\n',...
        channel,trigger_repeats);
    pause;
    s.stopStim('triggers',channel);

end

function h__stopAndDelete(s,channel)

    try
        s.stopStim('triggers',channel);
    catch
    end
    try
        delete(s);
    catch
    end

end
