classdef rounding_options < matlab.mixin.Copyable
    %
    %   Class:
    %   mcs.stg.rounding_options
    
    properties
        round_rate = true %By default we'll round a user's specified rate
        %to a realizable rate by the hardware. This is currently done
        %on the timestep, not on the target times.
        %   i.e. if timestep must be a multiple of 20 (us) and you ask for a
        %   rate that gives a timestep of 35 (us), then you'll get:
        %       0:round_to_20(35):200 <= as an example (35 goes to 40)
        %       => [0 40 80 120 160 200]
        %   NOT THIS:
        %       round_to_20(0:35:200) => [0 40 80 100 140 180]
        %           %Note the 100 comes from the 105 (3*35)
        %           %140 =>
        %
        %   This behavior may eventually change ...
        
        
        round_on_durations = true
        on_durations_max_pct = 10
        round_off_durations = true
        off_durations_max_pct = 10
    end
    
    methods
        function new_dt = getDT(obj,orig_dt,min_dt)
            if obj.round_rate
                new_dt = h__roundTo(orig_dt,min_dt);
            else
                new_dt = orig_dt;
            end
        end
        %         function new_rate = getRate(obj,old_rate,dt)
        %             if obj.round_rate
        %                 old_dt   = 1/old_rate;
        %                 new_rate = 1./h__roundTo(old_dt,dt);
        %             else
        %                 new_rate = old_rate;
        %             end
        %         end
        function new_durations = getRoundedDurations(obj,durations,amplitudes,dt)
            
            ERR_ID = 'MCS:STG:ROUNDING_OPTIONS:GET_ROUNDED_DURATIONS';
            
            new_durations = durations;
            if obj.round_on_durations
                on_mask = amplitudes ~= 0;
                on_durations = durations(on_mask);
                new_on = h__roundTo(on_durations,dt);
                max_pct_error = 100*max(abs(new_on-on_durations)/dt);
                
                if max_pct_error > obj.on_durations_max_pct
                    error(ERR_ID,'stimulus specified deviated from min_dt by too much, %0.1f%%',max_pct_error)
                end
                new_durations(on_mask) = new_on;
            end
            
            if obj.round_off_durations
                off_mask = amplitudes ~= 0;
                off_durations = durations(off_mask);
                new_off = h__roundTo(off_durations,dt);
                max_pct_error = 100*max(abs(new_off-off_durations)/dt);
                
                if max_pct_error > obj.off_durations_max_pct
                    error(ERR_ID,'stimulus specified deviated from min_dt by too much, %0.1f%%',max_pct_error)
                end
                new_durations(off_mask) = new_off;
            end
            
            
        end
    end
end

function new_durations = h__roundTo(durations,target_dt)
new_durations = round(durations/target_dt)*target_dt;
end

% %     methods (Static)
% % %         function obj = fromStruct(s)
% % %             %
% % %             %   obj = mcs.stg.rounding_options.fromStruct(s);
% % %
% % %             obj = mcs.stg.rounding_options();
% % %             fn = fieldnames(s);
% % %             for i = 1:length(fn)
% % %                 cur_name = fn{i};
% % %                 obj.(cur_name) = s.(cur_name);
% % %             end
% % %         end
% % %         function s = getDefaultStruct()
% % %             %
% % %             %   s = mcs.stg.rounding_options.getDefaultStruct()
% % %             temp = mcs.stg.rounding_options;
% % %             w = warning('off','MATLAB:structOnObject');
% % %             s = struct(temp);
% % %             warning(w);
% % %         end
% %     end


