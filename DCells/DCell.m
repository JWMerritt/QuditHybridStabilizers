classdef DCell
    properties
        Cell
    end
    methods

        function obj = DCell(input_data)
            if nargin==0
                input_data = {};
            end
            %input_data
            obj.Cell = obj.Struct2DCell(input_data);
            obj.Attributes = obj.index();
        end

        function Out = Struct2DCell(obj,struct_in)
            TrivStruct = struct('SystemSize',[],'MeasurementProbability',[],'InteractingProbability',[],'TotalTimeSteps',[],'LengthDistribution',cell(1),'SubsystemEntropy',cell(1),'PurificationEntropy',cell(1),'Realizations',cell(1));
            Out = {};
            skip = false;
            
            for ii=1:numel(struct_in)
                skip = false;
                    %The following if statements check if struct_in(ii) has any data, and skips the entry if it is empty.
                if numel(struct_in(ii).SystemSize)==0
                    skip = true;
                end
                if ~isequal(class(struct_in(ii).SubsystemEntropy),'cell')  % This is here in case SubsystemEntropy=[] instead of SubsystemEntropy={[]}
                    skip = true;
                elseif numel(struct_in(ii).SubsystemEntropy{1})==0
                    skip = true;
                end
                if isfield(struct_in,'LengthDistribution')
                    if ~isequal(class(struct_in(ii).LengthDistribution),'cell')
                        skip = true;
                    elseif numel(struct_in(ii).LengthDistribution{1})==0
                        skip = true;
                    end
                end
    
                if ~skip        %just place entries into the cell, no duplicate-checking
                    Out{end+1} = TrivStruct;
                    Out{end}.SystemSize = struct_in(ii).SystemSize;
                    Out{end}.MeasurementProbability = struct_in(ii).MeasurementProbability;
                    Out{end}.InteractingProbability = struct_in(ii).InteractingProbability;
                    Out{end}.SubsystemEntropy = struct_in(ii).SubsystemEntropy;
                    if isfield(struct_in,'TotalTimeSteps')
                        Out{end}.TotalTimeSteps = struct_in(ii).TotalTimeSteps;
                    else
                        Out{end}.TotalTimeSteps = [];
                    end
                    if isfield(struct_in,'LengthDistribution')
                        Out{end}.LengthDistribution = struct_in(ii).LengthDistribution;
                    else
                        Out{end}.LengthDistribution = {};
                    end
                    if isfield(struct_in,'PurificationEntropy')
                        Out{end}.PurificationEntropy = struct_in(ii).PurificationEntropy;
                    else
                        Out{end}.PurificationEntropy = {};
                    end
                    if isfield(struct_in,'Realizations')
                        Out{end}.Realizations = struct_in(ii).Realizations;
                    else
                        Out{end}.Realizations = {};
                    end
                end
            end
        end

        function Out = Append(obj,DC2)
            
        end

    end
end