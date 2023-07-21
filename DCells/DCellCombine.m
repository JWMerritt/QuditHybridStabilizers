function Out = DCellCombine(In1,In2)
%DCELLCOMBINE  Combine two DCells into one.
%   OUT = DCELLCOMBINE(A, B) combines two DCells A and B into one DCell.
%
%   This function combines data for entries with 
%   the same independent variables.
%   This function does not order the entries.
%
%   See DCELLNORMALIZE, DCELLORDER


Out = In1;

for in_idx=1:numel(In2)
    % Check if an entry in Out shares the same dependent variable values as this entry in In2.
    % If not, make an additional entry in Out.
    InEntry = In2{in_idx};
    NewEntry = true;
    for out_idx=1:numel(Out)
        OutEntry = Out{out_idx};
        if (InEntry.SystemSize==OutEntry.SystemSize)...
                &&(InEntry.MeasurementProbability==OutEntry.MeasurementProbability)...
                &&(InEntry.InteractingProbability==OutEntry.InteractingProbability)...
                &&(InEntry.TotalTimeSteps==OutEntry.TotalTimeSteps)
            Out{out_idx}.LengthDistribution = cat(1,OutEntry.LengthDistribution,InEntry.LengthDistribution);
            Out{out_idx}.SubsystemEntropy = cat(1,OutEntry.SubsystemEntropy,InEntry.SubsystemEntropy);
            Out{out_idx}.PurificationEntropy = cat(1,OutEntry.PurificationEntropy,InEntry.PurificationEntropy);
            Out{out_idx}.Realizations = cat(1,OutEntry.Realizations,InEntry.Realizations);
            NewEntry = false;
            break
        end

    end

    if NewEntry
        Out = cat(2,Out,InEntry);
    end
    
end

end