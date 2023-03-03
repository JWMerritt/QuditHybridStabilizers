function [SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,TotalTimeSteps,Out,Realizations,sig,roughLimits] = ScellPullData(Scell,arg,roughLimit)
%sig is std deviation; roughLimits is the number of times data was thrown due to being over the roughLimit

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

    CurrentArgEntries = getfield(Scell{IterativeScellEntryIndex},arg);   %should give us the cell array we're looking for
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

    Number_Args_Current = numel(CurrentArgEntries);
    Realizations(IterativeScellEntryIndex) = Number_Args_Current;
    ArgOutCurrent = CurrentArgEntries{1};
    %Realizations_Counter = Scell{IterativeScellEntryIndex}.Realizations{1};

    for IterativeArgEntryIndex=2:Number_Args_Current
        ArgOutCurrent = ArgOutCurrent + CurrentArgEntries{IterativeArgEntryIndex};
        %   We force all Realizations=1 so that we can do the variance calculation.
    end

    FinalArgOut = ArgOutCurrent/Number_Args_Current;
    Out{IterativeScellEntryIndex} = FinalArgOut;

    %{
    if numel(Scell{IterativeScellEntryIndex}.Realizations)~=0
        Realizations(IterativeScellEntryIndex) = sum(finalReals);
    end
    holdVar = [];
    %}
    
    VarianceBuffer = (FinalArgOut - CurrentArgEntries{1});
    for jj=2:Number_Args_Current
        VarianceBuffer = VarianceBuffer + (FinalArgOut - CurrentArgEntries{jj}).^2;
    end
    sig = sqrt(VarianceBuffer/(Number_Args_Current-1));


end

end

%03/Feb/21 - Added catch conditions for when I accidentally just put the
%   struct into the function. Also changed the name from Scell_pull_data to
%   ScellPullData
%07/Feb/21 - Added measurement standard deviation (sig) to list of
%   calculations.