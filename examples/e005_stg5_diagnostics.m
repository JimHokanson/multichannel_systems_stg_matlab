% e005_stg5_diagnostics
%
% Connect to the first stimulator, print driver/device output-limit
% information, and verify the linear trigger setup used by the GUI.
%
% This diagnostic does not start stimulation.

s = mcs.getStimulator();
cleanup_obj = onCleanup(@()delete(s));

fprintf('MCS MATLAB wrapper driver folder: %s\n',s.driver_version);
fprintf('Device product: %s\n',s.device_product);
fprintf('Device name: %s\n',s.device_name);
fprintf('Serial number: %s\n',s.serial_number);
fprintf('Analog channels: %d\n',s.n_analog_channels);
fprintf('Sync channels: %d\n',s.n_syncout_channels);
fprintf('Trigger inputs: %d\n',s.n_trigger_inputs);
fprintf('\n');

info = s.getOutputResolutionInfo();
for i = 1:length(info)
    fprintf('Channel %d voltage range %.0f mV, resolution %.3g mV\n',...
        info(i).channel,...
        info(i).voltage_range_uV/1000,...
        info(i).voltage_resolution_uV/1000);
    fprintf('Channel %d current range %.0f uA, resolution %.3g uA\n',...
        info(i).channel,...
        info(i).current_range_nA/1000,...
        info(i).current_resolution_nA/1000);
end
fprintf('\n');

% This is the same trigger convention used by the GUI:
% trigger 1 controls channel/sync 1, trigger 2 controls channel/sync 2,
% and so on. Repeats of 0 mean repeat forever until stopped.
s.setupTrigger('linearize',true,'repeat_all',0);
tr = s.trigger_settings;
disp(tr);

fprintf('No stimulation was started. For channel 1, startStim(''triggers'',1) maps to SendStart(1).\n');
