function [SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,TotalTimeSteps,Out,Realizations,STD] = DCellPullData(Dcell,ARG)
%DCELLPULLDATA  Collect the data from a DCell and convert it into arrays
%  for plotting / manipulation / etc.
%
%   [SystemSizeValues,MeasurementProbabilityValues,...
%     InteractingProbabilityValues,TotalTimeSteps,Out,...
%     Realizations,STD] = DCELLPULLDATA(In,ARG) extracts and averages the
%   ARG data (ARG = 'LengthDistribution', 'SubsystemEntropy', or 'PurificationEntropy'),
%   then organizes the results into double arrays.
%   Out is a cell array of ARG values.
%   STD is a double array of standard deviations in the values at each point.

if nargin<2
    ErSrct = struct('message','Argument missing from input.','identifier','DCellPullData:MissingArgument');
    error(ErSrct)
end

if ~iscell(Dcell)
    if isstruct(Dcell)
        ErSrct = struct('Input is a struct. Remember to convert structs to DCells.','identifier','DCellPullData:InputIsStruct');
        error(ErSrct)
    else
        ErSrct = struct('Input must be a DCell.','identifier','DCellPullData:InputIsNotCell');
        error(ErSrct)
    end
end


SystemSizeValues=[];
MeasurementProbabilityValues=[];
InteractingProbabilityValues=[];
TotalTimeSteps=[];
Out={};
STD=[];
Realizations=[];

for entry_idx=1:numel(Dcell)
    SystemSizeValues(entry_idx) = Dcell{entry_idx}.SystemSize;
    MeasurementProbabilityValues(entry_idx) = Dcell{entry_idx}.MeasurementProbability;
    InteractingProbabilityValues(entry_idx) = Dcell{entry_idx}.InteractingProbability;
    TotalTimeSteps(entry_idx) = Dcell{entry_idx}.TotalTimeSteps;
    Current_ARGData_cell = getfield(Dcell{entry_idx},ARG);   % This should give us the cell array we're looking for...
    %   It will be a single value in the case of PurificationEntropy, and a column matrix for LengthDistribution / SubsystemEntropy

    Current_ArgData_numel = numel(Current_ARGData_cell);
    Realizations(entry_idx) = Current_ArgData_numel;
        % Notice that we don't check the value of the Realizations{i} entries,
        % we just expect them all to be 1. If not, then the standard deviation
        % calculation will be incorrect.
    ArgData_Cumulative = Current_ARGData_cell{1};

    for ArgData_idx=2:Current_ArgData_numel
        ArgData_Cumulative = ArgData_Cumulative + Current_ARGData_cell{ArgData_idx};
        %   We force all Realizations{i}=1 so that we can do the variance calculation.
    end

    FinalArgOut = ArgData_Cumulative/Current_ArgData_numel;
    Out{entry_idx} = FinalArgOut;

    Variance_Cumulative = (FinalArgOut - Current_ARGData_cell{1}).^2;
    for jj=2:Current_ArgData_numel
        Variance_Cumulative = Variance_Cumulative + (FinalArgOut - Current_ARGData_cell{jj}).^2;
    end
    STD{entry_idx} = sqrt(Variance_Cumulative/(Current_ArgData_numel-1));

end

end

%03/Feb/21 - Added catch conditions for when I accidentally just put the
%   struct into the function. Also changed the name from Scell_pull_data to
%   ScellPullData
%07/Feb/21 - Added measurement standard deviation (sig) to list of
%   calculations.