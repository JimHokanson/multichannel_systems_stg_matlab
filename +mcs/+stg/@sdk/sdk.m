classdef sdk < handle
    %
    %   Class:
    %   mcs.stg.sdk
    %
    %   Source of Stimulator DLL & Documentation:
    %   http://www.multichannelsystems.com/software/mcsusbnetdll
    %
    %   Stimulator Software GUI from MCS:
    %   http://www.multichannelsystems.com/software/mc-stimulus-ii
    %
    %   Forum:
    %   http://multichannelsystems.forumieren.de
    %
    %   Usage
    %   -----
    %   Generally this class is not called directly.
    %
    %   See Also
    %   --------
    %   mcs.stg.getDevice
    %
    
    %{
        temp = mcs.stg.sdk.load();
    %}
    
    properties (Constant)
        DRIVER_VERSION = '3_2_71'
    end
    
    properties
        dll
    end
    
    methods (Static)
        function varargout = load()
            %
            %   mcs.stg.sdk.load()
            
            persistent obj
            
            if isempty(obj)
               obj = mcs.stg.sdk; 
            end
            
            if nargout
               varargout{1} = obj; 
            end
        end
    end
    
    methods (Access = private)
        function obj = sdk()
            %
            %   obj = mcs.stg.sdk()
            %
            %   Run via: 
            %   mcs.stg.sdk.load()
            
            %Note, the _v20 in the dll name means using .NET 2.0 framework, 
            %versus the the normal file which uses 4
            
            %TODO: Move into local package
            p = mcs.sl.stack.getMyBasePath;
            
            obj.dll = NET.addAssembly(fullfile(p,obj.DRIVER_VERSION,'McsUsbNet.dll'));
            
        end
    end
end

