function n_closed = closeStimGUI()
%closeStimGUI Close open MCS stim GUI windows and release the stimulator.
%
%   mcs.closeStimGUI()
%
%   This is intentionally explicit because closing the GUI also stops any
%   stimulation that is controlled by that GUI.

figures = findall(groot,'Type','figure');
closed_count = 0;

for i = 1:numel(figures)
    fig = figures(i);
    if ~isStimGuiFigure(fig)
        continue
    end

    closed_count = closed_count + 1;
    try
        user_data = fig.UserData;
        if isa(user_data,'mcs.stg.stim_gui') && isvalid(user_data)
            delete(user_data);
        else
            delete(fig);
        end
    catch
        try
            delete(fig);
        catch
        end
    end
end

drawnow

if nargout
    n_closed = closed_count;
else
    fprintf('Closed %d MCS stim GUI window(s).\n',closed_count);
end

end

function tf = isStimGuiFigure(fig)

tf = false;

try
    if strcmp(fig.Tag,'mcs_stim_gui')
        tf = true;
        return
    end
catch
end

try
    if strcmp(fig.Name,'MCS Multi-Channel Stimulus Control')
        tf = true;
        return
    end
catch
end

try
    if strcmp(fig.Name,'MATLAB App') && hasText(fig,'Start Stim') && ...
            hasText(fig,'Stop Stim')
        tf = true;
    end
catch
end

end

function tf = hasText(fig,target_text)

tf = false;
items = findall(fig,'-property','Text');
for i = 1:numel(items)
    try
        if strcmp(char(items(i).Text),target_text)
            tf = true;
            return
        end
    catch
    end
end

end
