function varargout = stimGUI()
%
%   mcs.stimGUI
%

gui = mcs.stg.stim_gui();

if nargout
    varargout{1} = gui;
end

end