classdef bitmask < handle
    %
    %   Class:
    %   mcs.utils.bitmask
    %
    %   TODO: Document this class
    
    properties
        value %array
    end
    
    properties (Dependent)
        expanded_value
    end
    
    methods 
        function value = get.expanded_value(obj)
            switch class(obj.value)
                case 'uint32'
                    n_max = 32;
                case 'uint64'
                    n_max = 64;
                otherwise
                    error('Unexpected type')
            end
            value = arrayfun(@(x) find(bitget(x,1:n_max)),obj.value,'un',0);
        end
    end
    
    methods
        function obj = bitmask(value,varargin)
            %
            %   Inputs
            %   ------
            %   value : 
            %
            %   Optional Inputs
            %   ---------------
            %   raw : default false
            %       If true, the input values are interpreted
            %       at being bitmask
            %   type : default 'uint32'
            %
            %   Example
            %   ---------------
            %   %Create an array where the first value
            %   %has:
            %   %#1 - first 4 bits set
            %   %#2 - bit 5
            %   %#3 - bit 6
            %   b = mcs.utils.bitmask({[1,2,3,4],5,6});
            %
            %   %Verification of 0 working
            %   b = mcs.utils.bitmask({1,0,6});
            
            in.raw = false;
            in.type = 'uint32';
            in = sl.in.processVarargin(in,varargin);
            
            if in.raw
                %TODO: We should check and only allow integers ...
                %What about cell vs array input?????
                obj.value = value;
            else
                if ~iscell(value)
                    error('Non-raw values must be input as a cell array')
                end

                %Determine fh
                %----------------------
                switch in.type
                    case 'uint32'
                        fh = @uint32;
                    case 'uint64'
                        fh = @uint64;
                        error('Not yet implemented')
                    otherwise
                        error('Option not recognized')
                end

                %The actual conversion
                %--------------------------
                %   TODO: The conversion approach might fail with uint64
                %   since we are using double for the calculation
                obj.value = cellfun(@(x) fh(sum(floor(2.^(x - 1)))),value);
            end
        end
        function enableBits(obj)
            
        end
        function disableBits(obj)
        end
    end
    
end

