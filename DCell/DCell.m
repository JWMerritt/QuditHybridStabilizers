classdef DCell < handle
    %DCELL An organized way of manipulating the Job data from
    %QuditHybridStabilizers
    %   
    
    properties
        data
    end
    
    methods
        function obj = DCell(JobDataStruct)
           if nargin==0
               obj.data = {};
           else
               obj.data = dcellConvert(JobDataStruct);
               obj.order()
           end
        end
       
        function obj = order(obj)
            obj.data = dcellOrder(obj.data);
        end
        
        function obj = append(obj, Input)
            if isstruct(Input)
                Input = DCell(Input);
            end
            obj.data = dcellCombineData(obj.data, Input.data);
            obj.order();
        end

        function Out = plus(obj, Addend)
            newdata = dcellCombineData(obj.data, Addend.data);
            Out = DCell();
            Out.data = newdata;
            Out.order()
        end

        function [SystemSizeValues,...
                MeasurementProbabilityValues,...
                InteractingProbabilityValues,...
                TotalTimeSteps,...
                ARG_Out,...
                Realizations,...
                StandardDeviation]...
                = pull(obj,ARG)

            [SystemSizeValues,...
                MeasurementProbabilityValues,...
                InteractingProbabilityValues,...
                TotalTimeSteps,...
                ARG_Out,...
                Realizations,...
                StandardDeviation] = dcellPullData(obj.data,ARG);
        end

    end

end

