function [SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,TotalTimeSteps,Out,Realizations,sig,roughLimits] = ScellPullData(Scell,arg,roughLimit)
% [SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,TotalTimeSteps,Out,Realizations,sig,roughLimits] = ScellPullData(Scell,arg,roughLimit)
% Pulls $arg data from a Scell cell
%   sig is standard deviation; roughLimits is the number of times data was thrown due to being over the roughLimit

if nargin==1
    if isequal(Scell,'info')
        fprintf('\n -- [SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,TotalTimeSteps,Out,Realizations,sig,roughLimits] = ScellPullData(Scell,arg,roughLimit)\n')
        return
    end
end
if nargin<3
	roughLimit = inf;
end
if nargin<2
    arg = 'LengthDistribution';
end



if ~iscell(Scell)
    if isstruct(Scell)
        fprintf('ERROR: Input is struct. Remember to Scellerize inputs.\n')
        return
    else
        fprintf('ERROR: Expecting input to be cell array.\n')
    end
end

SystemSizeValues=[];
MeasurementProbabilityValues=[];
InteractingProbabilityValues=[];
TotalTimeSteps=[];
Out={};
sig=[];
Realizations=[];
roughLimits = [];



for IterativeScellEntryIndex=1:numel(Scell)

    ArgData_CurrentScellEntry = getfield(Scell{IterativeScellEntryIndex},arg);   %should give us the cell array we're looking for
    %   This will be a single value in the case of PurificationEntropy, and a column matrix for LengthDistribution / SubsystemEntropy

    SystemSizeValues(IterativeScellEntryIndex)=Scell{IterativeScellEntryIndex}.SystemSize;
    MeasurementProbabilityValues(IterativeScellEntryIndex)=Scell{IterativeScellEntryIndex}.MeasurementProbability;
    InteractingProbabilityValues(IterativeScellEntryIndex)=Scell{IterativeScellEntryIndex}.InteractingProbability;
    TotalTimeSteps(IterativeScellEntryIndex)=Scell{IterativeScellEntryIndex}.TotalTimeSteps;


    %{
    holdReals = 0;
    holdArg = 0;
    entries = numel(Current); 	%note: replace this loop with cell2mat() & sum() in the future...

    for jj=1:entries
        holdArg(jj) = Current{jj};
        if numel(Scell{ii}.Realizations)~=0
            holdReals(jj) = Scell{ii}.Realizations{jj};
        end
    end

        % RoughLimit code: keep only the values below roughLimit
    keptOnes = holdArg<roughLimit;
    finalArg = holdArg(keptOnes);
    finalReals = holdReals(keptOnes);
    roughLimits(ii) = entries - sum(keptOnes);
    %}

    Number_Data_in_Current_Arg = numel(ArgData_CurrentScellEntry);
    Realizations(IterativeScellEntryIndex) = Number_Data_in_Current_Arg;
    ArgOutCurrent = ArgData_CurrentScellEntry{1};
    %Realizations_Counter = Scell{IterativeScellEntryIndex}.Realizations{1};

    for IterativeArgEntryIndex=2:Number_Data_in_Current_Arg
        ArgOutCurrent = ArgOutCurrent + ArgData_CurrentScellEntry{IterativeArgEntryIndex};
        %   We force all Realizations=1 so that we can do the variance calculation.
    end

    FinalArgOut = ArgOutCurrent/Number_Data_in_Current_Arg;
    Out{IterativeScellEntryIndex} = FinalArgOut;

    %{
    if numel(Scell{IterativeScellEntryIndex}.Realizations)~=0
        Realizations(IterativeScellEntryIndex) = sum(finalReals);
    end
    holdVar = [];
    %}
    
    VarianceBuffer = (FinalArgOut - ArgData_CurrentScellEntry{1}).^2;
    for jj=2:Number_Data_in_Current_Arg
        VarianceBuffer = VarianceBuffer + (FinalArgOut - ArgData_CurrentScellEntry{jj}).^2;
    end
    sig{IterativeScellEntryIndex} = sqrt(VarianceBuffer/(Number_Data_in_Current_Arg-1));


end

end

%03/Feb/21 - Added catch conditions for when I accidentally just put the
%   struct into the function. Also changed the name from Scell_pull_data to
%   ScellPullData
%07/Feb/21 - Added measurement standard deviation (sig) to list of
%   calculations.