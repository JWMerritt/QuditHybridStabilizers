function Out = dcellConvert(In)
%DCELLCONVERT  Convert a struct of data into a DCell cell array.
%
%   A DCell is the term for a cell array, where each entry is a struct that
%   contains the data corresponding a particular set of independent values.
%
%   OUT = DCELLCONVERT(IN) converts the struct IN into an array of cells 
%   (a DCell array), where each entry holds the data corresponding to one 
%   value of the independent variables (SystemSize,InteractingProbability,
%   MeasurementProbability,TotalTimeSteps).
%
%   This function does not combine data for entries with 
%   the same independent variables.
%   This function does not order the entries.
%
%   The input structure is expected to be a struct of any size,
%   where each entry has the following fields and data types:
%       SystemSize - 1x1 double
%       MeasurementProbability - 1x1 double
%       InteractingProbability - 1x1 double
%       TotalTimeSteps - 1x1 double
%       LengthDistribution - Nx1 cell of Mx1 doubles
%       SubsystemEntropy - Nx1 cell of Mx1 doubles
%       PurificationEntropy Nx1 cell  of 1x1 doubles
%       Realizations - Nx1 cell of 1x1 doubles

EmptyStruct = struct('SystemSize',[],'MeasurementProbability',[],...
    'InteractingProbability',[],'TotalTimeSteps',[],...
    'LengthDistribution',cell(1),'SubsystemEntropy',cell(1),...
    'PurificationEntropy',cell(1),'Realizations',cell(1));
Out = {};


for in_idx=1:numel(In)
    skip_entry = false;
        % First, we check if In(in_idx) actually has any data

    if numel(In(in_idx).SystemSize)==0
        skip_entry = true;
    end

    if ~isequal(class(In(in_idx).SubsystemEntropy),'cell')  
        % This is here because sometimes the entry will be an array of 
        % doubles instead of a cell array
        skip_entry = true;
    elseif numel(In(in_idx).SubsystemEntropy{1})==0
        skip_entry = true;
    end

    if isfield(In,'LengthDistribution')
        if ~isequal(class(In(in_idx).LengthDistribution),'cell')
            skip_entry = true;
        elseif numel(In(in_idx).LengthDistribution{1})==0
            skip_entry = true;
        end
    end

    if ~skip_entry        % Add another entry
        Out{end+1} = EmptyStruct;
        Out{end}.SystemSize = In(in_idx).SystemSize;
        Out{end}.MeasurementProbability = In(in_idx).MeasurementProbability;
        Out{end}.InteractingProbability = In(in_idx).InteractingProbability;
        Out{end}.SubsystemEntropy = In(in_idx).SubsystemEntropy;
        if isfield(In,'TotalTimeSteps')
            Out{end}.TotalTimeSteps = In(in_idx).TotalTimeSteps;
        else
            Out{end}.TotalTimeSteps = [];
        end
        if isfield(In,'LengthDistribution')
            Out{end}.LengthDistribution = In(in_idx).LengthDistribution;
        else
            Out{end}.LengthDistribution = {};
        end
        if isfield(In,'PurificationEntropy')
            Out{end}.PurificationEntropy = In(in_idx).PurificationEntropy;
        else
            Out{end}.PurificationEntropy = {};
        end
        if isfield(In,'Realizations')
            Out{end}.Realizations = In(in_idx).Realizations;
        else
            Out{end}.Realizations = {};
        end
    end
end

end