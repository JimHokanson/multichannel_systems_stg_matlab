function handleError(error_id,error_message,error_code)
%
%   mcs_stg.sdk.handleError(error_id,error_message,error_code)

    if error_code ~= 0
       temp = Mcs.Usb.CUsbExceptionNet(error_code); 
       fprintf(2,'--------------------------------------------\n');
       fprintf(2,'\nError from MCS: %s\n\n',char(temp.Message));
       fprintf(2,'--------------------------------------------\n');
       error(error_id,error_message)
    end

end

%TODO: Provide translations of error codes
%#? - Device is locked - probably because we've already connected to it ...