classdef device_chooser < handle
    %
    %   Class:
    %   mcs.utils.device_chooser
    %
    %   Use this to choose a device
    
    %{
        %Usage
        %--------------
        dc = mcs.utils.device_chooser;
        dc.wait();
        selected_id = dc.active_id;
    %}
    
    properties
        h_fig
        active_id
        devices
        %cellstr
        device_text
        h_close
        h_selection
        h_text
    end

    methods
        function obj = device_chooser()
            obj.active_id = 1;
            obj.h_fig = uifigure('Position',[100 100 400 400]);
            obj.devices = mcs.getDevicesInfo();
            n_devices = length(obj.devices);
            obj.device_text = cell(1,n_devices);
            items = cell(1,n_devices);
            for i = 1:n_devices
                items{i} = sprintf('%d',i);
                obj.device_text{i} = obj.devices(i).getDispText();
            end
            obj.h_close = uibutton(obj.h_fig,'Text','Close','Position',[250 350 100 40]);
            obj.h_close.ButtonPushedFcn = @(~,~)obj.closeGUI();
            obj.h_selection = uidropdown(obj.h_fig,'Items',items,...
                'ItemsData',1:n_devices,'Position',[50 350 50 20]);
            obj.h_selection.ValueChangedFcn = @(~,~)obj.selectionChanged();
            obj.h_text = uitextarea(obj.h_fig,'Value',obj.device_text{1},...
                'Position',[0 0 400 300],'FontName','Monospaced');
        end
        function wait(obj)
            uiwait(obj.h_fig)
        end
        function selectionChanged(obj)
            obj.active_id = obj.h_selection.Value;
            obj.h_text.Value = obj.device_text{obj.active_id};
        end
        function closeGUI(obj)
            close(obj.h_fig);
        end
    end
end