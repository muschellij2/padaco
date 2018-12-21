classdef PABase < handle
    
    properties(SetAccess=protected)
        handles;
        statusHandle;
    end
    methods
        function clearStatus(obj)
            obj.setStatus('');
        end
        function setStatus(obj, fmtStr, varargin)
           str = sprintf(fmtStr, varargin{:});
           if(~isempty(obj.statusHandle) && ishandle(obj.statusHandle))
               set(obj.statusHandle,'string',str);
           else
               if(~isempty(fmtStr))
                   fprintf(1,['%s',newline],str);
               end
           end
        end
        function didSet = setStatusHandle(obj, statusH)
            didSet = false;
            if(ishandle(statusH))
                obj.statusHandle = statusH;
                didSet = true;
            end
        end

    end
end
    
    
    
   