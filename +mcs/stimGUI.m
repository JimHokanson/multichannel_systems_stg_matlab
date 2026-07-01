function varargout = stimGUI(varargin)
%
%   mcs.stimGUI
%

gui = mcs.stg.stim_gui(varargin{:});

if nargout
    varargout{1} = gui;
end

end
