classdef RData < handle
    %HData (Realization Data) an organized way of manipulating the Job data from
    %QuditHybridStabilizers.
    %   
    %   R = RDATA() creates an empty DCell object.
    %
    %   R = RDATA(JobDataStruct) creates an RData object, given the `Out` struct
    %   of a DATA file. The data is contained in a cell array, R.data. Each
    %   entry of R.data is a struct which corresponds to one combination of
    %   parameters, and contains all of the Realizations' results for that
    %   combination of parameters.
    %
    %   R.append(K) appends the contents of another RData object, K. This combines
    %   results for Realizations with the same values for its parameters. This
    %   can also be done using R = R + K.
    %
    %   [N,M,I,T,Out,Reals,Sig] = R.pull(ARG) pulls the data from R.data into
    %   arrays which can be plotted. ARG = 'SubsystemEntropy',
    %   'PurificationEntropy', or 'LengthDistribution' is the result that is to
    %   be extracted. For each combination of parameters, i:
    %       N(i) = the system sizes of each result
    %       M(i) = the measurement probability
    %       I(i) = the interacting probability
    %       T(i) = the total number of time steps
    %       Out{i} = the average results. (Out is a cell array.)
    %       Reals(i) = the total number of realizations
    %       Sig{i} = the standard deviation. (Sig is a cell array.) Sig{i}(L)
    %           is the standard deviation for Out{i}(L).
    %
    %   See also RDATAFROMLIST
    
    properties
        data
    end
    
    methods
        function obj = RData(JobDataStruct)
           if nargin==0
               obj.data = {};
           else
               obj.data = RDataConvert(JobDataStruct);
               obj.order();
           end
        end
       
        function obj = order(obj)
            obj.data = RDataOrder(obj.data);
        end
        
        function obj = append(obj, Input)
            if isstruct(Input)
                Input = RData(Input);
            end
            obj.data = RDataCombineData(obj.data, Input.data);
            obj.order();
        end

        function Out = plus(obj, Addend)
            newdata = RDataCombineData(obj.data, Addend.data);
            Out = RData();
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
                StandardDeviation] = RDataPullData(obj.data,ARG);
        end

    end

end

