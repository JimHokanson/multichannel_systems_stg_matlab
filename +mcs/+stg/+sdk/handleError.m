function handleError(error_id,error_message,error_code)
%
%   mcs_stg.sdk.handleError(error_id,error_message,error_code)

    if error_code ~= 0
       temp = Mcs.Usb.CUsbExceptionNet(error_code);
       mcs_message = char(temp.Message);
       fprintf(2,'--------------------------------------------\n');
       fprintf(2,'\nError from MCS: %s\n\n',mcs_message);
       fprintf(2,'--------------------------------------------\n');

       if contains(lower(mcs_message),'device is locked')
           error_message = sprintf([...
               '%s. MCS returned: %s\n\n',...
               'The stimulator is already open somewhere. Close any open ',...
               'stim GUI window, or run mcs.closeStimGUI(), then try ',...
               'clear classes. Also close MC_Stimulus or any other process ',...
               'using the device. If the lock remains, restart MATLAB or ',...
               'power cycle the stimulator.'],error_message,mcs_message);
       else
           error_message = sprintf('%s. MCS returned: %s',error_message,...
               mcs_message);
       end
       error(error_id,'%s',error_message)
    end

end
