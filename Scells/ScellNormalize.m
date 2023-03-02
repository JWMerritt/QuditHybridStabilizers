function Out = ScellNormalize(In,ArgsX,ArgsY,DoOrder)
%   Normalizes the Scell - orders it, and combines duplicates. 'In' is a Scell, and 'Args' are cells of field names for the structs in the Scell. 'ArgsX' are the independent arguments which we order by. 'ArgsY' are the dependent arguments that get ordered.
%   In is expected to be a Scell - a cell of structs, each struct having one index value and multiple fields.

if nargs<3
    ArgsX = {'SystemSize','MeasurementProbability','InteractingProbability','TotalTimeSteps'}
    ArgsY = {'Realizations','LengthDistribution','SubsystemEntropy','PurificationEntropy'};
end
ArgsAll = cat(1,ArgsX,ArgsY);

if nargs<4
    DoOrder = true;
end

%{

First, we check for duplicates. We build up the Scell 'Mid' with entries from 'In', one at a time.
    For each new In{ii} we go though, we check it with the entries already in Mid to see if it matches, based on ArgsX
        If so, we concatenate the data based on ArgsY
        If not, we add a new entry to Mid

%} 

%   First, initialize a default structure:
EntryStruct = struct()
for ii=1:numel(ArgsAll)
    EntryStruct = setfield(EntryStruct,ArgsAll{ii},[]);
end


Mid = In{ii};

for InIndex = 2:numel(In)
    EntryEqual_Counter = true; %    just to initialize this variable.

    for MidIndex = 1:numel(Mid)
        %   We check if this In's ArgsX are the same as any of the Mid's ArgsX

        EntryEqual_Counter = true;
        for ArgIndex = 1:numel(ArgsX)
            EntryEqual_Counter = EntryEqual_Counter && (isequal( getfield(In{InIndex},ArgsX{ArgIndex}) , getfield(Mid{MidIndex},ArgsX{ArgIndex}) ));
            %   That is, if any ArgX is different, then EntryEqual_Counter = false.
        end
        %   We expect EntryEqual_Counter to be false in most cases.
        
        if EntryEqual_Counter==true
            %   In{InIndex} and Mid{MidIndex} have the same ArgsX

            for ArgIndex = 1:numel(ArgsY)
                %   append the In data to the Mid struct:
                Mid = setfield( Mid{MidIndex},ArgsY{ArgIndex} , cat(1, getfield(Mid{MidIndex},ArgsY{ArgIndex}), getfield(In{InIndex},ArgsY{ArgIndex})) );
            end
            break

        end

    end

    if EntryEqual_Counter==false
        %   We've gone through all the In entries, and none match to any of the Mid entries.
        %   Note that the previous loop breaks when EntryEqual_Counter==true
        Mid = cat(2,Mid,EntryStruct);
        for ArgIndex=1:ArgsAll
            Mid{MidIndex} = setfield( Mid{MidIndex}, ArgsAll{ArgIndex}, getfield(In{InIndex},ArgsAll{ArgIndex}));
        end
    end

end

%   Now that we've combined data based on ArgsX, we order them based on the values of ArgsX

if DoOrder

    AllEntriesX = struct();
    for ii=1:numel(ArgsX)
        AllEntriesX = setfield(AllEntriesX,ArgsX{ii},[]);
    end
    %   That is, the blank structure with all the ArgsX fields.

    %   Now, we find all the values for ArgX fields, then order them:
    %{
    for all elements in Mid,
        for all ArgsX,
            concatenate the value from the current Mid entry to the list of previous entries
        end
    end
    %}
    for MidIndex=1:numel(Mid)
        for ArgIndex=1:numel(ArgsX)
            % AllEntriesX.S = cat(1, AllEntriesX.S, Mid{ii}.S);
            AllEntriesX = setfield(AllEntriesX, ArgsX{ArgIndex}, cat(1, getfield(AllEntriesX, ArgsX{ArgIndex}), getfield(Mid{MidIndex},ArgsX{ArgIndex}) ) );
        end
    end

    for ii=1:numel(ArgsX)
        % AllEntriesX.S = unique(AllEntriesX.S, 'sorted');
        AllEntriesX = setfield(AllEntriesX, ArgsX{ArgIndex}, unique(getfield(AllEntriesX, ArgsX{ArgIndex}), 'sorted' ) );
    end

    %   We now create a cell, where each entry is the 

    %   I'll update this later, when I have the time to be more creative:

    Out = {};

    for ii=AllEntriesX.SystemSize
    for jj=AllEntriesX.MeasurementProbability
    for kk=AllEntriesX.InteractingProbability
    for ll=AllEntriesX.TotalTimeSteps
        for MM = Mid
            if (MM{1}.SystemSize==ii)&&(MM{1}.MeasurementProbability==jj)&&(MM{1}.InteractingProbability==kk)&&(MM{1}.TotalTimeSteps==kk)
                Out = cat(2,Out,MM);
                %   same as cat(2,Out,MM{1}), it seems.
            end
        end
    end
    end
    end

end

end