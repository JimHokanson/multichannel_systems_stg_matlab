function varargout = stimGUI(varargin)
%
%   mcs.stimGUI
%
%   Inputs
%   ------
%   id :
%       Use -1 to prompt for details
%       1 - first connected
%       2 - second connected
%       You can also use:
%       - serial number - string
%       - product - string
%
%   TODO:
%   Allow for more flexible asking - this may already be supported

%{

    %STG4
    mcs.stimGUI('id','STG4004')
    
    %STG5
    mcs.stimGUI('id','STG5')
%}

in.id = 1;
in = sl.in.processVarargin(in,varargin);

if in.id == -1

end

gui = mcs.stg.stim_gui('stimulator_id',in.id);

if nargout
    varargout{1} = gui;
end

end