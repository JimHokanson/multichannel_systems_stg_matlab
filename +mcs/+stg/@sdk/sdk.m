classdef sdk < handle
    %
    %   Class:
    %   mcs.stg.sdk
    %
    %   Source of Stimulator DLL:
    %   http://www.multichannelsystems.com/software/mcsusbnetdll
    %
    %   Stimulator software:
    %   http://www.multichannelsystems.com/software/mc-stimulus-ii
    %
    %   Forum:
    %   http://multichannelsystems.forumieren.de/
    %
    %
    
    properties (Constant)
        DRIVER_VERSION = '3_2_71'
    end
    
    methods (Static)
        function load()
            %
            %   mcs.stg.sdk.load()
            
            persistent obj
            
            if isempty(obj)
               obj = mcs.stg.sdk; 
            end
        end
    end
    
    methods (Access = private)
        function obj = sdk()
            %
            %   obj = mcs.stg.sdk()
            
            %Note, the _v20 in the dll name means using .NET 2.0 framework, 
            %versus the the normal file which uses 4
            
            %TODO: Move into local package
            p = sl.stack.getMyBasePath;
            
            dll = NET.addAssembly(fullfile(p,obj.DRIVER_VERSION,'McsUsbNet.dll'));
            
        end
    end
end

