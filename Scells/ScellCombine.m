function Out = ScellCombine(In1,In2)
%   Expects Normalized Scells

%EntryStruct = struct('N',[],'p',[],'q',[],'t',[],'S',cell(1),'ns',cell(1),'reals',cell(1));
EntryStruct = struct('SystemSize',[],'MeasurementProbability',[],'InteractingProbability',[],'TotalTimeSteps',[],'LengthDistribution',cell(1),'SubsystemEntropy',cell(1),'PurificationEntropy',cell(1),'Realizations',cell(1));
Out = In1;

for InIndex=1:numel(In2)

    InNow = In2{InIndex};
    for OutIndex=1:numel(Out)
        OutNow = Out{OutIndex};
        if (InNow.SystemSize==OutNow.SystemSize)&&(InNow.MeasurementProbability==OutNow.MeasurementProbability)&&(InNow.InteractingProbability==OutNow.InteractingProbability)&&(InNow.TotalTimeSteps==OutNow.TotalTimeSteps)
            % combine entries
            Out{OutIndex}.LengthDistribution = cat(2,OutNow.LengthDistribution,InNow.LengthDistribution);
            Out{OutIndex}.SubsystemEntropy = cat(2,OutNow.SubsystemEntropy,InNow.SubsystemEntropy);
            Out{OutIndex}.PurificationEntropy = cat(2,OutNow.PurificationEntropy,InNow.PurificationEntropy);
            Out{OutIndex}.Realizations = cat(2,OutNow.Realizations,InNow.Realizations);
            break
        end
    end
    
end



%{
for i=2:numel(In1)                                          %Now we check for duplicates in In1. Go through all the entries in In1...
    newEntry = false;
    if ~(numel(In1{i}.S)==0)||~(numel(In1{i}.ns)==0)                            %...if there's any content in this entry...     (this relies on proper Scellerization)
        for j=1:numel(Out)                                                      %...then check all of the entries we have so far...
            if (In1{i}.N==Out{j}.N)&&(In1{i}.p==Out{j}.p)&&(In1{i}.q==Out{j}.q) %...and check to see if there's a (p,N,q) match...
                if numel(In1{i}.t)==0                                           %...then see if there's a t value. If not, we have a match.
                    Out{j}.S = cat(1,Out{j}.S,In1{i}.S);
                    Out{j}.ns = cat(1,Out{j}.ns,In1{i}.ns);
                    Out{j}.reals = cat(1,Out{j}.reals,In1{i}.reals);
                    newEntry = true;
                    break
                elseif In1{i}.t==Out{j}.t                                       %If there is a t value, make sure they match, too. If not, keep searching.
                    Out{j}.S = cat(1,Out{j}.S,In1{i}.S);
                    Out{j}.ns = cat(1,Out{j}.ns,In1{i}.ns);
                    Out{j}.reals = cat(1,Out{j}.reals,In1{i}.reals);
                    newEntry = true;
                    break
                end
            end
        end
        if ~newEntry        %If there are no matches, make a new entry.
            Out = cat(2,Out,EntryStruct);
            Os = numel(Out);
            Out{Os}.N = In1{i}.N;
            Out{Os}.p = In1{i}.p;
            Out{Os}.q = In1{i}.q;
            Out{Os}.t = In1{i}.t;
            Out{Os}.S = In1{i}.S;
            Out{Os}.ns = In1{i}.ns;
            Out{Os}.reals = In1{i}.reals;
        end
    end
end

for i=1:numel(In2)
    newEntry = false;
    if ~(numel(In2{i}.S)==0)||~(numel(In2{i}.ns)==0)                            %...if there's any content in this entry...
        for j=1:numel(Out)                                                      %...then check all of the entries we have so far...
            if (In2{i}.N==Out{j}.N)&&(In2{i}.p==Out{j}.p)&&(In2{i}.q==Out{j}.q) %...and check to see if there's a (p,N,q) match...
                if numel(In2{i}.t)==0                                           %...then see if there's a t value. If not, we have a match.
                    Out{j}.S = cat(1,Out{j}.S,In2{i}.S);
                    Out{j}.ns = cat(1,Out{j}.ns,In2{i}.ns);
                    Out{j}.reals = cat(1,Out{j}.reals,In2{i}.reals);
                    newEntry = true;
                    break
                elseif In2{i}.t==Out{j}.t                                       %If there is a t value, make sure they match, too. If not, keep searching.
                    Out{j}.S = cat(1,Out{j}.S,In2{i}.S);
                    Out{j}.ns = cat(1,Out{j}.ns,In2{i}.ns);
                    Out{j}.reals = cat(1,Out{j}.reals,In2{i}.reals);
                    newEntry = true;
                    break
                end
            end
        end
        if ~newEntry        %If there are no matches, make a new entry.
            Out = cat(2,Out,EntryStruct);
            Os = numel(Out);
            Out{Os}.N = In2{i}.N;
            Out{Os}.p = In2{i}.p;
            Out{Os}.q = In2{i}.q;
            Out{Os}.t = In2{i}.t;
            Out{Os}.S = In2{i}.S;
            Out{Os}.ns = In2{i}.ns;
            Out{Os}.reals = In2{i}.reals;
        end
    end
end
%}

end